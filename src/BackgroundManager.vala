/*
 * Portico
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 *
 * This file incorporates work licensed under the following notice:
 *
 */

namespace Greeter.Services {
    public enum BackgroundState {
        LIGHT,
        DARK
    }

    [DBus (name = "org.pantheon.gala.WingpanelInterface")]
    public interface InterfaceBus : Object {
        public signal void state_changed (BackgroundState state, uint animation_duration);

        public abstract void initialize (int monitor, int panel_height) throws GLib.Error;
        public abstract void remember_focused_window () throws GLib.Error;
        public abstract void restore_focused_window () throws GLib.Error;
        public abstract bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) throws GLib.Error;

    }

    public class BackgroundManager : Object {
        private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
        private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

        private static BackgroundManager? instance = null;

        private InterfaceBus? bus = null;

        private BackgroundState current_state = BackgroundState.LIGHT;

        private bool bus_available {
            get {
                return bus != null;
            }
        }

        private int monitor;
        private int panel_height;

        public signal void background_state_changed (BackgroundState state, uint animation_duration);

        public static void initialize (int monitor, int panel_height) {
            var manager = BackgroundManager.get_default ();
            manager.monitor = monitor;
            manager.panel_height = panel_height;
        }

        public static BackgroundManager get_default () {
            if (instance == null) {
                instance = new BackgroundManager ();
            }

            return instance;
        }

        private BackgroundManager () {
            Bus.watch_name (BusType.SESSION, DBUS_NAME, BusNameWatcherFlags.NONE,
                            () => connect_dbus (),
                            () => bus = null);
        }

        private bool connect_dbus () {
            try {
                bus = Bus.get_proxy_sync (
                    BusType.SESSION, DBUS_NAME, DBUS_PATH
                    );
                bus.initialize (monitor, panel_height);
            } catch (Error err) {
                warning (@"Connecting to $(DBUS_NAME) failed: $(err.message)");
                return false;
            }

            bus.state_changed.connect ((state, animation_duration) => {
                background_state_changed (state, animation_duration);
            });

            state_updated ();

            return true;
        }

        private void state_updated (uint animation_duration = 0) {
            background_state_changed (current_state, animation_duration);
        }

    }
}
