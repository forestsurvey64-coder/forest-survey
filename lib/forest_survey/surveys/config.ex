defmodule ForestSurvey.Surveys.Config do
  use Ash.Resource,
    domain: ForestSurvey.Surveys,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "survey_configs"
    repo ForestSurvey.Repo
  end

  actions do
    create :create do
      accept [:name, :tally_base_url, :min_recontact_months]
    end

    defaults [:read, :destroy]

    read :list_all do
      prepare build(sort: [inserted_at: :asc])
    end

    update :save do
      accept [:name, :tally_base_url, :min_recontact_months]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      constraints min_length: 1
    end

    attribute :tally_base_url, :string do
      allow_nil? false
    end

    attribute :min_recontact_months, :integer do
      default 6
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
