alias ForestSurvey.Surveys

# ---------------------------------------------------------------------------
# Vendors
# ---------------------------------------------------------------------------
vendors = [
  %{name: "Pablo May", team: "Ventas Cancún"},
  %{name: "Antonio Herrera", team: "Ventas Cancún"},
  %{name: "María López", team: "Ventas Riviera Maya"},
  %{name: "Carlos Ruiz", team: "Ventas Cozumel"},
  %{name: "Sofía Méndez", team: "Ventas Cancún"}
]

Enum.each(vendors, fn attrs ->
  Surveys.create_vendor!(attrs)
end)

IO.puts("✓ #{length(vendors)} vendors created")

# ---------------------------------------------------------------------------
# Clients (hotels in Cancún / Riviera Maya)
# ---------------------------------------------------------------------------
clients = [
  %{name: "Hotel Riu Cancún", zone: "Cancún"},
  %{name: "Hyatt Ziva Cancún", zone: "Cancún"},
  %{name: "Grand Velas Riviera Maya", zone: "Riviera Maya"},
  %{name: "Moon Palace Cancún", zone: "Cancún"},
  %{name: "Hard Rock Hotel Cancún", zone: "Cancún"},
  %{name: "Secrets Maroma Beach", zone: "Riviera Maya"},
  %{name: "Live Aqua Beach Resort", zone: "Cancún"},
  %{name: "Krystal Grand Cancún", zone: "Cancún"},
  %{name: "Nizuc Resort & Spa", zone: "Cancún"},
  %{name: "Royalton Riviera Cancún", zone: "Riviera Maya"},
  %{name: "Excellence Playa Mujeres", zone: "Cancún"},
  %{name: "Hotel Solaris Cancún", zone: "Cancún"},
  %{name: "Marriott Cancún Resort", zone: "Cancún"},
  %{name: "Westin Lagunamar", zone: "Cancún"},
  %{name: "Fiesta Americana Grand", zone: "Cancún"}
]

Enum.each(clients, fn attrs ->
  Surveys.create_client!(attrs)
end)

IO.puts("✓ #{length(clients)} clients created")

# ---------------------------------------------------------------------------
# Config (singleton — only create if none exists)
# ---------------------------------------------------------------------------
case Surveys.list_configs!() do
  [] ->
    Surveys.create_config!(%{
      name: "default",
      tally_base_url: "https://tally.so/r/J9XOr7",
      min_recontact_months: 6
    })
    IO.puts("✓ Config created")

  [_ | _] ->
    IO.puts("- Config already exists, skipping")
end
