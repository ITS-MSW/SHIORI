# dmgbuild supplies defines from its -D arguments.
format = "UDZO"
filesystem = "HFS+"
files = [defines["app"]]
symlinks = {"Applications": "/Applications"}
background = defines["background"]
window_rect = ((100, 100), (660, 440))
icon_locations = {"SHIORI.app": (170, 220), "Applications": (490, 220)}
icon_size = 96
text_size = 14
show_toolbar = False
show_status_bar = False
show_pathbar = False
show_sidebar = False
default_view = "icon-view"
