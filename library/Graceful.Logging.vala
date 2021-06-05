/* Graceful.Logging.vala
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

namespace Graceful.Logging
{
	/* Functions for logging messages to console and log files */

    using GLib.FileUtils;
    using GLib.DirUtils;
    using Graceful.Misc;

    public FileIOStream ios = null;
    public DataOutputStream dos_log = null;
    private string log_path;
    public string err_log;
    public bool LOG_ENABLE = true;
    public bool LOG_TIMESTAMP = true;
    public bool LOG_COLORS = true;
    public bool LOG_DEBUG = true;
    public bool LOG_COMMANDS = true;

     /**
     * @brif 输出日志到文件 <需要主函数里调用>
     * @param logDir 日志输出文件夹名
     * @param logFile 日志输出文件名
      */
     public void log_init (string logDir, string logFile)
     {
        string log_path = string.join("/", logDir, logFile);
        try {
	        create_with_parents (logDir, 0777);
	        File file = File.new_for_path (log_path);
	        if (FileUtils.test(log_path, FileTest.EXISTS)) {
	            FileUtils.remove (log_path);
	            }
	        ios = file.create_readwrite (FileCreateFlags.NONE);
	        dos_log = new DataOutputStream (ios.output_stream);
	    } catch (Error e) {
	        stderr.printf (_("create log file error:%s"), e.message);
	     }
	}

    public void log_msg (string message, bool highlight = true)
	{
		if (!LOG_ENABLE) { return; }

		string msg = "";

		if (highlight && LOG_COLORS){
			msg += "\033[1;38;5;34m";
		}

		if (LOG_TIMESTAMP){
			msg += "[" + timestamp(true) +  "] ";
		}

		msg += message;

		if (highlight && LOG_COLORS){
			msg += "\033[0m";
		}

		msg += "\n";

		stdout.printf (msg);
		stdout.flush();

		try {
			if (dos_log != null){
				dos_log.put_string ("[%s] %s\n".printf(timestamp(), message));
			}
		} catch (Error e) {
			stdout.printf (e.message);
		}
	}

	public void log_error (string message, bool highlight = false, bool is_warning = false)
	{
		if (!LOG_ENABLE) { return; }

		string msg = "";

		if (highlight && LOG_COLORS){
			msg += "\033[1;38;5;160m";
		}

		if (LOG_TIMESTAMP){
			msg += "[" + timestamp(true) +  "] ";
		}

		string prefix = (is_warning) ? "W" : "E";

		msg += prefix + ": " + message;

		if (highlight && LOG_COLORS){
			msg += "\033[0m";
		}

		msg += "\n";

		stdout.printf (msg);
		stdout.flush();

		try {
			string str = "[%s] %s: %s\n".printf(timestamp(), prefix, message);

			if (dos_log != null){
				dos_log.put_string (str);
			}

			if (err_log != null){
				err_log += "%s\n".printf(message);
			}
		} catch (Error e) {
			stdout.printf (e.message);
		}
	}

	public void log_debug (string message)
	{
		if (!LOG_ENABLE) {
		    return;
		}

		if (LOG_DEBUG) {
			log_msg ("D: " + message);
		}
	}

	public void log_to_file (string message, bool highlight = false)
	{
		try {
			if (dos_log != null){
				dos_log.put_string ("[%s] %s\n".printf(timestamp(), message));
			}
		} catch (Error e) {
			stdout.printf (e.message);
		}
	}

	public void log_draw_line()
	{
		log_msg(string.nfill(70,'='));
	}

	public void show_err_log(Gtk.Window parent, bool disable_log = true)
	{

		if (disable_log) {
			err_log_disable();
		}
	}

	public void err_log_clear()
	{
		err_log = "";
	}

	public void err_log_disable()
	{
		err_log = null;
	}
}
