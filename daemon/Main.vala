/* main.vala
 *
 * Copyright 2021 dingjing
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name(s) of the above copyright
 * holders shall not be used in advertising or otherwise to promote the sale,
 * use or other dealings in this Software without prior written
 * authorization.
 */

using GLib.Environment;

using Graceful;
using Graceful.Logging;

public class Main : GLib.Object {


    public static int main (string[] args)
    {
        string logDir = string.join ("/", get_home_dir (), ".config/", "graceful-daemon");
        log_init (logDir, "graceful-daemon.log");

        log_debug("test");
        log_debug("test");
        log_debug("test");
        log_debug("test");

        Bus.own_name (BusType.SESSION, "com.dingjing.graceful.daemon", BusNameOwnerFlags.NONE,
                        on_bus_aquired, () => {},
                        () => stderr.printf ("Could not aquire name\n"));

        new MainLoop().run();

        return 0;
    }
}

void on_bus_aquired (DBusConnection conn)
{
    try {
        conn.register_object ("/com/dingjing/graceful/daemon", new Graceful.DBusDaemon ());
    } catch (IOError e) {
    log_error (_("The process has been started and does not need to be executed again!"));
        stderr.printf ("Could not register service\n");
    }
}
