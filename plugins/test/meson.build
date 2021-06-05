plugin_test_sources = [
  'Graceful.Plugin.test.vala'
]

plugin_test = shared_library('graceful-plugin-test', plugin_test_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_common_deps,
  install: true,
)

