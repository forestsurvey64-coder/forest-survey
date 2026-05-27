defmodule ForestSurvey.Surveys.GeneratedLink do
  use Ash.Resource,
    domain: ForestSurvey.Surveys,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "generated_links"
    repo ForestSurvey.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:full_url, :status, :notes, :vendor_id, :client_id]
    end

    update :update do
      accept [:full_url, :status, :notes]
    end

    read :latest_for_client do
      argument :client_id, :uuid, allow_nil?: false

      prepare build(
                filter: expr(client_id == ^arg(:client_id)),
                sort: [inserted_at: :desc],
                limit: 1
              )
    end

    update :mark_as_sent do
      change set_attribute(:status, :sent)
      change set_attribute(:sent_at, &DateTime.utc_now/0)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :full_url, :string do
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:pending, :sent, :responded, :dismissed]
      default :pending
      allow_nil? false
    end

    attribute :sent_at, :utc_datetime_usec
    attribute :notes, :string

    timestamps()
  end

  relationships do
    belongs_to :vendor, ForestSurvey.Surveys.Vendor do
      allow_nil? false
    end

    belongs_to :client, ForestSurvey.Surveys.Client do
      allow_nil? false
    end
  end
end
