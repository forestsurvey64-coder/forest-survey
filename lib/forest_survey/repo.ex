defmodule ForestSurvey.Repo do
  use Ecto.Repo,
    otp_app: :forest_survey,
    adapter: Ecto.Adapters.SQLite3
end
