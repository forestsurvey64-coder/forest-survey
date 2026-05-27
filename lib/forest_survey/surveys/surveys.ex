defmodule ForestSurvey.Surveys do
  use Ash.Domain, otp_app: :forest_survey, extensions: [AshPhoenix]

  resources do
    resource ForestSurvey.Surveys.Vendor do
      define :create_vendor, action: :create
      define :update_vendor, action: :update
      define :archive_vendor, action: :archive
      define :destroy_vendor, action: :destroy
      define :list_vendors, action: :read
      define :list_active_vendors, action: :list_active
      define :get_vendor, action: :read, get_by: [:id]
    end

    resource ForestSurvey.Surveys.Client do
      define :create_client, action: :create
      define :update_client, action: :update
      define :archive_client, action: :archive
      define :destroy_client, action: :destroy
      define :list_clients, action: :read
      define :list_active_clients, action: :list_active
      define :get_client, action: :read, get_by: [:id]
    end

    resource ForestSurvey.Surveys.GeneratedLink do
      define :create_link, action: :create
      define :update_link, action: :update
      define :destroy_link, action: :destroy
      define :list_links, action: :read
      define :get_link, action: :read, get_by: [:id]
      define :latest_link_for_client, action: :latest_for_client, args: [:client_id]
      define :mark_as_sent, action: :mark_as_sent
    end

    resource ForestSurvey.Surveys.Config do
      define :list_configs, action: :list_all
      define :get_config, action: :read, get_by: [:id]
      define :create_config, action: :create
      define :save_config, action: :save
      define :destroy_config, action: :destroy
    end
  end
end
