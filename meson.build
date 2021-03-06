project(
  'com.paysonwallach.portico',
  'vala', 'c',
  version: '5.0.4',
  meson_version: '>= 0.49.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language:'c'
)

add_project_arguments(
  ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
  language: 'vala'
)

ubuntu_patched_gsd = get_option('ubuntu-patched-gsd')

if ubuntu_patched_gsd
  add_project_arguments(['--define', 'UBUNTU_PATCHED_GSD'], language: 'vala')
endif

greeter_resources = gnome.compile_resources(
  'greeter-resources',
  'data/greeter.gresource.xml',
  source_dir: 'data'
)

compositor_resources = gnome.compile_resources(
  'compositor-resources',
  'data/compositor.gresource.xml',
  source_dir: 'data'
)

subdir('src')
subdir('compositor')
subdir('data')
subdir('po')

vapigen = find_program('vapigen', required: false)
if vapigen.found()
  subdir('vapi')
endif

meson.add_install_script('meson/post_install.py')
