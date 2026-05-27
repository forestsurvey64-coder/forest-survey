defmodule ForestSurveyWeb.VendorsLive do
  use ForestSurveyWeb, :live_view

  alias ForestSurvey.Surveys
  alias ForestSurvey.Surveys.Vendor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, nil) |> load_vendors()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :form, nil)
  end

  defp apply_action(socket, :new, _params) do
    form = AshPhoenix.Form.for_create(Vendor, :create) |> to_form()
    assign(socket, :form, form)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    vendor = Surveys.get_vendor!(id)
    form = AshPhoenix.Form.for_update(vendor, :update) |> to_form()
    assign(socket, :form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _vendor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vendedor guardado correctamente.")
         |> push_navigate(to: ~p"/admin/vendors")
         |> load_vendors()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("archive", %{"id" => id}, socket) do
    with {:ok, vendor} <- Surveys.get_vendor(id),
         {:ok, _} <- Surveys.archive_vendor(vendor) do
      {:noreply, socket |> put_flash(:info, "Vendedor archivado.") |> load_vendors()}
    else
      _ -> {:noreply, put_flash(socket, :error, "No se pudo archivar el vendedor.")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/vendors")}
  end

  defp load_vendors(socket) do
    assign(socket, :vendors, Surveys.list_active_vendors!())
  end
end
