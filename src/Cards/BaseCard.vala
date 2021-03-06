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
 *  Copyright 2018 elementary, Inc. (https://elementary.io)
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public
 *  License along with this program; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 *
 *  Authors: Corentin Noël <corentin@elementary.io>
 */

public abstract class Greeter.BaseCard : Gtk.Revealer {
    public signal void do_connect (string? credential = null);

    public bool connecting { get; set; default = false; }
    public bool need_password { get; set; default = false; }
    public bool use_fingerprint { get; set; default = false; }

    construct {
        width_request = 350;
        reveal_child = true;
        transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        events |= Gdk.EventMask.BUTTON_RELEASE_MASK;

        notify["child-revealed"].connect (() => {
            if (!child_revealed) {
                visible = false;
            }
        });

        notify["reveal-child"].connect (() => {
            if (reveal_child) {
                visible = true;
            }
        });
    }

    public virtual void wrong_credentials () {}

}
