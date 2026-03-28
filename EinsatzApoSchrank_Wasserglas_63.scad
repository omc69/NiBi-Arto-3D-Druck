// ============================================================
// Parametrische Lochplatte mit Eckstützen und Zylindern
// ============================================================
// Aufbau:
//   z = +platten_dicke  → Oberkante Platte = Öffnung Zylinder
//   z =  0              → Unterkante Platte
//   z = -stuetzen_hoehe → Unterkante Stützen
// ============================================================

// --- Parameter (anpassbar) ---
laenge          =  159; // Länge der Grundplatte in mm
breite          =  159;   // Breite der Grundplatte in mm
stuetzen_hoehe  =   32;   // Höhe der Eckstützen in mm
bohrung_dm      =   63;   // Innendurchmesser der Zylinder in mm
zylinder_tiefe  =   32;   // Tiefe der Zylinder in mm (max = stuetzen_hoehe!)
mit_stuetzen    = true;  // true = Stützen an / false = Stützen aus

// --- Konstanten ---
platten_dicke   =  3;    // Dicke der Grundplatte in mm
stuetzen_breite =  9;    // Querschnitt der quadratischen Stützen in mm
randabstand     =  16;   // Mindestabstand Bohrungsrand → Plattenrand in mm
wandstaerke     =  3;    // Wandstärke der Zylinder in mm

// --- Kreisauflösung ---
$fn = 64;

// --- Sicherheit: Zylinder nie tiefer als Stützen ---
eff_tiefe = min(zylinder_tiefe, stuetzen_hoehe);

// ============================================================
// Berechnete Hilfswerte
//
//   rand_mitte = randabstand + bohrung_dm/2
//   → Abstand Bohrungsmitte zum Plattenrand
//
//   Diagonale Platzierung:
//   Bohrung 1: vorne-links  (-x, -y)
//   Bohrung 2: hinten-rechts (+x, +y)
// ============================================================
rand_mitte = randabstand + bohrung_dm / 2;
pos_x      = laenge/2 - rand_mitte;   // X-Abstand vom Zentrum
pos_y      = breite/2 - rand_mitte;   // Y-Abstand vom Zentrum
aussen_dm  = bohrung_dm + 2 * wandstaerke;

// ============================================================
// Modul: Grundplatte mit 2 diagonalen Ausschnitten
// ============================================================
module grundplatte() {
    difference() {
        translate([-laenge/2, -breite/2, 0])
            cube([laenge, breite, platten_dicke]);

        // Bohrung 1 – vorne links
        translate([-pos_x, -pos_y, -0.1])
            cylinder(h = platten_dicke + 0.2, d = aussen_dm);

        // Bohrung 2 – hinten rechts
        translate([+pos_x, +pos_y, -0.1])
            cylinder(h = platten_dicke + 0.2, d = aussen_dm);
    }
}

// ============================================================
// Modul: Ein einzelner Zylinder (hängt unter der Platte)
// ============================================================
module zylinder_einzel(px, py) {
    translate([px, py, platten_dicke - eff_tiefe])
        difference() {
            cylinder(h = eff_tiefe, d = aussen_dm);
            translate([0, 0, wandstaerke])
                cylinder(h = eff_tiefe, d = bohrung_dm);
        }
}

// ============================================================
// Modul: Beide Zylinder diagonal
// ============================================================
module zylinder_diagonal() {
    zylinder_einzel(-pos_x, -pos_y);  // vorne links
    zylinder_einzel(+pos_x, +pos_y);  // hinten rechts
}

// ============================================================
// Modul: Eine einzelne Eckstütze
// ============================================================
module stuetze() {
    cube([stuetzen_breite, stuetzen_breite, stuetzen_hoehe]);
}

// ============================================================
// Modul: Alle vier Eckstützen unter der Grundplatte
// ============================================================
module eckstuetzen() {
    x = laenge/2 - stuetzen_breite;
    y = breite/2  - stuetzen_breite;

    translate([-laenge/2, -breite/2, -stuetzen_hoehe]) stuetze();
    translate([ x,        -breite/2, -stuetzen_hoehe]) stuetze();
    translate([-laenge/2,  y,        -stuetzen_hoehe]) stuetze();
    translate([ x,         y,        -stuetzen_hoehe]) stuetze();
}

// ============================================================
// Zusammenbau
// ============================================================
union() {
    grundplatte();
    zylinder_diagonal();
    if (mit_stuetzen) {
        eckstuetzen();
    }
}
