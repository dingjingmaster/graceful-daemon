/* OSDNotify.vala
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

// dep: notify-send
public class OSDNotify : GLib.Object
{

	private static DateTime dt_last_notification = null;
	public const int NOTIFICATION_INTERVAL = 3;

	public static int notify_send (
		string title, string message, int durationMillis,
		string urgency = "low", // low, normal, critical
		string dialog_type = "info" //error, info, warning
		){

		/* Displays notification bubble on the desktop */

		int retVal = 0;

		switch (dialog_type){
			case "error":
			case "info":
			case "warning":
				//ok
				break;
			default:
				dialog_type = "info";
				break;
		}

		long seconds = 9999;

		if (dt_last_notification != null){

			DateTime dt_end = new DateTime.now_local();
			TimeSpan elapsed = dt_end.difference(dt_last_notification);
			seconds = (long)(elapsed * 1.0 / TimeSpan.SECOND);
		}

		if (seconds > NOTIFICATION_INTERVAL){

			if (cmd_exists("notify-send")){

				string desktop_entry = "timeshift-gtk";
				string hint = "string:desktop-entry:%s".printf(desktop_entry);

				string s = "notify-send -t %d -u %s -i %s \"%s\" \"%s\" -h %s".printf(
					durationMillis, urgency, "gtk-dialog-" + dialog_type, title, message, hint);

				retVal = exec_sync (s, null, null);

				dt_last_notification = new DateTime.now_local();
			}
		}

		return retVal;
	}

	public static bool is_supported(){

		string path = get_cmd_path("notify-send");

		return (path != null) && (path.length > 0);
	}
}

