lib_version = 0.1

cur_dir = $(shell dirname $(shell pwd))

vala_pkg = \
	-X -lm														\
	--pkg posix													\
	--pkg gio-2.0												\
	--pkg gee-0.8												\
	--pkg gtk+-3.0												\
	--pkg glib-2.0												\
	--pkg gobject-2.0											\
	--pkg gio-unix-2.0											\
	--pkg json-glib-1.0											\

vala_flags = \
	-g															\
	-X -DGETTEXT_PACKAGE=\"graceful-daemon\"					\

vala_src = $(wildcard *.vala)
#vala_header = $(patsubst %.vala, %.h, $(vala_src))
#vala_source = $(patsubst %.vala, %.c, $(vala_src))

all : gen_vala_lib

gen_vala_lib : 
	valac -X -fPIC -X -shared --library=GracefulDaemon --gir=GracefulDaemon-$(lib_version).gir -H graceful-daemon.h -o libgraceful-daemon.so.$(lib_version) $(vala_flags) $(vala_pkg) $(vala_src)
	g-ir-compiler --shared-library=libgraceful-daemon.so.$(lib_version) --output=GracefulDaemon-$(lib_version).typelib GracefulDaemon-$(lib_version).gir


vala_header :
	valac $< -c -C    $< $(vala_src) $(vala_flags)


%.h : %.vala
	valac $< -c -H 	  $@ $(vala_pkg) $(vala_flags)

%.c : %.vala
	valac $< -c -C -o $@ $(vala_pkg) $(vala_flags)


clean:
	rm -f *.o *.gir *.typelib *.vapi *.so *.so.$(lib_version)

.PHONY:clean *.h *.c
