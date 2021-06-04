graceful_daemon_libray_sources = [
  'Graceful.Misc.vala',
  'Graceful.Json.vala',
  'Graceful.System.vala',
  'Graceful.Global.vala',
  'Graceful.Logging.vala',
  'Graceful.Process.vala',
  'Graceful.FileSystem.vala',

  'Device.vala',
  'CronTab.vala',
  'AppLock.vala',
  'FileItem.vala',
  'AsyncTask.vala',
  'OSDNotify.vala',
  'RsyncTask.vala',
  'MountEntry.vala',
  'FsTabEntry.vala',
  'SystemUser.vala',
  'LicenseText.vala',
  'IconManager.vala',
  'CryptTabEntry.vala',
  'TimeoutCounter.vala',
]

graceful_daemon_libray_deps = [
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gtk+-3.0'),
  dependency('gobject-2.0'),
  dependency('gio-unix-2.0'),
  dependency('json-glib-1.0'),

  meson.get_compiler('vala').find_library('posix'),
]

static_library('graceful-daemon', graceful_daemon_libray_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_libray_deps,
  install: true,
)
