defmodule ForestSurvey.Surveys.SixMonthRuleTest do
  use ForestSurvey.DataCase, async: true

  alias ForestSurvey.Surveys

  setup do
    vendor = Surveys.create_vendor!(%{name: "Test Vendor", team: "Test"})
    client = Surveys.create_client!(%{name: "Test Hotel", zone: "Cancún"})
    config = Surveys.create_config!(%{tally_base_url: "https://tally.so/r/test", min_recontact_months: 6})

    %{vendor: vendor, client: client, config: config}
  end

  describe "eligibility with no prior contact" do
    test "client with no previous links is allowed (first contact)", %{client: client, config: config} do
      result = check_eligibility(client.id, config.min_recontact_months)
      assert result == :first_contact
    end
  end

  describe "eligibility with recent link" do
    test "client contacted 3 months ago is blocked", %{vendor: vendor, client: client, config: config} do
      insert_link_months_ago(vendor, client, 3)

      result = check_eligibility(client.id, config.min_recontact_months)

      assert {:blocked, _link, months_elapsed, _available_on} = result
      assert months_elapsed == 3
    end

    test "client contacted 5 months ago is blocked (threshold is 6)", %{vendor: vendor, client: client, config: config} do
      insert_link_months_ago(vendor, client, 5)

      result = check_eligibility(client.id, config.min_recontact_months)

      assert {:blocked, _link, months_elapsed, _available_on} = result
      assert months_elapsed == 5
    end
  end

  describe "eligibility with old link" do
    test "client contacted 7 months ago is allowed", %{vendor: vendor, client: client, config: config} do
      insert_link_months_ago(vendor, client, 7)

      result = check_eligibility(client.id, config.min_recontact_months)

      assert {:allowed, _link, months_elapsed} = result
      assert months_elapsed == 7
    end

    test "client contacted exactly 6 months ago is allowed (threshold inclusive)", %{vendor: vendor, client: client, config: config} do
      insert_link_months_ago(vendor, client, 6)

      result = check_eligibility(client.id, config.min_recontact_months)

      assert {:allowed, _link, months_elapsed} = result
      assert months_elapsed >= 6
    end
  end

  describe "custom min_recontact_months" do
    test "with 4 month threshold, a 4-month-old link is allowed", %{vendor: vendor, client: client} do
      insert_link_months_ago(vendor, client, 4)

      result = check_eligibility(client.id, 4)

      assert {:allowed, _link, _months} = result
    end

    test "with 4 month threshold, a 3-month-old link is blocked", %{vendor: vendor, client: client} do
      insert_link_months_ago(vendor, client, 3)

      result = check_eligibility(client.id, 4)

      assert {:blocked, _link, _months, _available} = result
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp insert_link_months_ago(vendor, client, months) do
    past_date = DateTime.utc_now() |> DateTime.add(-months * 30 * 24 * 3600, :second)

    link =
      Surveys.create_link!(%{
        vendor_id: vendor.id,
        client_id: client.id,
        full_url: "https://tally.so/r/test?agent=Test&client=Test"
      })

    # Directly update inserted_at via Repo to simulate past creation
    ForestSurvey.Repo.query!(
      "UPDATE generated_links SET inserted_at = $1 WHERE id = $2",
      [past_date, link.id]
    )

    link
  end

  defp check_eligibility(client_id, min_months) do
    case Surveys.latest_link_for_client(client_id) do
      {:ok, []} ->
        :first_contact

      {:ok, [last_link | _]} ->
        reference_date = last_link.sent_at || last_link.inserted_at
        months_elapsed = months_since(reference_date)

        if months_elapsed >= min_months do
          {:allowed, last_link, months_elapsed}
        else
          months_remaining = min_months - months_elapsed
          available_on = Date.add(Date.utc_today(), months_remaining * 30)
          {:blocked, last_link, months_elapsed, available_on}
        end

      _ ->
        :first_contact
    end
  end

  defp months_since(%DateTime{} = dt) do
    now = DateTime.utc_now()
    years_diff = now.year - dt.year
    months_diff = now.month - dt.month
    total = years_diff * 12 + months_diff
    if now.day < dt.day, do: max(0, total - 1), else: max(0, total)
  end

  defp months_since(%NaiveDateTime{} = ndt) do
    months_since(DateTime.from_naive!(ndt, "Etc/UTC"))
  end
end
