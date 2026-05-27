defmodule ForestSurvey.Surveys.Vendor do
  use Ash.Resource,
    domain: ForestSurvey.Surveys,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "vendors"
    repo ForestSurvey.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :team, :email, :whatsapp]
    end

    update :update do
      accept [:name, :team, :email, :whatsapp]
    end

    read :list_active do
      prepare build(filter: [active: true], sort: [name: :asc])
    end

    update :archive do
      accept []
      change set_attribute(:active, false)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      constraints min_length: 1
    end

    attribute :team, :string
    attribute :email, :string
    attribute :whatsapp, :string

    attribute :active, :boolean do
      default true
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :generated_links, ForestSurvey.Surveys.GeneratedLink
  end
end
