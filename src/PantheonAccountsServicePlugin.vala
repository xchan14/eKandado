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

[DBus (name = "io.elementary.pantheon.AccountsService")]
interface Pantheon.AccountsService : Object {
    public abstract string time_format { owned get; set; }

    [DBus (name = "SleepInactiveACTimeout")]
    public abstract int sleep_inactive_ac_timeout { get; set; }
    [DBus (name = "SleepInactiveACType")]
    public abstract int sleep_inactive_ac_type { get; set; }

    public abstract int sleep_inactive_battery_timeout { get; set; }
    public abstract int sleep_inactive_battery_type { get; set; }
}
