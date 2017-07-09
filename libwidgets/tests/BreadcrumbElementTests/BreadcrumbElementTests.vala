/*
* Copyright (c) 2017 elementary LLC
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation, Inc.,; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
* MA 02110-1335 USA.
*
* Authored by: Jeremy Wootten <jeremy@elementaryos.org>
*/

const string TEST_NAME = "#test? \name&_漢字"; /* This should be most problematic name possible */
const string TEST_ICON_NAME = "folder-documents-symbolic.svg";

void add_breadcrumb_element_tests () {
    Test.add_func ("/BreadcrumbElement/escaped_name", breadcrumb_escaped_name_test);
    Test.add_func ("/BreadcrumbElement/unescaped_name", breadcrumb_unescaped_name_test);
    Test.add_func ("/BreadcrumbElement/no_name", breadcrumb_no_name_test);
    Test.add_func ("/BreadcrumbElement/icon", breadcrumb_icon_test);
}

/*** Test functions ***/
void breadcrumb_escaped_name_test () {
    Test.log_set_fatal_handler (fatal_handler);

    string name = Uri.escape_string (TEST_NAME);
    var bce = make_breadcrumb_element (name);

    assert (bce != null);
    assert (bce.text_for_display == TEST_NAME);

    check_widths (bce, name);
}

void breadcrumb_unescaped_name_test () {
    Test.log_set_fatal_handler (fatal_handler);

    var bce = make_breadcrumb_element (TEST_NAME);

    assert (bce != null);
    assert (bce.text_for_display == TEST_NAME);

    check_widths (bce, TEST_NAME);
}

void breadcrumb_no_name_test () {
    Test.log_set_fatal_handler (fatal_handler);

    var bce = make_breadcrumb_element ("");

    assert (bce != null);
    assert (bce.text_for_display == "");
    assert (bce.display_width < 0);
    assert (bce.natural_width >= 0);
    assert (bce.real_width == bce.natural_width);

    bce.display_width = 5;
    assert (bce.real_width == bce.display_width);
}

void breadcrumb_icon_test () {
    Test.log_set_fatal_handler (fatal_handler);

    var bce = make_breadcrumb_element ("");
    int size = 16;
    Gdk.Pixbuf? pb = null;

    string test_file_path = Path.build_filename (Config.TESTDATA_DIR, "images", TEST_ICON_NAME);

    try {
        pb = new Gdk.Pixbuf.from_file_at_size (test_file_path, size, size);
    } catch (GLib.Error e) {
        warning ("Failed to get test pixbuf - %s", e.message);
        Test.fail ();
    }

    bce.set_icon (pb);
    assert (bce.icon_width == size);

    bce.set_icon (null);
    assert (bce.icon_width == 0);
}
/*** Helper functions ***/
Marlin.View.Chrome.BreadcrumbElement make_breadcrumb_element (string text) {
    Gtk.Widget w = new Gtk.Grid ();
    Gtk.StyleContext sc = w.get_style_context ();
    sc.add_class ("pathbar");

    return new Marlin.View.Chrome.BreadcrumbElement (text, w, sc);
}

void check_widths (Marlin.View.Chrome.BreadcrumbElement bce, string name) {
    assert (bce.display_width < 0);
    assert (bce.natural_width >= name.length);
    assert (bce.real_width == bce.natural_width);

    bce.display_width = bce.natural_width - 5;
    assert (bce.real_width == bce.display_width);
}

bool fatal_handler (string? log_domain, LogLevelFlags log_levels, string msg) {
    /* Do not fail on WARN messages or those issued by Gtk e.g. re theme parsing */
    return !(((log_levels & GLib.LogLevelFlags.LEVEL_WARNING) > 0) || (log_domain != null && log_domain.contains ("Gtk")));
}

int main (string[] args) {
    Test.log_set_fatal_handler (fatal_handler);

    Gtk.test_init (ref args);

    add_breadcrumb_element_tests ();
    return Test.run ();
}
