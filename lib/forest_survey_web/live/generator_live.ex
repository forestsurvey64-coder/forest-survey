defmodule ForestSurveyWeb.GeneratorLive do
  use ForestSurveyWeb, :live_view

  alias ForestSurvey.Surveys

  @impl true
  def mount(_params, _session, socket) do
    vendors = Surveys.list_active_vendors!()
    clients = Surveys.list_active_clients!()
    configs = Surveys.list_configs!()
    default_config = List.first(configs)

    {:ok,
     socket
     |> assign(:vendors, vendors)
     |> assign(:clients, clients)
     |> assign(:configs, configs)
     |> assign(:config, default_config)
     |> assign(:vendor_id, nil)
     |> assign(:client_id, nil)
     |> assign(:eligibility, nil)
     |> assign(:generated_link, nil)}
  end

  @impl true
  def handle_event("select_vendor", %{"vendor_id" => vendor_id}, socket) do
    vendor_id = if vendor_id == "", do: nil, else: vendor_id
    socket = assign(socket, :vendor_id, vendor_id) |> assign(:generated_link, nil)
    {:noreply, recalculate_eligibility(socket)}
  end

  def handle_event("select_client", %{"client_id" => client_id}, socket) do
    client_id = if client_id == "", do: nil, else: client_id
    socket = assign(socket, :client_id, client_id) |> assign(:generated_link, nil)
    {:noreply, recalculate_eligibility(socket)}
  end

  def handle_event("select_config", %{"config_id" => config_id}, socket) do
    config = Enum.find(socket.assigns.configs, &(to_string(&1.id) == config_id))
    socket = assign(socket, :config, config) |> assign(:generated_link, nil)
    {:noreply, recalculate_eligibility(socket)}
  end

  def handle_event("generate_link", _params, socket) do
    %{vendor_id: vendor_id, client_id: client_id, config: config} = socket.assigns

    with {:ok, vendor} <- Surveys.get_vendor(vendor_id),
         {:ok, client} <- Surveys.get_client(client_id) do
      url = build_url(vendor, client, config.tally_base_url)

      case Surveys.create_link(%{
             vendor_id: vendor_id,
             client_id: client_id,
             full_url: url
           }) do
        {:ok, link} ->
          {:noreply, assign(socket, :generated_link, link)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Error al generar el link. Inténtalo de nuevo.")}
      end
    else
      _ -> {:noreply, put_flash(socket, :error, "Selecciona un vendedor y un cliente.")}
    end
  end

  def handle_event("mark_as_sent", %{"id" => id}, socket) do
    case Surveys.get_link(id) do
      {:ok, link} ->
        case Surveys.mark_as_sent(link) do
          {:ok, updated} ->
            socket =
              socket
              |> put_flash(:info, "¡Marcado como enviado!")
              |> assign(:generated_link, updated)

            {:noreply, socket}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "No se pudo marcar como enviado.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Link no encontrado.")}
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp recalculate_eligibility(%{assigns: %{vendor_id: nil}} = socket), do: assign(socket, :eligibility, nil)
  defp recalculate_eligibility(%{assigns: %{client_id: nil}} = socket), do: assign(socket, :eligibility, nil)
  defp recalculate_eligibility(%{assigns: %{config: nil}} = socket), do: assign(socket, :eligibility, nil)

  defp recalculate_eligibility(socket) do
    %{client_id: client_id, config: config} = socket.assigns
    eligibility = check_eligibility(client_id, config.min_recontact_months)
    assign(socket, :eligibility, eligibility)
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
  rescue
    _ -> :first_contact
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

  defp build_url(vendor, client, base_url) do
    params = %{
      "agente" => vendor.name,
      "cliente" => client.main_contact || client.name,
      "hotel" => client.name
    }

    "#{base_url}?#{URI.encode_query(params)}"
  end

  defp find_record(list, id), do: Enum.find(list, &(to_string(&1.id) == to_string(id)))
end
