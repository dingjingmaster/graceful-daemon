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

gd_lib = static_library('graceful-daemon', graceful_daemon_libray_sources,
  vala_args: '--target-glib=2.58',  dependencies: graceful_daemon_common_deps,
  install: true,
)

graceful_daemon_libs = declare_dependency (link_with: gd_lib,
  dependencies: graceful_daemon_common_deps,
)
