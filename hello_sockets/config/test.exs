import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hello_sockets, HelloSocketsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "miE1X1yPKL7P/ydDNSYrcajLqtANJrCsfUoPnY1TUTrUP1OQwDm4duWzoSrPOAzZ",
  server: false

# In test we don't send emails.
config :hello_sockets, HelloSockets.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# We will use StatsDLogger in a special test mode to write this test-
# it will forward any stats to the test process rather than the StatsD server. Let's
# configure our test environment for StatsD and then write our test.
config :statix, HelloSockets.Statix, port: 8127
