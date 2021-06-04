/* MountEntry.vala
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

using Json;
using Graceful.Misc;
using Graceful.System;
using Graceful.Logging;
using Graceful.FileSystem;
using Graceful.JsonHelper;
using Graceful.ProcessHelper;

public class MountEntry : GLib.Object
{

	public Device device = null;
	public string mount_point = "";
	public string mount_options = "";

	public MountEntry(Device? device, string mount_point, string mount_options){

		this.device = device;
		this.mount_point = mount_point;
		this.mount_options = mount_options;
	}

	public string subvolume_name(){

		if (mount_options.contains("subvol=")){

			string txt = mount_options.split("subvol=")[1].split(",")[0].strip();

			if (txt.has_prefix("/") && (txt.split("/").length == 2)){
				txt = txt.split("/")[1];
			}

			return txt;
		}
		else{
			return "";
		}
	}

	public string lvm_name(){

		if ((device != null) && (device.type == "lvm") && (device.mapped_name.length > 0)){
			return device.mapped_name.strip();
		}
		else{
			return "";
		}
	}

	public static MountEntry? find_entry_by_mount_point(Gee.ArrayList<MountEntry> entries, string mount_path){

		foreach(var entry in entries){
			if (entry.mount_point == mount_path){
				return entry;
			}
		}

		return null;
	}
}

