//
// Wohnmobil-Fensterbank
// Parametrisches Modell mit optionaler Lilien-Dekoration (STL-Import)
//

// ----------------------------------------------------------------------
// --- PARAMETER ---
// ----------------------------------------------------------------------

/* [A. GRUNDDIMENSIONEN PLATTE] */
// Breite (X)
01_shelf_width     = 150;   // [50:1:500]
// Tiefe (Y)
01_shelf_depth     = 100;   // [50:1:300]
// Dicke der Platte (Z)
01_shelf_thickness = 4;     // [2:0.5:10]

/* [B. KANTEN & VERFEINERUNG] */
// Radius der Abrundung (Vorder- und Seitenkanten)
02_front_radius    = 5;     // [0:0.5:10]

/* [C. ANTI-RUTSCH RILLEN (Vertiefungen)] */
03_grooves_enabled = false;   // [false, true] EIN/AUS-Schalter
// Tiefe der Rille
03_groove_depth    = 0.5;   // [0.1:0.1:2]
// Breite der Rille (entlang Y)
03_groove_width_x  = 2;     // [0.5:0.5:5]
// Abstand der Rillen (Mitte zu Mitte in Y)
03_groove_spacing_y= 10;    // [5:1:30]
// Startposition in Y (vom hinteren Rand y=0)
03_groove_offset_y = 10;    // [0:1:50]

/* [D. KLEMMUNG / HALTERUNG] */
// Abstand zwischen den INNENflächen der Halter (zu greifendes Element)
04_board_thickness = 10;    // [10:1:100]
// Spiel für die Klemmung (Anpassung an Druckergenauigkeit)
04_fit_clearance   = 0.3;   // [0:0.05:1]

/* [E. HALTERUNGS-MASSE] */
// Dicke des äußeren Halters (Y)
05_outer_br_thickness = 4;   // [1:1:10]
// Höhe des äußeren Halters (Z)
05_outer_br_height    = 32;  // [10:1:100]
// Dicke des inneren Halters (Y)
05_inner_br_thickness = 3;   // [1:1:10]
// Höhe des inneren Halters (Z)
05_inner_br_height    = 32;  // [10:1:100]

/* [F. OPTIONALER RAND (Deaktiviert)] */
06_rim_enabled     = false;  // [false, true] Rand an/aus
// Breite / Dicke des Randes (X/Y)
06_rim_width       = 5;     // [1:1:10]
// Höhe des Randes nach unten (Z)
06_rim_height      = 5;     // [1:1:10]

/* [G. LILIEN-DEKORATION (STL-Import)] */
// Dateiname der STL (muss im selben Ordner liegen)
07_lily_file       = "lilie_only2.stl";
// EIN/AUS
07_lily_enabled    = true;   // [false, true]
// Modus: true = Gravur (eingesenkt), false = Relief (erhaben)
07_lily_engrave    = true;   // [false, true]
// Skalierung gleichmäßig (XYZ)
07_lily_scale      = 1.0;   // [0.1:0.05:5.0]
// Position X (von links, Mitte der Lilie)
07_lily_pos_x      = 103;   // [0:1:500]
// Position Y (von hinten, Mitte der Lilie)
07_lily_pos_y      = 65;    // [0:1:300]
// Gravurtiefe (nur bei Gravur-Modus, wie tief wird sie gefräst)
07_lily_engrave_depth = 1.0; // [0.2:0.1:3.0]
// Z-Höhe des Reliefs über der Platte (nur bei Relief-Modus)
07_lily_relief_height = 1.5; // [0.2:0.1:5.0]
// Rotation der Lilie um Z-Achse (Grad)
07_lily_rotation   = 180;   // [0:5:360]

/* [H. TEXT-GRAVUR] */
// Text EIN/AUS
08_text_enabled    = true;          // [false, true]
// Der eigentliche Text
08_text_string     = "Kirstin & Christian";   // Freitext
// Schriftgröße (Höhe in mm)
08_text_size       = 6;             // [2:0.5:20]
// Schrift (muss auf dem System installiert sein)
08_text_font = "FreeSans:style=Bold"; // Freitext
// Gravurtiefe des Textes
08_text_depth      = 0.6;           // [0.2:0.1:2.0]
// Abstand Textmitte zur Lilien-Position in Y (negativ = darunter)
08_text_offset_y   = -58;           // [-80:1:80]
// Zusätzlicher Versatz in X (Feinkorrektur)
08_text_offset_x   = -29;             // [-100:1:100]
// Zeichenabstand (1.0 = Standard)
08_text_spacing    = 1.0;           // [0.5:0.05:2.0]
// Rotation des Textes um Z-Achse (Grad) // NEU
08_text_rotation   = 180;             // [0:5:360]


// ----------------------------------------------------------------------
// --- HILFSWERTE ---
// ----------------------------------------------------------------------

_lily_z_base = 01_shelf_thickness - 07_lily_engrave_depth;

