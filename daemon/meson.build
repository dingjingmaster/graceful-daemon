graceful_daemon_sources = [
  'Main.vala',

  'Graceful.DBusDaemon.vala',
]

graceful_daemon_deps = [
  graceful_daemon_libs,
]

executable('graceful-daemon', graceful_daemon_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_deps,
  install: true,
)
