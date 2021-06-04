/* FileItem.vala
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

using GLib;
using Gee;
using Json;

using Graceful.Logging;
using Graceful.FileSystem;
using Graceful.JsonHelper;
using Graceful.ProcessHelper;
using Graceful.System;
using Graceful.Misc;

public class FileItem : GLib.Object,Gee.Comparable<FileItem>
{

	public string file_name = "";
	public string file_location = "";
	public string file_path = "";
	public string file_path_prefix = "";
	public FileType file_type = FileType.REGULAR;
	public DateTime modified;
	public string permissions = "";
	public string owner_user = "";
	public string owner_group = "";
	public string content_type = "";
	public string file_status = "";

	public bool is_selected = false;
	public bool is_symlink = false;
	public string symlink_target = "";

	public long file_count = 0;
	public long dir_count = 0;
	private int64 _size = 0;

	public GLib.Icon icon;

	// contructors -------------------------------

	public FileItem(string name) {
		file_name = name;
	}

	public FileItem.from_disk_path_with_basic_info(string _file_path) {
		file_path = _file_path;
		file_name = file_basename(_file_path);
		file_location = file_parent(_file_path);
		query_file_info_basic();
	}

	public FileItem.from_path_and_type(string _file_path, FileType _file_type) {
		file_path = _file_path;
		file_name = file_basename(_file_path);
		file_location = file_parent(_file_path);
		file_type = _file_type;
	}

	// properties -------------------------------------------------

	public int64 size {
		get{
			return _size;
		}
	}

	// helpers ----------------------------------------------------

	public int compare_to(FileItem b){
		if (this.file_type != b.file_type) {
			if (this.file_type == FileType.DIRECTORY) {
				return -1;
			}
			else {
				return +1;
			}
		}
		else {
			//if (view.sort_column_desc) {
				return strcmp(this.file_name.down(), b.file_name.down());
			//}
			//else {
				//return -1 * strcmp(a.file_name.down(), b.file_name.down());
			//}
		}
	}

	// instance methods -------------------------------------------

	public void query_file_info() {

		try {
			FileInfo info;
			File file = File.parse_name (file_path);

			if (file.query_exists()) {

				// get type without following symlinks

				info = file.query_info("%s,%s,%s".printf(
				                           FileAttribute.STANDARD_TYPE,
				                           FileAttribute.STANDARD_ICON,
				                           FileAttribute.STANDARD_SYMLINK_TARGET),
										   FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

				var item_file_type = info.get_file_type();

				this.icon = info.get_icon();

				if (item_file_type == FileType.SYMBOLIC_LINK) {
					//this.icon = GLib.Icon.new_for_string("emblem-symbolic-link");
					this.is_symlink = true;
					this.symlink_target = info.get_symlink_target();
				}
				else {

					this.is_symlink = false;
					this.symlink_target = "";

					if (item_file_type == FileType.REGULAR){
						//log_msg(file_basename(file_path) + " (gicon): " + icon.to_string());

						/*var themed_icon = (GLib.ThemedIcon) icon;

						string txt = "-> ";
						foreach(var name in themed_icon.names){
							txt += ", " + name;
						}
						log_msg(txt);*/
					}
				}

				// get file info - follow symlinks

				info = file.query_info("%s,%s,%s,%s,%s,%s,%s,%s".printf(
				                           FileAttribute.STANDARD_TYPE,
				                           FileAttribute.STANDARD_SIZE,
				                           FileAttribute.STANDARD_ICON,
				                           FileAttribute.STANDARD_CONTENT_TYPE,
				                           FileAttribute.TIME_MODIFIED,
				                           FileAttribute.OWNER_USER,
				                           FileAttribute.OWNER_GROUP,
				                           FileAttribute.FILESYSTEM_FREE
				                           ), 0);

				if (this.is_symlink){
					// get icon for the resolved file
					this.icon = info.get_icon();
				}

				// file type resolved
				this.file_type = info.get_file_type();

				// content type
				this.content_type = info.get_content_type();

				// size
				if (!this.is_symlink && (this.file_type == FileType.REGULAR)) {
					this._size = info.get_size();
				}

				// modified
				this.modified = (new DateTime.from_timeval_utc(info.get_modification_time())).to_local();

				// owner_user
				this.owner_user = info.get_attribute_string(FileAttribute.OWNER_USER);

				// owner_group
				this.owner_group = info.get_attribute_string(FileAttribute.OWNER_GROUP);

			}
		}
		catch (Error e) {
			log_error (e.message);
		}
	}

	public void query_file_info_basic() {

		try {
			FileInfo info;
			File file = File.parse_name(file_path);

			if (file.query_exists()) {

				// get type and icon -- follow symlinks

				info = file.query_info("%s,%s".printf(
				                           FileAttribute.STANDARD_TYPE,
				                           FileAttribute.STANDARD_ICON
				                           ), 0);

				this.icon = info.get_icon();

				this.file_type = info.get_file_type();
			}
		}
		catch (Error e) {
			log_error (e.message);
		}
	}

	// icons ------------------------------------------------------

	public Gdk.Pixbuf? get_icon(int icon_size, bool add_transparency, bool add_emblems){

		Gdk.Pixbuf? pixbuf = null;

		if (icon != null) {
			pixbuf = IconManager.lookup_gicon(icon, icon_size);
		}

		if (pixbuf == null){
			if (file_type == FileType.DIRECTORY) {
				pixbuf = IconManager.lookup("folder", icon_size, false);
			}
			else{
				pixbuf = IconManager.lookup("text-x-preview", icon_size, false);
			}
		}

		return pixbuf;
	}
}

