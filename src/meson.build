graceful_daemon_sources = [
  'main.vala',
]

graceful_daemon_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
]

executable('graceful-daemon', graceful_daemon_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_deps,
  install: true,
)
