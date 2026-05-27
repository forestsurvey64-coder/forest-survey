defmodule ForestSurveyWeb.Layouts do
  use ForestSurveyWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, default: nil
  attr :inner_content, :any, default: nil

  def app(assigns) do
    ~H"""
    <div class="drawer">
      <input id="nav-drawer" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col min-h-screen">
        <%!-- Navbar --%>
        <header class="navbar bg-base-100 border-b border-base-300 px-4 sm:px-6 sticky top-0 z-30 shadow-sm">
          <div class="navbar-start gap-2">
            <%!-- Mobile hamburger --%>
            <label for="nav-drawer" class="btn btn-ghost btn-square lg:hidden">
              <.icon name="hero-bars-3" class="size-5" />
            </label>
            <%!-- Logo --%>
            <a href={~p"/"} class="flex items-center gap-2">
              <span class="font-serif text-xl font-semibold tracking-widest text-primary uppercase">
                Forest
              </span>
            </a>
            <%!-- Divider --%>
            <span class="hidden lg:block text-base-300 select-none">|</span>
          </div>

          <nav class="navbar-center hidden lg:flex">
            <ul class="flex items-center gap-1 text-sm font-medium">
              <li>
                <a href={~p"/"} class={nav_link_class(@current_scope, :generator)}>
                  <.icon name="hero-link" class="size-4" /> Generador
                </a>
              </li>
              <li>
                <a href={~p"/history"} class={nav_link_class(@current_scope, :history)}>
                  <.icon name="hero-clock" class="size-4" /> Historial
                </a>
              </li>
              <li class="relative group">
                <details class="group">
                  <summary class={nav_link_class(@current_scope, :admin) <> " list-none cursor-pointer"}>
                    <.icon name="hero-cog-6-tooth" class="size-4" /> Admin
                    <.icon name="hero-chevron-down" class="size-3 opacity-60" />
                  </summary>
                  <ul class="absolute top-full left-1/2 -translate-x-1/2 mt-1 bg-base-100 rounded-xl border border-base-300 w-44 shadow-xl z-50 py-1 overflow-hidden">
                    <li>
                      <a href={~p"/admin/vendors"} class="flex items-center gap-2 px-4 py-2.5 text-sm hover:bg-base-200 transition-colors">
                        <.icon name="hero-users" class="size-4 text-base-content/50" /> Vendedores
                      </a>
                    </li>
                    <li>
                      <a href={~p"/admin/clients"} class="flex items-center gap-2 px-4 py-2.5 text-sm hover:bg-base-200 transition-colors">
                        <.icon name="hero-building-office-2" class="size-4 text-base-content/50" /> Clientes
                      </a>
                    </li>
                    <li class="border-t border-base-200 mt-1 pt-1">
                      <a href={~p"/admin/config"} class="flex items-center gap-2 px-4 py-2.5 text-sm hover:bg-base-200 transition-colors">
                        <.icon name="hero-wrench-screwdriver" class="size-4 text-base-content/50" /> Configuración
                      </a>
                    </li>
                  </ul>
                </details>
              </li>
            </ul>
          </nav>

          <div class="navbar-end">
            <span class="hidden lg:flex items-center gap-1.5 text-xs text-base-content/40 font-medium tracking-wider uppercase">
              <span class="size-1.5 rounded-full bg-success inline-block"></span>
              Interno
            </span>
          </div>
        </header>

        <%!-- Page content --%>
        <main class="flex-1 px-4 sm:px-6 lg:px-8 py-8">
          <div class="mx-auto max-w-4xl">
            {@inner_content}
          </div>
        </main>

        <%!-- Footer --%>
        <footer class="py-4 px-6 bg-base-200 text-center text-xs text-base-content/40 border-t border-base-300">
          FOREST · Sistema interno de encuestas
        </footer>
      </div>

      <%!-- Mobile sidebar --%>
      <div class="drawer-side z-40">
        <label for="nav-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
        <nav class="bg-base-100 min-h-full w-72 p-5 flex flex-col gap-1 shadow-2xl">
          <div class="mb-8 px-1 flex items-center justify-between">
            <span class="font-serif text-xl font-semibold tracking-widest text-primary uppercase">Forest</span>
            <label for="nav-drawer" class="btn btn-ghost btn-sm btn-square">
              <.icon name="hero-x-mark" class="size-4" />
            </label>
          </div>
          <p class="text-xs font-semibold uppercase tracking-wider text-base-content/40 px-3 mb-1">Principal</p>
          <a href={~p"/"} class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-base-200 transition-colors">
            <.icon name="hero-link" class="size-4 text-primary" /> Generador
          </a>
          <a href={~p"/history"} class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-base-200 transition-colors">
            <.icon name="hero-clock" class="size-4 text-primary" /> Historial
          </a>
          <p class="text-xs font-semibold uppercase tracking-wider text-base-content/40 px-3 mb-1 mt-4">Administración</p>
          <a href={~p"/admin/vendors"} class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-base-200 transition-colors">
            <.icon name="hero-users" class="size-4 text-base-content/50" /> Vendedores
          </a>
          <a href={~p"/admin/clients"} class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-base-200 transition-colors">
            <.icon name="hero-building-office-2" class="size-4 text-base-content/50" /> Clientes
          </a>
          <a href={~p"/admin/config"} class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-base-200 transition-colors">
            <.icon name="hero-wrench-screwdriver" class="size-4 text-base-content/50" /> Configuración
          </a>
        </nav>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  defp nav_link_class(_scope, _page) do
    "flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium text-base-content/70 hover:text-base-content hover:bg-base-200 transition-colors"
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="Sin conexión"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Intentando reconectar...
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Algo salió mal"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Intentando reconectar...
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
