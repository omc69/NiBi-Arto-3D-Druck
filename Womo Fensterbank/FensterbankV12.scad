// BOSL2 für sauberes Rounding
include <BOSL2/std.scad>;

//
// Wohnmobil-Fensterbank
// - Oben: Platte + optional umlaufender Rand + BOSL2-Rundung oben an allen 4 Außenkanten
// - Oben: optional Anti-Rutsch-Rifflung auf der Grundfläche
// - Unten: zwei Halterungen zum Aufstecken
// Alle Maße in mm
//

// Unterplatte
shelf_width        = 250;   // Breite (X)
shelf_depth        = 200;   // Tiefe (Y)
shelf_thickness    = 4;     // Dicke der Platte

// Umlaufender Rand auf der OBERSEITE
rim_enabled        = true;  // Rand an/aus
rim_height         = 5;     // Höhe des Randes über der Platte
rim_width          = 5;     // Breite des Randes nach innen

// BOSL2-Rundung (oben außen)
front_radius       = 6;     // 0 = keine Rundung, >0 = Radius an allen oberen Außenkanten

// Fensterbank, auf die aufgeklippt wird
board_thickness    = 50;    // Abstand zwischen den INNENflächen der beiden Halter
fit_clearance      = 0.5;   // Spiel für die Klemmung

// Äußerer Halter (fensterseitig, UNTEN)
outer_br_height    = 40;    // Höhe unter der Platte
outer_br_thickness = 4;     // Dicke in Y

// Innerer Halter (raumseitig, UNTEN)
inner_br_height    = 30;    // Höhe unter der Platte
inner_br_thickness = 3;     // Dicke in Y

// Anti-Rutsch-Rifflung
anti_slip_enabled    = true;  // Anti-Rutsch an/aus
anti_ridge_height    = 1.0;   // Höhe der Rillen über der Grundfläche
anti_ridge_width     = 3.0;   // Breite einer Rille in Y-Richtung
anti_ridge_spacing   = 8.0;   // Abstand von Rillenmitte zu Rillenmitte in Y-Richtung
anti_ridge_margin    = 3.0;   // Abstand zur Innenkante des Randes bzw. Plattenrand


// ---------- Module ----------

// Grundplatte + optionaler Rand oben (ohne BOSL-Rundung)
module flat_base_with_rim() {

    // Platte: z = 0 .. shelf_thickness  (OBERSEITE = z = shelf_thickness)
    cube([shelf_width, shelf_depth, shelf_thickness], center = false);

    // Rand auf der Oberseite (nur wenn aktiviert)
    if (rim_enabled && rim_height > 0 && rim_width > 0) {
        difference() {
            // äußerer Block für den Rand
            translate([0, 0, shelf_thickness])
                cube([shelf_width, shelf_depth, rim_height], center = false);

            // Innenbereich ausschneiden, damit nur der Ring stehen bleibt
            translate([rim_width,
                       rim_width,
                       shelf_thickness - 0.1])   // leicht überlappend, kein Spalt
                cube([shelf_width - 2*rim_width,
                      shelf_depth - 2*rim_width,
                      rim_height + 0.2], center = false);
        }
    }
}

// Anti-Rutsch-Rifflung auf der Grundfläche (oberhalb der Platte)
module anti_slip_pattern() {
    if (anti_slip_enabled) {

        // Oberseite der Platte
        top_z = shelf_thickness;

        // Innenbereich definieren:
        // - Wenn Rand aktiv: innerhalb des Randes
        // - Wenn kein Rand: gesamte Platte
        inner_x0 = rim_enabled ? rim_width : 0;
        inner_x1 = rim_enabled ? (shelf_width  - rim_width)  : shelf_width;
        inner_y0 = rim_enabled ? rim_width : 0;
        inner_y1 = rim_enabled ? (shelf_depth - rim_width) : shelf_depth;

        inner_width  = inner_x1 - inner_x0;
        inner_depth  = inner_y1 - inner_y0;

        // Nur Rifflung, wenn genug Platz vorhanden ist
        if (inner_width > 2*anti_ridge_margin && inner_depth > 2*anti_ridge_margin) {

            start_y = inner_y0 + anti_ridge_margin;
            end_y   = inner_y1 - anti_ridge_margin;

            for (y = [start_y : anti_ridge_spacing : end_y]) {
                translate([inner_x0 + anti_ridge_margin,
                           y - anti_ridge_width/2,
                           top_z])
                    cube([
                        inner_width - 2*anti_ridge_margin,
                        anti_ridge_width,
                        anti_ridge_height
                    ], center = false);
            }
        }
    }
}

// Grundplatte + Rand + BOSL2-Rundung an allen oberen Außenkanten
module base_plate_with_rim() {

    // Gesamthöhe Platte + Rand
    H = shelf_thickness + (rim_enabled ? rim_height : 0);

    // Fall 1: Rand aus oder kein Radius -> Original + Rifflung
    if (!rim_enabled || front_radius <= 0) {
        flat_base_with_rim();
        anti_slip_pattern();
    }

    // Fall 2: Rand an + Radius > 0 -> BOSL2 cuboid als Außenform
    else {
        difference() {
            // ÄUSSERE Hülle: Platte + Rand als ein Körper
            // -> alle oberen Außenkanten (Front/Back/Links/Rechts) werden gerundet
            //
            // cuboid ist zentriert, wir verschieben ihn so,
            // dass seine Unterseite bei z=0, Rückseite bei y=0, linke Seite bei x=0 liegt.
            translate([shelf_width/2, shelf_depth/2, H/2])
                cuboid(
                    [shelf_width, shelf_depth, H],
                    rounding = front_radius,
                    // alle oberen Außenkanten: TOP mit FRONT, BACK, LEFT, RIGHT
                    edges    = TOP+FRONT+BACK+LEFT+RIGHT
                );

            // Innenbereich des Randes wegschneiden:
            // - von rim_width zu allen Seiten
            // - nur im oberen Bereich über der Platte (ab z = shelf_thickness)
            translate([rim_width, rim_width, shelf_thickness])
                cube([
                    shelf_width  - 2*rim_width,
                    shelf_depth  - 2*rim_width,
                    rim_height + 0.2
                ], center = false);
        }

        // Rifflung nachträglich oben in den Innenbereich einfügen
        anti_slip_pattern();
    }
}

// Halterungen auf der UNTERSEITE
module brackets() {
    // y = 0: Rückkante der neuen Fensterbank

    // äußerer Halter (direkt an der Rückkante, nach UNTEN)
    translate([0, 0, -outer_br_height])
        cube([shelf_width, outer_br_thickness, outer_br_height], center = false);

    // innerer Halter
    translate([0,
               outer_br_thickness + board_thickness + fit_clearance,
               -inner_br_height])
        cube([shelf_width, inner_br_thickness, inner_br_height], center = false);
}

module fensterbank() {
    base_plate_with_rim();
    brackets();
}

// Aufruf
fensterbank();
