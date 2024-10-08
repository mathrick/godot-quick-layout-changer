This is a simple Godot 4 editor plugin to change editor layouts
directly from the toolbar, without going through the
Editor->Layouts->... menu.

<!--- changelog: 3
      heading: Changes -->

![Screenshot of the plugin in action](screenshots/screenshot.png "Screenshot")

Since version 1.3.0, the quick layout menu itself is localised in
several languages (if running on Godot 4.3+).

![Screenshot of localised layou menu](screenshots/localisation.png "Screenshot")

**WARNING**: This plugin is very hacky and relies on a lot of
internal details of how the editor works, since there's no official
API that would allow access to saved layouts. According to my testing
it _should_ be compatible with:

* Godot 4.2, should work for any language
* Godot 4.3, should work with any language supported by
  4.3.stable. As it currently requires manual syncing of
  translations, any changed or added translations in
  subsequent Godot releases will not be picked up
  automatically and will need a new release of the plugin

If you run into any problems, please open an issue, and I'll do my best to fix it.


