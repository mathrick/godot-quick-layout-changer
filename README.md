This is a simple Godot 4 editor plugin to change editor layouts
directly from the toolbar, without going through the
Editor->Layouts->... menu.

![Screenshot of the plugin in action](screenshots/screenshot.png "Screenshot")

**WARNING**: This plugin is very hacky and relies on a lot of
internal details of how the editor works, since there's no official
API that would allow access to saved layouts. According to my testing
it _should_ be compatible with:

* Godot 4.2, should work for any language
* Godot 4.3, currently English only

If you run into problems, please open an issue, and I'll do my best to fix it.


