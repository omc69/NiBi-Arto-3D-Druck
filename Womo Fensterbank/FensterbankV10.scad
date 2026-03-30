//
// Wohnmobil-Fensterbank
// - Oben: Platte + optional umlaufender Rand
// - Unten: zwei Halterungen zum Aufstecken
// Alle Maße in mm
//

// Unterplatte
shelf_width        = 250;   // Breite (X)
shelf_depth        = 200;   // Tiefe (Y)
shelf_thickness    = 4;     // Dicke der Platte

// Umlaufender Rand auf der OBERSEITE
rim_enabled        = true;  // <<== Rand an/aus
rim_height         = 5;     // Höhe des Randes über der Platte
rim_width          = 5;     // Breite des Randes nach innen

// Fensterbank, auf die aufgeklipst wird
board_thickness    = 50;    // Abstand zwischen den INNENflächen der beiden Halter
fit_clearance      = 0.5;   // Spiel für die Klemmung

// Äußerer Halter (fensterseitig, UNTEN)
outer_br_height    = 40;    // Höhe unter der Platte
outer_br_thickness = 4;     // Dicke in Y

// Innerer Halter (raumseitig, UNTEN)
inner_br_height    = 30;    // Höhe unter der Platte
inner_br_thickness = 3;     // Dicke in Y


// ---------- Module ----------

// Grundplatte + optionaler Rand oben
module base_plate_with_rim() {

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
