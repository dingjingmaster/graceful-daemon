project('graceful-daemon', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

i18n = import('i18n')

add_project_arguments('-X', '-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language: 'c')

i18n.gettext(meson.project_name(),
    args: '--directory=' + meson.source_root()
)

subdir('library')
subdir('src')

