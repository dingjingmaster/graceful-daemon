/* TimeoutCounter.vala
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

using Graceful.Logging;
using Graceful.FileSystem;
using Graceful.Misc;

public class TimeoutCounter : GLib.Object
{

	public bool active = false;
	public string process_to_kill = "";
	public const int DEFAULT_SECONDS_TO_WAIT = 60;
	public int seconds_to_wait = 60;
	public bool exit_app = false;

	public void kill_process_on_timeout(
		string process_to_kill, int seconds_to_wait = DEFAULT_SECONDS_TO_WAIT, bool exit_app = false){

		this.process_to_kill = process_to_kill;
		this.seconds_to_wait = seconds_to_wait;
		this.exit_app = exit_app;

		try {
			active = true;
			Thread.create<void> (start_counter_thread, true);
		}
		catch (Error e) {
			log_error (e.message);
		}
	}

	public void exit_on_timeout(int seconds_to_wait = DEFAULT_SECONDS_TO_WAIT){
		this.process_to_kill = "";
		this.seconds_to_wait = seconds_to_wait;
		this.exit_app = true;

		try {
			active = true;
			Thread.create<void> (start_counter_thread, true);
		}
		catch (Error e) {
			log_error (e.message);
		}
	}

	public void stop(){
		active = false;
	}

	public void start_counter_thread(){
		int secs = 0;

		while (active && (secs < seconds_to_wait)){
			Thread.usleep((ulong) GLib.TimeSpan.MILLISECOND * 1000);
			secs += 1;
		}

		if (active){
			active = false;
			stdout.printf("\n");

			if (process_to_kill.length > 0){
				Posix.system("killall " + process_to_kill);
				log_debug("[timeout] Killed process" + ": %s".printf(process_to_kill));
			}

			if (exit_app){
				log_debug("[timeout] Exit application");
				Process.exit(0);
			}
		}
	}
}


