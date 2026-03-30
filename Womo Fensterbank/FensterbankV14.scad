// BOSL2 für sauberes Rounding
include <BOSL2/std.scad>;

//
// Wohnmobil-Fensterbank
// - Oben: Platte + optional umlaufender Rand + BOSL2-Rundung oben an allen 4 Außenkanten
// - Oben: optional Anti-Rutsch-Rifflung auf der Grundfläche (ohne die Stecklöcher)
// - Unten: zwei Brackets zum Einstecken (mit Steck-Clips + Löchern in der Platte)
// - Brackets optional abnehmbar für optimalen Druck
// Alle Maße in mm
//

// ---------------- Basismaße ----------------

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
fit_clearance      = 0.5;   // Spiel für die Klemmung (additiv zur board_thickness)

// Äußerer Halter (fensterseitig)
outer_br_height    = 40;    // Höhe des Halters
outer_br_thickness = 4;     // Dicke in Y

// Innerer Halter (raumseitig)
inner_br_height    = 30;    // Höhe des Halters
inner_br_thickness = 3;     // Dicke in Y

// Anti-Rutsch-Rifflung
anti_slip_enabled    = true;  // Anti-Rutsch an/aus
anti_ridge_height    = 1.0;   // Höhe der Rillen über der Grundfläche
anti_ridge_width     = 3.0;   // Breite einer Rille in Y-Richtung
anti_ridge_spacing   = 8.0;   // Abstand von Rillenmitte zu Rillenmitte in Y-Richtung
anti_ridge_margin    = 3.0;   // Abstand zur Innenkante des Randes bzw. Plattenrand

// Brackets separat zum Drucken anordnen?
brackets_detached    = true;  // false = Brackets in Einbauposition, true = separat neben der Platte

// Steg hinten an der Platte, bevor die äußeren Löcher beginnen
back_steg            = 4.0;   // Materialstärke zwischen Plattenende (y=0) und Beginn des äußeren Brackets

// ---------------- Clips / Steckverbindung ----------------

// Anzahl der Stecknasen pro Bracket
plug_count           = 3;     // z.B. 2 oder 3

// Maße der Stecknasen (am Bracket)
plug_width_x         = 20;    // Länge der Nase in X-Richtung
plug_depth_y         = 6;     // Tiefe in Y-Richtung (in den Bracket hinein)
plug_height_z        = 3.0;   // Höhe der Nase, die in die Platte hineinragt

// Löcher in der Platte sind etwas größer:
plug_clearance       = 0.3;   // Toleranz (wird auf beide Seiten draufgeschlagen)
plug_margin_x        = 10.0;  // Abstand zu den Seiten in X


// =============================================================
// Abgeleitete Maße / gemeinsame Positionierungsfunktionen
// =============================================================

// FIX #1: innerer Bracket-Offset (korrigiert)
// Ziel: Abstand der INNENFLÄCHEN = board_thickness + fit_clearance
// Außenbracket liegt bei y = back_steg .. back_steg+outer_br_thickness
// Innenfläche außen = back_steg + outer_br_thickness
// Innenfläche innen = inner_y0
// => inner_y0 = back_steg + outer_br_thickness + board_thickness + fit_clearance
inner_y0 = back_steg + outer_br_thickness + board_thickness + fit_clearance;

// Gemeinsamer X-Schritt (zentriert über Plug-Geometrie, nicht über Loch-Geometrie)
step_x = (plug_count > 1)
  ? ( (shelf_width - 2*plug_margin_x - plug_width_x) / (plug_count - 1) )
  : 0;

// Gemeinsame X-Zentren der Plugs/Löcher
function x_center(i) = plug_margin_x + plug_width_x/2 + i*step_x;


// =============================================================
// Hilfs-Module: Stecklöcher / Stecknasen
// =============================================================

// Stecklöcher in der Platte (für beide Brackets)
module plug_holes() {
    // Hole-Höhe: komplett durch die Platte
    hole_h = shelf_thickness + 0.3;

    // Lochgrößen (mit Clearance)
    hole_w = plug_width_x  + 2*plug_clearance;
    hole_d = plug_depth_y  + 2*plug_clearance;

    // ---------- Äußerer Bracket: Löcher mit hinterem Steg ----------
    outer_y_center = back_steg + outer_br_thickness / 2;
    outer_y0_hole  = outer_y_center - hole_d/2;

