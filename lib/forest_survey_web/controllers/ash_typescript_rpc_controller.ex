defmodule ForestSurveyWeb.AshTypescriptRpcController do
  use ForestSurveyWeb, :controller

  def run(conn, params) do
    result = AshTypescript.Rpc.run_action(:forest_survey, conn, params)
    json(conn, result)
  end

  def validate(conn, params) do
    result = AshTypescript.Rpc.validate_action(:forest_survey, conn, params)
    json(conn, result)
  end
end
