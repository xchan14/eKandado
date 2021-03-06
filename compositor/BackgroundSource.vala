/*
 * Portico
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 *
 * This file incorporates work licensed under the following notice:
 *  Copyright (C) 2014 Tom Beckmann
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace GreeterCompositor {
    public class BackgroundSource : Object {
        public signal void changed ();

#if HAS_MUTTER330
        public Meta.Display display { get; construct; }
#else
        public Meta.Screen screen { get; construct; }
#endif
        public Settings settings { get; construct; }

        internal int use_count { get; set; default = 0; }

        Gee.HashMap<int,Background> backgrounds;

#if HAS_MUTTER330
        public BackgroundSource (Meta.Display display, string settings_schema) {
            Object (display: display, settings: new Settings (settings_schema));
        }
#else
        public BackgroundSource (Meta.Screen screen, string settings_schema) {
            Object (screen: screen, settings: new Settings (settings_schema));
        }
#endif

        construct {
            backgrounds = new Gee.HashMap<int,Background> ();

#if HAS_MUTTER330
            Meta.MonitorManager.@get ().monitors_changed.connect (monitors_changed);
#else
            screen.monitors_changed.connect (monitors_changed);
#endif

            settings_hash_cache = get_current_settings_hash_cache ();
            settings.changed.connect (settings_changed);
        }

        void monitors_changed () {
#if HAS_MUTTER330
            var n = display.get_n_monitors ();
#else
            var n = screen.get_n_monitors ();
#endif
            var i = 0;

            foreach (var background in backgrounds.values) {
                if (i++ < n) {
                    background.update_resolution ();
                    continue;
                }

                background.changed.disconnect (background_changed);
                background.destroy ();
                // TODO can we remove from a list while iterating?
                backgrounds.unset (i);
            }
        }

        public Background get_background (int monitor_index) {
            string? filename = null;

            var style = settings.get_enum ("picture-options");
            if (style != GDesktop.BackgroundStyle.NONE) {
                var uri = settings.get_string ("picture-uri");
                if (Uri.parse_scheme (uri) != null)
                    filename = File.new_for_uri (uri).get_path ();
                else
                    filename = uri;
            }

            // Animated backgrounds are (potentially) per-monitor, since
            // they can have variants that depend on the aspect ratio and
            // size of the monitor; for other backgrounds we can use the
            // same background object for all monitors.
            if (filename == null || !filename.has_suffix (".xml"))
                monitor_index = 0;

            if (!backgrounds.has_key (monitor_index)) {
#if HAS_MUTTER330
                var background = new Background (display, monitor_index, filename, this, (GDesktop.BackgroundStyle) style);
#else
                var background = new Background (screen, monitor_index, filename, this, (GDesktop.BackgroundStyle) style);
#endif
                background.changed.connect (background_changed);
                backgrounds[monitor_index] = background;
            }

            return backgrounds[monitor_index];
        }

        void background_changed (Background background) {
            background.changed.disconnect (background_changed);
            background.destroy ();
            backgrounds.unset (background.monitor_index);
        }

        public void destroy () {
#if HAS_MUTTER330
            Meta.MonitorManager.@get ().monitors_changed.disconnect (monitors_changed);
#else
            screen.monitors_changed.disconnect (monitors_changed);
#endif

            foreach (var background in backgrounds.values) {
                background.changed.disconnect (background_changed);
                background.destroy ();
            }
        }

        // unfortunately the settings sometimes tend to fire random changes even though
        // nothing actually happend. The code below is used to prevent us from spamming
        // new actors all the time, which lead to some problems in other areas of the code

        // helper struct which stores the hash values generated by g_variant_hash
        struct SettingsHashCache {
            uint color_shading_type;
            uint picture_opacity;
            uint picture_options;
            uint picture_uri;
            uint primar_color;
            uint secondary_color;
        }

        SettingsHashCache settings_hash_cache;

        // list of keys that are actually relevant for us
        const string[] options = { "color-shading-type", "picture-opacity",
                "picture-options", "picture-uri", "primary-color", "secondary-color" };

        void settings_changed (string key) {
            if (!(key in options))
                return;

            var current = get_current_settings_hash_cache ();

            if (Memory.cmp (&settings_hash_cache, &current, sizeof (SettingsHashCache)) == 0) {
                return;
            }

            Memory.copy (&settings_hash_cache, &current, sizeof (SettingsHashCache));

            changed ();
        }

        SettingsHashCache get_current_settings_hash_cache () {
            return {
                settings.get_value ("color-shading-type").hash (),
                settings.get_value ("picture-opacity").hash (),
                settings.get_value ("picture-options").hash (),
                settings.get_value ("picture-uri").hash (),
                settings.get_value ("primary-color").hash (),
                settings.get_value ("secondary-color").hash ()
            };
        }
    }
}
