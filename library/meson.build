graceful_daemon_libray_sources = [
  'Graceful.Misc.vala',
  'Graceful.Logging.vala',
  'Graceful.Process.vala',
  'Graceful.FileSystem.vala',
]

graceful_daemon_libray_deps = [
  dependency('posix'),
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gtk+-3.0'),
  dependency('gobject-2.0'),
  dependency('json-glib-1.0'),
]

static_library('graceful-daemon', graceful_daemon_libray_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_libray_deps,
  install: true,
)