    // ---------- Innerer Bracket ----------
    inner_y_center = inner_y0 + inner_br_thickness / 2;
    inner_y0_hole  = inner_y_center - hole_d/2;

    for (i = [0 : plug_count-1]) {
        xc = x_center(i);

        // Loch für äußeren Bracket (zentriert in X)
        translate([xc - hole_w/2, outer_y0_hole, 0])
            cube([hole_w, hole_d, hole_h], center = false);

        // Loch für inneren Bracket (zentriert in X)
        translate([xc - hole_w/2, inner_y0_hole, 0])
            cube([hole_w, hole_d, hole_h], center = false);
    }
}

// Maske für die Rillen: gleiche XY wie die Löcher, aber nur im Bereich der Anti-Slip-Höhe
module plug_holes_mask_for_ridges() {
    // Lochgrößen (mit Clearance), identisch wie in plug_holes()
    hole_w = plug_width_x  + 2*plug_clearance;
    hole_d = plug_depth_y  + 2*plug_clearance;

    outer_y_center = back_steg + outer_br_thickness / 2;
    outer_y0_hole  = outer_y_center - hole_d/2;

    inner_y_center = inner_y0 + inner_br_thickness / 2;
    inner_y0_hole  = inner_y_center - hole_d/2;

    // Maske nur im Bereich oberhalb der Platte, wo die Rillen sind
    top_z  = shelf_thickness;
    mask_h = anti_ridge_height + 1.0;  // etwas höher als die Rillen

    for (i = [0 : plug_count-1]) {
        xc = x_center(i);

        // Maskenblock über äußerem Loch
        translate([xc - hole_w/2, outer_y0_hole, top_z - 0.1])
            cube([hole_w, hole_d, mask_h], center = false);

        // Maskenblock über innerem Loch
        translate([xc - hole_w/2, inner_y0_hole, top_z - 0.1])
            cube([hole_w, hole_d, mask_h], center = false);
    }
}

// Stecknasen am äußeren Bracket (in Einbaukoordinaten)
module outer_bracket_plugs() {
    outer_y_center = back_steg + outer_br_thickness / 2;
    plug_y0        = outer_y_center - plug_depth_y / 2;

    for (i = [0 : plug_count-1]) {
        xc = x_center(i);
        translate([xc - plug_width_x/2, plug_y0, 0])
            cube([plug_width_x, plug_depth_y, plug_height_z], center = false);
    }
}

// Stecknasen am inneren Bracket (in Einbaukoordinaten)
module inner_bracket_plugs() {
    inner_y_center = inner_y0 + inner_br_thickness / 2;
    plug_y0        = inner_y_center - plug_depth_y / 2;

    for (i = [0 : plug_count-1]) {
        xc = x_center(i);
        translate([xc - plug_width_x/2, plug_y0, 0])
            cube([plug_width_x, plug_depth_y, plug_height_z], center = false);
    }
}


// =============================================================
// Grundplatte + Rand + Anti-Rutsch
// =============================================================

// Grundplatte + optionaler Rand, noch ohne Rundung, ohne Löcher
module flat_base_with_rim_raw() {

    // Platte
    cube([shelf_width, shelf_depth, shelf_thickness], center = false);

    // Rand auf der Oberseite (nur wenn aktiviert)
    if (rim_enabled && rim_height > 0 && rim_width > 0) {
        difference() {
            // äußerer Block für den Rand
            translate([0, 0, shelf_thickness])
                cube([shelf_width, shelf_depth, rim_height], center = false);

            // Innenbereich ausschneiden, damit nur der Ring stehen bleibt
            translate([rim_width, rim_width, shelf_thickness - 0.1])
                cube([shelf_width - 2*rim_width,
                      shelf_depth - 2*rim_width,
                      rim_height + 0.2], center = false);
        }
    }
}

