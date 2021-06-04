project('graceful-daemon', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

i18n = import('i18n')

add_project_arguments(
  '-X',
  '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
  language: 'c')

i18n.gettext(meson.project_name(),
    args: '--directory=' + meson.source_root()
)

graceful_daemon_common_deps = [
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gtk+-3.0'),
  dependency('gobject-2.0'),
  dependency('gio-unix-2.0'),
  dependency('json-glib-1.0'),

  meson.get_compiler('c').find_library('m'),
  meson.get_compiler('vala').find_library('posix'),
]

subdir('library')
subdir('daemon')