// Textposition: relativ zur Lilien-Position
_text_pos_x  = 07_lily_pos_x + 08_text_offset_x;
_text_pos_y  = 07_lily_pos_y + 08_text_offset_y;
_text_z      = 01_shelf_thickness - 08_text_depth;


// ----------------------------------------------------------------------
// ---------- MODULE ----------
// ----------------------------------------------------------------------

// Lilien-Geometrie zentriert und positioniert
module lily_geometry() {
    translate([07_lily_pos_x, 07_lily_pos_y, 0])
    rotate([0, 0, 07_lily_rotation])
    scale([07_lily_scale, 07_lily_scale, 07_lily_scale])
    import(07_lily_file, convexity = 10);
}

// Lilien-Dekoration auf Platte (Gravur oder Relief)
module lily_decoration() {
    if (07_lily_enabled) {
        if (07_lily_engrave) {
            translate([0, 0, _lily_z_base])
                lily_geometry();
        } else {
            translate([0, 0, 01_shelf_thickness])
                lily_geometry();
        }
    }
}

// Text-Gravur
module text_engraving() {
    if (08_text_enabled) {
        translate([_text_pos_x, _text_pos_y, _text_z])
        rotate([0, 0, 08_text_rotation])  // NEU
        linear_extrude(height = 08_text_depth + 0.01)
            text(
                08_text_string,
                size    = 08_text_size,
                font    = 08_text_font,
                halign  = "center",
                valign  = "center",
                spacing = 08_text_spacing,
                $fn     = 32
            );
    }
}

// Modul zum Erstellen der Rillen (wird subtrahiert)
module anti_slip_grooves() {
    if (03_grooves_enabled) {
        num_grooves = floor((01_shelf_depth - 03_groove_offset_y) / 03_groove_spacing_y);
        for (i = [0 : 1 : num_grooves - 1]) {
            current_y     = 03_groove_offset_y + i * 03_groove_spacing_y;
            groove_start_x  = 02_front_radius;
            groove_length_x = 01_shelf_width - 2 * 02_front_radius;
            translate([groove_start_x, current_y, 01_shelf_thickness - 03_groove_depth])
                cube([groove_length_x, 03_groove_width_x, 03_groove_depth + 0.01], center = false);
        }
    }
}

// Grundplatte + optionaler Rim
module base_plate_with_rim() {
    difference() {
        union() {
            // a) Verrundeter Hauptteil
            translate([02_front_radius, 02_front_radius, 0])
            minkowski() {
                cube([01_shelf_width - 2*02_front_radius,
                      01_shelf_depth - 2*02_front_radius,
                      01_shelf_thickness], center = false);
                cylinder(r = 02_front_radius, h = 0.001, $fn = 64);
            }
            // b) Hinterer, gerader Teil
            translate([0, 0, 0])
                cube([01_shelf_width, 02_front_radius, 01_shelf_thickness], center = false);

            // RELIEF-Modus: Lilie wird zur Platte addiert
            if (07_lily_enabled && !07_lily_engrave) {
                lily_decoration();
            }
        }

        // Gravur-Modus: Lilie wird aus der Platte subtrahiert
        if (07_lily_enabled && 07_lily_engrave) {
            lily_decoration();
        }

        // Text-Gravur subtrahieren
        text_engraving();

        // Anti-Rutsch-Rillen
        anti_slip_grooves();
    }

    // Optionaler Rim
    if (06_rim_enabled && 06_rim_height > 0 && 06_rim_width > 0) {
        inner_br_start_y = 05_outer_br_thickness + 04_board_thickness + 04_fit_clearance;
        inner_br_front_y = inner_br_start_y + 05_inner_br_thickness;
        rim_y_start = inner_br_front_y;
        rim_y_end   = 01_shelf_depth - 02_front_radius;
        rim_depth_y = rim_y_end - rim_y_start;
        if (rim_depth_y > 0) {
            translate([02_front_radius, 01_shelf_depth - 06_rim_width, -06_rim_height])
            minkowski() {
                cube([01_shelf_width - 2*02_front_radius,
                      06_rim_width - 02_front_radius,
                      06_rim_height], center = false);
                cylinder(r = 02_front_radius, h = 0.001, $fn = 64);
            }
            translate([0, rim_y_start, -06_rim_height])
                cube([06_rim_width, rim_depth_y, 06_rim_height], center = false);
            translate([01_shelf_width - 06_rim_width, rim_y_start, -06_rim_height])
                cube([06_rim_width, rim_depth_y, 06_rim_height], center = false);
        }
    }
}

// Halterungen auf der UNTERSEITE
module brackets() {
    translate([0, 0, -05_outer_br_height])
        cube([01_shelf_width, 05_outer_br_thickness, 05_outer_br_height], center = false);
    translate([0,
               05_outer_br_thickness + 04_board_thickness + 04_fit_clearance,
               -05_inner_br_height])
        cube([01_shelf_width, 05_inner_br_thickness, 05_inner_br_height], center = false);
}

module fensterbank() {
    base_plate_with_rim();
    brackets();
}

// Aufruf
fensterbank();
