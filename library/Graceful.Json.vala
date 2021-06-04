/* Graceful.Json.vala
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

namespace Graceful.JsonHelper
{
	using Graceful.Logging;

	/* Convenience functions for reading and writing JSON files */

	public string json_get_string(Json.Object jobj, string member, string def_value)
	{
		if (jobj.has_member(member)){
			return jobj.get_string_member(member);
		} else {
			log_debug ("Member not found in JSON object: " + member);
			return def_value;
		}
	}

	public double json_get_double(Json.Object jobj, string member, double def_value)
	{
		var text = json_get_string(jobj, member, def_value.to_string());
		double double_value;
		if (double.try_parse(text, out double_value)){
			return double_value;
		} else {
			return def_value;
		}
	}

	public bool json_get_bool(Json.Object jobj, string member, bool def_value)
	{
		if (jobj.has_member(member)){
			return bool.parse(jobj.get_string_member(member));
		} else {
			log_debug ("Member not found in JSON object: " + member);
			return def_value;
		}
	}

	public int json_get_int(Json.Object jobj, string member, int def_value)
	{
		if (jobj.has_member(member)){
			return int.parse(jobj.get_string_member(member));
		} else {
			log_debug ("Member not found in JSON object: " + member);
			return def_value;
		}
	}

	public uint64 json_get_uint64(Json.Object jobj, string member, uint64 def_value)
	{
		if (jobj.has_member(member)){
			return uint64.parse(jobj.get_string_member(member));
		} else {
			log_debug ("Member not found in JSON object: " + member);
			return def_value;
		}
	}

	public Gee.ArrayList<string> json_get_array(Json.Object jobj, string member, Gee.ArrayList<string> def_value)
	{
		if (jobj.has_member(member)){
			var jarray = jobj.get_array_member(member);
			var list = new Gee.ArrayList<string>();
			foreach(var node in jarray.get_elements()){
				list.add(node.get_string());
			}
			return list;
		}
		else{
			log_debug ("Member not found in JSON object: " + member);
			return def_value;
		}
	}
}
