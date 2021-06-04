/* Graceful.System.vala
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

namespace Graceful.System
{

	using Graceful.ProcessHelper;
	using Graceful.Logging;
	using Graceful.Misc;
	using Graceful.FileSystem;

	// user ---------------------------------------------------

	public bool user_is_admin(){

		return (get_user_id_effective() == 0);
	}

	public int get_user_id(){

		// returns actual user id of current user (even for applications executed with sudo and pkexec)

		string pkexec_uid = GLib.Environment.get_variable("PKEXEC_UID");

		if (pkexec_uid != null){
			return int.parse(pkexec_uid);
		}

		string sudo_user = GLib.Environment.get_variable("SUDO_USER");

		if (sudo_user != null){
			return get_user_id_from_username(sudo_user);
		}

		return get_user_id_effective(); // normal user
	}

	public int get_user_id_effective(){

		// returns effective user id (0 for applications executed with sudo and pkexec)

		int uid = -1;
		string cmd = "id -u";
		string std_out, std_err;
		exec_sync(cmd, out std_out, out std_err);
		if ((std_out != null) && (std_out.length > 0)){
			uid = int.parse(std_out);
		}

		return uid;
	}

	public string get_username(){

		// returns actual username of current user (even for applications executed with sudo and pkexec)

		return get_username_from_uid(get_user_id());
	}

	public string get_username_effective(){

		// returns effective user id ('root' for applications executed with sudo and pkexec)

		return get_username_from_uid(get_user_id_effective());
	}

	public int get_user_id_from_username(string username){

		// check local user accounts in /etc/passwd -------------------

		foreach(var line in file_read("/etc/passwd").split("\n")){

			var arr = line.split(":");

			if ((arr.length >= 3) && (arr[0] == username)){

				return int.parse(arr[2]);
			}
		}

		// not found --------------------

		log_error("UserId not found for userName: %s".printf(username));

		return -1;
	}

	public string get_username_from_uid(int user_id){

		// check local user accounts in /etc/passwd -------------------

		foreach(var line in file_read("/etc/passwd").split("\n")){

			var arr = line.split(":");

			if ((arr.length >= 3) && (arr[2] == user_id.to_string())){

				return arr[0];
			}
		}

		// not found --------------------

		log_error("Username not found for uid: %d".printf(user_id));

		return "";
	}

	public string get_user_home(string username = get_username()){

		// check local user accounts in /etc/passwd -------------------

		foreach(var line in file_read("/etc/passwd").split("\n")){

			var arr = line.split(":");

			if ((arr.length >= 6) && (arr[0] == username)){

				return arr[5];
			}
		}

		// not found --------------------

		log_error("Home directory not found for user: %s".printf(username));

		return "";
	}

	public string get_user_home_effective(){
		return get_user_home(get_username_effective());
	}

	// application -----------------------------------------------

	public string get_app_path(){

		/* Get path of current process */

		try{
			return GLib.FileUtils.read_link ("/proc/self/exe");
		}
		catch (Error e){
	        log_error (e.message);
	        return "";
	    }
	}

	public string get_app_dir(){

		/* Get parent directory of current process */

		try{
			return (File.new_for_path (GLib.FileUtils.read_link ("/proc/self/exe"))).get_parent ().get_path ();
		}
		catch (Error e){
	        log_error (e.message);
	        return "";
	    }
	}

	// system ------------------------------------

	// dep: cat TODO: rewrite
	public double get_system_uptime_seconds(){

		/* Returns the system up-time in seconds */

		string cmd = "";
		string std_out;
		string std_err;
		int ret_val;

		try{
			cmd = "cat /proc/uptime";
			Process.spawn_command_line_sync(cmd, out std_out, out std_err, out ret_val);
			string uptime = std_out.split(" ")[0];
			double secs = double.parse(uptime);
			return secs;
		}
		catch(Error e){
			log_error (e.message);
			return 0;
		}
	}

	public string get_desktop_name(){

		/* Return the names of the current Desktop environment */

		int pid = -1;

		pid = get_pid_by_name("cinnamon");
		if (pid > 0){
			return "Cinnamon";
		}

		pid = get_pid_by_name("xfdesktop");
		if (pid > 0){
			return "Xfce";
		}

		pid = get_pid_by_name("lxsession");
		if (pid > 0){
			return "LXDE";
		}

		pid = get_pid_by_name("gnome-shell");
		if (pid > 0){
			return "Gnome";
		}

		pid = get_pid_by_name("wingpanel");
		if (pid > 0){
			return "Elementary";
		}

		pid = get_pid_by_name("unity-panel-service");
		if (pid > 0){
			return "Unity";
		}

		pid = get_pid_by_name("plasma-desktop");
		if (pid > 0){
			return "KDE";
		}

		return "Unknown";
	}

	public Gee.ArrayList<string> list_dir_names(string path){
		var list = new Gee.ArrayList<string>();

		try
		{
			File f_home = File.new_for_path (path);
			FileEnumerator enumerator = f_home.enumerate_children ("%s".printf(FileAttribute.STANDARD_NAME), 0);
			FileInfo file;
			while ((file = enumerator.next_file ()) != null) {
				string name = file.get_name();
				//string item = path + "/" + name;
				list.add(name);
			}
		}
		catch (Error e) {
			log_error (e.message);
		}

		//sort the list
		CompareDataFunc<string> entry_compare = (a, b) => {
			return strcmp(a,b);
		};
		list.sort((owned) entry_compare);

		return list;
	}

	// internet helpers ----------------------

	public bool shutdown (){

		/* Shutdown the system immediately */

		try{
			string[] argv = { "shutdown", "-h", "now" };
			Pid procId;
			Process.spawn_async(null, argv, null, SpawnFlags.SEARCH_PATH, null, out procId);
			return true;
		}
		catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	public bool command_exists(string command){
		string path = get_cmd_path(command);
		return ((path != null) && (path.length > 0));
	}

	// open -----------------------------

	public bool xdg_open (string file, string user = ""){
		string path = get_cmd_path ("xdg-open");
		if ((path != null) && (path != "")){
			string cmd = "xdg-open '%s'".printf(escape_single_quote(file));
			if (user.length > 0){
				cmd = "pkexec --user %s env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY ".printf(user) + cmd;
			}
			log_debug(cmd);
			int status = exec_script_async(cmd);
			return (status == 0);
		}
		return false;
	}

	public bool exo_open_folder (string dir_path, bool xdg_open_try_first = true){

		/* Tries to open the given directory in a file manager */

		/*
		xdg-open is a desktop-independent tool for configuring the default applications of a user.
		Inside a desktop environment (e.g. GNOME, KDE, Xfce), xdg-open simply passes the arguments
		to that desktop environment's file-opener application (gvfs-open, kde-open, exo-open, respectively).
		We will first try using xdg-open and then check for specific file managers if it fails.
		*/

		string path;
		int status;

		if (xdg_open_try_first){
			//try using xdg-open
			path = get_cmd_path ("xdg-open");
			if ((path != null)&&(path != "")){
				string cmd = "xdg-open '%s'".printf(escape_single_quote(dir_path));
				status = exec_script_async (cmd);
				return (status == 0);
			}
		}

		foreach(string app_name in
			new string[]{ "nemo", "nautilus", "thunar", "pantheon-files", "marlin"}){

			path = get_cmd_path (app_name);
			if ((path != null)&&(path != "")){
				string cmd = "%s '%s'".printf(app_name, escape_single_quote(dir_path));
				status = exec_script_async (cmd);
				return (status == 0);
			}
		}

		if (xdg_open_try_first == false){
			//try using xdg-open
			path = get_cmd_path ("xdg-open");
			if ((path != null)&&(path != "")){
				string cmd = "xdg-open '%s'".printf(escape_single_quote(dir_path));
				status = exec_script_async (cmd);
				return (status == 0);
			}
		}

		return false;
	}

	public bool exo_open_textfile (string txt_file){

		/* Tries to open the given text file in a text editor */

		string path;
		int status;
		string cmd;

		path = get_cmd_path ("exo-open");
		if ((path != null)&&(path != "")){
			cmd = "exo-open '%s'".printf(escape_single_quote(txt_file));
			status = exec_script_async (cmd);
			return (status == 0);
		}

		path = get_cmd_path ("gedit");
		if ((path != null)&&(path != "")){
			cmd = "gedit --new-document '%s'".printf(escape_single_quote(txt_file));
			status = exec_script_async (cmd);
			return (status == 0);
		}

		return false;
	}

	public bool exo_open_url (string url){

		/* Tries to open the given text file in a text editor */

		string path;
		int status;
		//string cmd;

		path = get_cmd_path ("exo-open");
		if ((path != null)&&(path != "")){
			status = exec_script_async ("exo-open \"" + url + "\"");
			return (status == 0);
		}

		path = get_cmd_path ("firefox");
		if ((path != null)&&(path != "")){
			status = exec_script_async ("firefox \"" + url + "\"");
			return (status == 0);
		}

		path = get_cmd_path ("chromium-browser");
		if ((path != null)&&(path != "")){
			status = exec_script_async ("chromium-browser \"" + url + "\"");
			return (status == 0);
		}

		return false;
	}

	public bool using_efi_boot(){

		/* Returns true if the system was booted in EFI mode
		 * and false for BIOS mode */

		return dir_exists("/sys/firmware/efi");
	}

	// timers --------------------------------------------------

	public GLib.Timer timer_start(){
		var timer = new GLib.Timer();
		timer.start();
		return timer;
	}

	public ulong timer_elapsed(GLib.Timer timer, bool stop = true){
		ulong microseconds;
		double seconds;
		seconds = timer.elapsed (out microseconds);
		if (stop){
			timer.stop();
		}
		return (ulong)((seconds * 1000 ) + (microseconds / 1000));
	}

	public void sleep(int milliseconds){
		Thread.usleep ((ulong) milliseconds * 1000);
	}

	public string timer_elapsed_string(GLib.Timer timer, bool stop = true){
		ulong microseconds;
		double seconds;
		seconds = timer.elapsed (out microseconds);
		if (stop){
			timer.stop();
		}
		return "%.0f ms".printf((seconds * 1000 ) + microseconds/1000);
	}

	public void timer_elapsed_print(GLib.Timer timer, bool stop = true){
		ulong microseconds;
		double seconds;
		seconds = timer.elapsed (out microseconds);
		if (stop){
			timer.stop();
		}
		log_msg("%s %lu\n".printf(seconds.to_string(), microseconds));
	}

	public void set_numeric_locale(string type){
		Intl.setlocale(GLib.LocaleCategory.NUMERIC, type);
	    Intl.setlocale(GLib.LocaleCategory.COLLATE, type);
	    Intl.setlocale(GLib.LocaleCategory.TIME, type);
	}
}