// Anti-Rutsch-Rifflung auf der Grundfläche (oberhalb der Platte),
// aber ausgespart über den Stecklöchern.
module anti_slip_pattern() {
    if (anti_slip_enabled) {

        // Oberseite der Platte
        top_z = shelf_thickness;

        // Innenbereich definieren (umbenannt, damit inner_y0 für Bracket nicht überschattet wird)
        area_x0 = rim_enabled ? rim_width : 0;
        area_x1 = rim_enabled ? (shelf_width  - rim_width)  : shelf_width;
        area_y0 = rim_enabled ? rim_width : 0;
        area_y1 = rim_enabled ? (shelf_depth - rim_width) : shelf_depth;

        area_w  = area_x1 - area_x0;
        area_d  = area_y1 - area_y0;

        if (area_w > 2*anti_ridge_margin && area_d > 2*anti_ridge_margin) {

            start_y = area_y0 + anti_ridge_margin;
            end_y   = area_y1 - anti_ridge_margin;

            difference() {
                // Alle Rillen
                union() {
                    for (y = [start_y : anti_ridge_spacing : end_y]) {
                        translate([area_x0 + anti_ridge_margin,
                                   y - anti_ridge_width/2,
                                   top_z])
                            cube([
                                area_w - 2*anti_ridge_margin,
                                anti_ridge_width,
                                anti_ridge_height
                            ], center = false);
                    }
                }
                // Maske über den Stecklöchern -> dort werden die Rillen entfernt
                plug_holes_mask_for_ridges();
            }
        }
    }
}

// Grundplatte + Rand + Löcher + BOSL2-Rundung
module base_plate_with_rim() {

    // Gesamthöhe Platte + Rand
    H = shelf_thickness + (rim_enabled ? rim_height : 0);

    // Fall 1: Rand aus oder kein Radius -> einfache Platte mit Rand + Löchern + Rifflung
    if (!rim_enabled || front_radius <= 0) {
        difference() {
            flat_base_with_rim_raw();
            plug_holes();
        }
        anti_slip_pattern();
    }

    // Fall 2: Rand an + Radius > 0 -> BOSL2-cuboid als Außenform
    else {
        difference() {
            // ÄUSSERE Hülle mit Rundung
            translate([shelf_width/2, shelf_depth/2, H/2])
                cuboid(
                    [shelf_width, shelf_depth, H],
                    rounding = front_radius,
                    edges    = TOP+FRONT+BACK+LEFT+RIGHT
                );

            // Innenbereich des Randes wegschneiden
            translate([rim_width, rim_width, shelf_thickness])
                cube([
                    shelf_width  - 2*rim_width,
                    shelf_depth  - 2*rim_width,
                    rim_height + 0.2
                ], center = false);

            // Stecklöcher von unten durch die Platte
            plug_holes();
        }

        // Rifflung oben innen, mit ausgesparten Lochbereichen
        anti_slip_pattern();
    }
}


// =============================================================
// Brackets mit Steck-Clips
// =============================================================

// Äußerer Bracket in Einbaukoordinaten:
// - Körper von z=-outer_br_height .. 0
// - Stecknasen von z=0 .. plug_height_z
// - in Y ab back_steg
module outer_bracket_assembled() {
    // Körper
    translate([0, back_steg, -outer_br_height])
        cube([shelf_width, outer_br_thickness, outer_br_height], center = false);

    // Stecknasen oben
    outer_bracket_plugs();
}

// Innerer Bracket in Einbaukoordinaten
module inner_bracket_assembled() {
    // Körper
    translate([0, inner_y0, -inner_br_height])
        cube([shelf_width, inner_br_thickness, inner_br_height], center = false);

    // Stecknasen oben
    inner_bracket_plugs();
}

// Brackets in Einbauposition (Visualisierung)
module brackets_attached() {
    outer_bracket_assembled();
    inner_bracket_assembled();
}

// Brackets für separaten Druck: beide mit Unterseite auf z=0, neben die Platte gestellt
module brackets_detached_for_print() {

    offset_y = shelf_depth + 20;

    // äußerer Bracket: tiefste Stelle bei z=-outer_br_height -> um +outer_br_height anheben
    translate([0, offset_y, outer_br_height])
        outer_bracket_assembled();

    // innerer Bracket daneben
    translate([0, offset_y + outer_br_thickness + 10, inner_br_height])
        inner_bracket_assembled();
}


// =============================================================
// Gesamtes Modell
// =============================================================
module fensterbank() {
    // Grundplatte mit Rand, Rundung, Stecklöchern und Anti-Rutsch
    base_plate_with_rim();

    // Brackets je nach Modus
    if (brackets_detached) {
        brackets_detached_for_print();
    } else {
        brackets_attached();
    }
}

// Aufruf
fensterbank();
