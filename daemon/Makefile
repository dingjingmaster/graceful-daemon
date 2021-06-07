cur_dir = $(shell dirname $(shell pwd))

vala_pkg = \
	--pkg=gio-2.0												\
	--pkg=gee-0.8												\
	--pkg=glib-2.0												\
	--pkg=gobject-2.0											\
	--pkg=gio-unix-2.0											\

vala_flags = \
	-g															\
	--basedir $(cur_dir)										\

vala_src = \
	Graceful.Logging.vala 										\
	Graceful.DBusDaemon.vala									\
	Graceful.PluginManager.vala									\
	Graceful.Plugin.Interface.vala								\

vala_header = $(patsubst %.vala, %.h, $(vala_src))
vala_source = $(patsubst %.vala, %.c, $(vala_src))

gen_c_code : $(vala_header) $(vala_source)


%.h : %.vala
	valac $< -c -H 	  $@ $(vala_pkg) $(vala_flags)

%.c : %.vala
	valac $< -c -C -o $@ $(vala_pkg) $(vala_flags)


clean:
	rm -f *.o
	rm -f $(vala_header)
	rm -f $(vala_source)

.PHONY:clean *.h *.c
