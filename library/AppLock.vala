/* AppLock.vala
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
using Graceful.ProcessHelper;
using Graceful.Misc;

public class AppLock : GLib.Object
{
	public string lock_file = "";
	public string lock_message = "";

	public bool create(string app_name, string message){

		var lock_dir = "/var/run/lock/%s".printf(app_name);
		dir_create(lock_dir);
		lock_file = path_combine(lock_dir, "lock");

		try{
			var file = File.new_for_path(lock_file);
			if (file.query_exists()) {

				string txt = file_read(lock_file);
				string process_id = txt.split(";")[0].strip();
				lock_message = txt.split(";")[1].strip();
				long pid = long.parse(process_id);

				if (process_is_running(pid)){
					log_msg(_("Another instance of this application is running")
						+ " (PID=%ld)".printf(pid));
					return false;
				}
				else{
					log_msg(_("[Warning] Deleted invalid lock"));
					file.delete();
					write_lock_file(message);
					return true;
				}
			}
			else{
				write_lock_file(message);
				return true;
			}
		}
		catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	private void write_lock_file(string message){
		string current_pid = ((long) Posix.getpid()).to_string();
		file_write(lock_file, "%s;%s".printf(current_pid, message));
	}

	public void remove(){
		try{
			var file = File.new_for_path (lock_file);
			if (file.query_exists()) {
				file.delete();
			}
		}
		catch (Error e) {
			log_error (e.message);
		}
	}

}

