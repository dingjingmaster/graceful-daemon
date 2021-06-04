/* LinuxDistro.vala
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

public class LinuxDistro : GLib.Object
{

	/* Class for storing information about Linux distribution */

	public string dist_id = "";
	public string description = "";
	public string release = "";
	public string codename = "";

	public LinuxDistro(){

		dist_id = "";
		description = "";
		release = "";
		codename = "";
	}

	public string full_name(){

		if (dist_id == ""){
			return "";
		}
		else{
			string val = "";
			val += dist_id;
			val += (release.length > 0) ? " " + release : "";
			val += (codename.length > 0) ? " (" + codename + ")" : "";
			return val;
		}
	}

	public static LinuxDistro get_dist_info(string root_path){

		/* Returns information about the Linux distribution
		 * installed at the given root path */

		LinuxDistro info = new LinuxDistro();

		string dist_file = root_path + "/etc/lsb-release";
		var f = File.new_for_path(dist_file);
		if (f.query_exists()){

			/*
				DISTRIB_ID=Ubuntu
				DISTRIB_RELEASE=13.04
				DISTRIB_CODENAME=raring
				DISTRIB_DESCRIPTION="Ubuntu 13.04"
			*/

			foreach(string line in file_read(dist_file).split("\n")){

				if (line.split("=").length != 2){ continue; }

				string key = line.split("=")[0].strip();
				string val = line.split("=")[1].strip();

				if (val.has_prefix("\"")){
					val = val[1:val.length];
				}

				if (val.has_suffix("\"")){
					val = val[0:val.length-1];
				}

				switch (key){
					case "DISTRIB_ID":
						info.dist_id = val;
						break;
					case "DISTRIB_RELEASE":
						info.release = val;
						break;
					case "DISTRIB_CODENAME":
						info.codename = val;
						break;
					case "DISTRIB_DESCRIPTION":
						info.description = val;
						break;
				}
			}
		}
		else{

			dist_file = root_path + "/etc/os-release";
			f = File.new_for_path(dist_file);
			if (f.query_exists()){

				/*
					NAME="Ubuntu"
					VERSION="13.04, Raring Ringtail"
					ID=ubuntu
					ID_LIKE=debian
					PRETTY_NAME="Ubuntu 13.04"
					VERSION_ID="13.04"
					HOME_URL="http://www.ubuntu.com/"
					SUPPORT_URL="http://help.ubuntu.com/"
					BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
				*/

				foreach(string line in file_read(dist_file).split("\n")){

					if (line.split("=").length != 2){ continue; }

					string key = line.split("=")[0].strip();
					string val = line.split("=")[1].strip();

					switch (key){
						case "ID":
							info.dist_id = val;
							break;
						case "VERSION_ID":
							info.release = val;
							break;
						//case "DISTRIB_CODENAME":
							//info.codename = val;
							//break;
						case "PRETTY_NAME":
							info.description = val;
							break;
					}
				}
			}
		}

		return info;
	}

	public static string get_running_desktop_name(){

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

	public string dist_type {

		owned get{

			if (dist_id == "fedora"){
				return "redhat";
			}
			else if (dist_id.down().contains("manjaro") || dist_id.down().contains("arch")){
				return "arch";
			}
			else if (dist_id.down().contains("ubuntu") || dist_id.down().contains("debian")){
				return "debian";
			}
			else{
				return "";
			}

		}
	}
}



