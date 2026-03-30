// BOSL2 für sauberes Rounding
include <BOSL2/std.scad>;

//
// Wohnmobil-Fensterbank
// - Oben: Platte + optional umlaufender Rand + BOSL2-Rundung oben an allen 4 Außenkanten
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

// Grundplatte + Rand + BOSL2-Rundung an allen oberen Außenkanten
module base_plate_with_rim() {

    // Gesamthöhe Platte + Rand
    H = shelf_thickness + (rim_enabled ? rim_height : 0);

    // Fall 1: Rand aus oder kein Radius -> exakt dein Original
    if (!rim_enabled || front_radius <= 0) {
        flat_base_with_rim();
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
