/* CryptTabEntry.vala
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

using Graceful.Misc;
using Graceful.System;
using Graceful.Logging;
using Graceful.FileSystem;
using Graceful.JsonHelper;
using Graceful.ProcessHelper;

public class CryptTabEntry : GLib.Object
{
	public bool is_comment = false;
	public bool is_empty_line = false;

	// fields
	public string mapped_name = "";
	public string device_string = "";
	public string keyfile = "none";
	public string options = "luks,nofail";
	public string line = "";

	public string device_uuid {
		owned get{
			if (device_string.down().has_prefix("uuid=")){
				return device_string.replace("\"","").replace("'","").split("=")[1];
			}
			else{
				return "";
			}
		}
		set {
			device_string = "UUID=%s".printf(value);
		}
	}

	public static Gee.ArrayList<CryptTabEntry> read_file(string file_path){

		var list = new Gee.ArrayList<CryptTabEntry>();

		if (!file_exists(file_path)){ return list; }

		string text = file_read(file_path);
		string[] lines = text.split("\n");
		foreach(string line in lines){
			var entry = new CryptTabEntry();
			list.add(entry);

			entry.is_comment = line.strip().has_prefix("#");
			entry.is_empty_line = (line.strip().length == 0);

			if (entry.is_comment){
				entry.line = line;
			}
			else if (entry.is_empty_line){
				entry.line = "";
			}
			else{
				entry.line = line;

				string[] parts = line.replace("\t"," ").split(" ");
				int part_num = -1;
				foreach(string part in parts){
					if (part.strip().length == 0) { continue; }
					switch (++part_num){
						case 0:
							entry.mapped_name = part.strip();
							break;
						case 1:
							entry.device_string = part.strip();
							break;
						case 2:
							entry.keyfile = part.strip();
							break;
						case 3:
							entry.options = part.strip();
							break;
					}
				}
			}
		}

		return list;
	}

	public static string write_file(Gee.ArrayList<CryptTabEntry> entries, string file_path, bool keep_comments_and_empty_lines = true){

		string text = "";
		foreach(var entry in entries){
			if (entry.is_comment || entry.is_empty_line){
				if (keep_comments_and_empty_lines){
					text += "%s\n".printf(entry.line);
				}
			}
			else {
				text += "%s\t%s\t%s\t%s\n".printf(
					entry.mapped_name, entry.device_string,
					entry.keyfile, entry.options);
			}
		}

		if (file_exists(file_path)){
			file_delete(file_path);
		}

		file_write(file_path, text);

		return text;
	}

	public void append_option(string option){

		if (!options.contains(option)){
			options += ",%s".printf(option);
		}

		if(options.has_prefix(",")){
			options = options[1:options.length];
		}

		options = options.strip();
	}

	public void remove_option(string option){

		options = options.replace(option,"").strip();

		if(options.has_prefix(",")){
			options = options[1:options.length];
		}

		if (options.has_suffix(",")){
			options = options[0:options.length - 1];
		}

		options = options.strip();
	}

	public static CryptTabEntry? find_entry_by_uuid(
		Gee.ArrayList<CryptTabEntry> entries, string uuid){

		foreach(var entry in entries){
			if (entry.device_uuid == uuid){
				return entry;
			}
		}

		return null;
	}
}

