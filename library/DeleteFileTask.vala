/* DeleteFileTask.vala
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
using Graceful.JsonHelper;
using Graceful.ProcessHelper;
using Graceful.System;
using Graceful.Misc;

public class DeleteFileTask : AsyncTask
{
	// settings
	public string dest_path = "";
	public bool verbose = true;
	public bool io_nice = true;
	public bool use_rsync = false;

	//private
	private string source_path = "";

	// regex
	private Gee.HashMap<string, Regex> regex_list;

	// status
	public int64 status_line_count = 0;
	public int64 total_size = 0;
	public string status_message = "";
	public string time_remaining = "";

	public DeleteFileTask(){
		init_regular_expressions();
	}

	private void init_regular_expressions(){
		if (regex_list != null){
			return; // already initialized
		}

		regex_list = new Gee.HashMap<string,Regex>();

		try {

			regex_list["rsync-deleted"] = new Regex(
				"""\*deleting[ \t]+(.*)""");

		}
		catch (Error e) {
			log_error (e.message);
		}
	}

	public void prepare() {
		string script_text = build_script();
		log_debug(script_text);
		save_bash_script_temp(script_text, script_file);

		log_debug("RsyncTask:prepare(): saved: %s".printf(script_file));

		status_line_count = 0;
		total_size = 0;
	}

	private string build_script() {
		var cmd = "";

		if (io_nice){
			//cmd += "ionice -c2 -n7 ";
		}

		if (use_rsync){

			cmd += "rsync -aii";

			if (verbose){
				cmd += " --verbose";
			}
			else{
				cmd += " --quiet";
			}

			cmd += " --delete";

			cmd += " --stats --relative";

			source_path = "/tmp/%s_empty".printf(random_string());
			dir_create(source_path);

			source_path = remove_trailing_slash(source_path);
			dest_path = remove_trailing_slash(dest_path);

			cmd += " '%s/'".printf(escape_single_quote(source_path));
			cmd += " '%s/'".printf(escape_single_quote(dest_path));
		}
		else{
			cmd += "rm";

			if (verbose){
				cmd += " -rfv";
			}
			else{
				cmd += " -rf";
			}

			cmd += " '%s'".printf(escape_single_quote(dest_path));
		}

		return cmd;
	}

	// execution ----------------------------

	public void execute() {

		status = AppStatus.RUNNING;

		log_debug("RsyncTask:execute()");

		prepare();

		begin();

		if (status == AppStatus.RUNNING){


		}
	}

	public override void parse_stdout_line(string out_line){
		if (is_terminated) {
			return;
		}

		update_progress_parse_console_output(out_line);
	}

	public override void parse_stderr_line(string err_line){
		if (is_terminated) {
			return;
		}

		update_progress_parse_console_output(err_line);
	}

	public bool update_progress_parse_console_output (string line) {
		if ((line == null) || (line.length == 0)) {
			return true;
		}

		status_line_count++;

		if (prg_count_total > 0){
			prg_count = status_line_count;
			progress = (prg_count * 1.0) / prg_count_total;
		}

		MatchInfo match;
		if (regex_list["rsync-deleted"].match(line, 0, out match)) {

			//log_debug("matched: rsync-deleted:%s".printf(line));

			status_line = match.fetch(1).split(" -> ")[0].strip();
		}
		else {

			//log_debug("matched: else:%s".printf(line));

			status_line = line.strip();
		}

		return true;
	}

	protected override void finish_task(){
		if ((status != AppStatus.CANCELLED) && (status != AppStatus.PASSWORD_REQUIRED)) {
			status = AppStatus.FINISHED;
		}
	}

	public int read_status(){
		var status_file = working_dir + "/status";
		var f = File.new_for_path(status_file);
		if (f.query_exists()){
			var txt = file_read(status_file);
			return int.parse(txt);
		}
		return -1;
	}
}

