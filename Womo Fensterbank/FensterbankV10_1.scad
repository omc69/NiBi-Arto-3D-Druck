//
// Wohnmobil-Fensterbank
// Parametrisches Modell mit optimierter Customizer-Struktur
//

// ----------------------------------------------------------------------
// --- PARAMETER ---
// ----------------------------------------------------------------------

/* [A. GRUNDDIMENSIONEN PLATTE] */
// Breite (X)
01_shelf_width     = 250;   // [50:1:500]
// Tiefe (Y)
01_shelf_depth     = 200;   // [50:1:300]
// Dicke der Platte (Z)
01_shelf_thickness = 4;     // [2:0.5:10]

/* [B. KANTEN & VERFEINERUNG] */
// Radius der Abrundung (Vorder- und Seitenkanten)
02_front_radius    = 5;     // [0:0.5:10]

/* [C. ANTI-RUTSCH RILLEN (Vertiefungen)] */
03_grooves_enabled = true;   // [false, true] EIN/AUS-Schalter
// Tiefe der Rille
03_groove_depth    = 0.5;   // [0.1:0.1:2]
// Breite der Rille (entlang Y)
03_groove_width_x  = 2;     // [0.5:0.5:5]
// Abstand der Rillen (Mitte zu Mitte in Y)
03_groove_spacing_y= 10;    // [5:1:30]
// Startposition in Y (vom hinteren Rand y=0)
03_groove_offset_y = 10;    // [0:1:50]

/* [D. KLEMMUNG / HALTERUNG] */
// Abstand zwischen den INNENflächen der Halter (zu greifendes Element)
04_board_thickness = 50;    // [10:1:100]
// Spiel für die Klemmung (Anpassung an Druckergenauigkeit)
04_fit_clearance   = 0.5;   // [0:0.05:1]

/* [E. HALTERUNGS-MASSE] */
// Dicke des äußeren Halters (Y)
05_outer_br_thickness = 4;   // [1:1:10]
// Höhe des äußeren Halters (Z)
05_outer_br_height    = 40;  // [10:1:100]
// Dicke des inneren Halters (Y)
05_inner_br_thickness = 3;   // [1:1:10]
// Höhe des inneren Halters (Z)
05_inner_br_height    = 70;  // [10:1:100]

/* [F. OPTIONALER RAND (Deaktiviert)] */
06_rim_enabled     = false;  // [false, true] Rand an/aus
// Breite / Dicke des Randes (X/Y)
06_rim_width       = 5;     // [1:1:10]
// Höhe des Randes nach unten (Z)
06_rim_height      = 5;     // [1:1:10]


// ----------------------------------------------------------------------
// ---------- MODULE ----------
// (Alle Modul-Variablen wurden mit den entsprechenden Präfixen angepasst)
// ----------------------------------------------------------------------

// Modul zum Erstellen der Rillen (wird subtrahiert)
module anti_slip_grooves() {
   
    if (03_grooves_enabled) {
        
        num_grooves = floor((01_shelf_depth - 03_groove_offset_y) / 03_groove_spacing_y);
        
        for (i = [0 : 1 : num_grooves - 1]) {
            
            current_y = 03_groove_offset_y + i * 03_groove_spacing_y;
            groove_start_x = 02_front_radius; 
            groove_length_x = 01_shelf_width - 2 * 02_front_radius;
            
            // Rillenobjekt (Cube)
            translate([groove_start_x, current_y, 01_shelf_thickness - 03_groove_depth])
            cube([groove_length_x, 03_groove_width_x, 03_groove_depth + 0.01], center = false);
        }
    }
}


// Grundplatte + optionaler Rim
module base_plate_with_rim() {

    // --- 1. Korrigierte Grundplatte (Positiv-Objekt) ---
    difference() {
        
        union() {
            // a) Verrundeter Hauptteil
            translate([02_front_radius, 02_front_radius, 0])
            minkowski() {
                cube([01_shelf_width - 2*02_front_radius, 01_shelf_depth - 2*02_front_radius, 01_shelf_thickness], center = false);
                cylinder(r = 02_front_radius, h = 0.001, $fn = 64);
            }
            
            // b) Hinterer, gerader Teil
            translate([0, 0, 0])
                cube([01_shelf_width, 02_front_radius, 01_shelf_thickness], center = false);
        }
        
        // 2. Die ANTI-RUTSCH RILLEN (Negativ-Objekt)
        anti_slip_grooves();
        
    }
    
    // --- 2. Optionaler Rim (Derzeit deaktiviert) ---
    if (06_rim_enabled && 06_rim_height > 0 && 06_rim_width > 0) {
        
        inner_br_start_y = 05_outer_br_thickness + 04_board_thickness + 04_fit_clearance;
        inner_br_front_y = inner_br_start_y + 05_inner_br_thickness;
        rim_y_start = inner_br_front_y;
        rim_y_end   = 01_shelf_depth - 02_front_radius;
        rim_depth_y = rim_y_end - rim_y_start;
        
        if (rim_depth_y > 0) {
            
            rim_front_thickness = 06_rim_width;
            
            // FRONT-RAND (Verrundet)
            translate([02_front_radius, 01_shelf_depth - rim_front_thickness, -06_rim_height])
            minkowski() {
                cube([01_shelf_width - 2*02_front_radius, rim_front_thickness - 02_front_radius, 06_rim_height], center = false);
                cylinder(r = 02_front_radius, h = 0.001, $fn = 64);
            }
            // LINKER RAND (seitlich)
            translate([0, rim_y_start, -06_rim_height])
                cube([06_rim_width, rim_depth_y, 06_rim_height], center = false);
            // RECHTER RAND (seitlich)
            translate([01_shelf_width - 06_rim_width, rim_y_start, -06_rim_height])
                cube([06_rim_width, rim_depth_y, 06_rim_height], center = false);
        }
    }
}

// Halterungen auf der UNTERSEITE
module brackets() {
    // äußerer Halter (direkt an der Rückkante, nach UNTEN)
    translate([0, 0, -05_outer_br_height])
        cube([01_shelf_width, 05_outer_br_thickness, 05_outer_br_height], center = false);

    // innerer Halter (weiter vorne im Raum)
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