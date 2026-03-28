// ============================================================
// Parametrische Lochplatte mit Eckstützen und Zylindern
// ============================================================
// Aufbau:
//   z = +platten_dicke           → Oberkante Platte = Öffnung Zylinder
//   z =  0                       → Unterkante Platte
//   z = -(platten_dicke-zyl_tief)→ Zylinderboden
//   z = -stuetzen_hoehe          → Unterkante Stützen
// ============================================================

// --- Parameter (anpassbar) ---
laenge          =  318/2;  // Länge der Grundplatte in mm
breite          =  158;  // Breite der Grundplatte in mm
stuetzen_hoehe  =   32;  // Höhe der Eckstützen in mm
bohrung_dm      =   62;  // Innendurchmesser der Zylinder (= Öffnung) in mm
n_bohrungen     =    2;  // Anzahl Bohrungen pro Reihe entlang der Länge
zylinder_tiefe  =   32;  // Tiefe der Zylinder in mm (max = stuetzen_hoehe!)
mit_stuetzen    = false; // true = Stützen an / false = Stützen aus

// --- Konstanten ---
platten_dicke   =  3;   // Dicke der Grundplatte in mm
stuetzen_breite =  5;   // Querschnitt der quadratischen Stützen in mm
randabstand     =  12;   // Mindestabstand Bohrungsrand → Plattenrand in mm
wandstaerke     =  3;   // Wandstärke der Zylinder in mm

// --- Kreisauflösung ---
$fn = 64;

// --- Sicherheit: Zylinder nie tiefer als Stützen ---
eff_tiefe = min(zylinder_tiefe, stuetzen_hoehe);

// ============================================================
// Berechnete Hilfswerte – Bohrungsverteilung
//
//   rand_mitte = randabstand + bohrung_dm/2
//   → Abstand Bohrungsmitte zum Plattenrand
//
//   avail_x    = laenge/2 - rand_mitte
//   abstand_x  = (2 × avail_x) / (n - 1)
//   pos_x[i]   = -avail_x + i × abstand_x   (symmetrisch um x=0)
//
//   y_reihe    = ±(breite/2 - rand_mitte)    (symmetrisch um y=0)
// ============================================================
rand_mitte = randabstand + bohrung_dm / 2;
avail_x    = laenge/2 - rand_mitte;
abstand_x  = (n_bohrungen > 1) ? (2 * avail_x) / (n_bohrungen - 1) : 0;
y_reihe    = breite/2 - rand_mitte;

// Außendurchmesser der Zylinder
aussen_dm  = bohrung_dm + 2 * wandstaerke;

// ============================================================
// Modul: Grundplatte
// Ausschnitte haben den AUSSEN-DM der Zylinder,
// damit die Zylinder bündig eingesetzt werden.
// ============================================================
module grundplatte() {
    difference() {
        translate([-laenge/2, -breite/2, 0])
            cube([laenge, breite, platten_dicke]);

        for (i = [0 : n_bohrungen - 1]) {
            pos_x = (n_bohrungen > 1) ? -avail_x + i * abstand_x : 0;

            // Ausschnitt Reihe 1 – vorne
            translate([pos_x, -y_reihe, -0.1])
                cylinder(h = platten_dicke + 0.2, d = aussen_dm);

            // Ausschnitt Reihe 2 – hinten
            translate([pos_x, +y_reihe, -0.1])
                cylinder(h = platten_dicke + 0.2, d = aussen_dm);
        }
    }
}

// ============================================================
// Modul: Ein einzelner Zylinder
// Öffnung oben bündig mit Plattenoberseite (z = platten_dicke)
// Hängt nach unten, Boden bei z = platten_dicke - eff_tiefe
// Außen-DM = aussen_dm, Innen-DM = bohrung_dm
// ============================================================
module zylinder_einzel(px, py) {
    translate([px, py, platten_dicke - eff_tiefe])
        difference() {
            // Außenwand
            cylinder(h = eff_tiefe, d = aussen_dm);
            // Innenbohrung (Boden bleibt stehen = wandstaerke)
            translate([0, 0, wandstaerke])
                cylinder(h = eff_tiefe, d = bohrung_dm);
        }
}

// ============================================================
// Modul: Alle Zylinder positionieren
// ============================================================
module zylinder_raster() {
    for (i = [0 : n_bohrungen - 1]) {
        pos_x = (n_bohrungen > 1) ? -avail_x + i * abstand_x : 0;

        zylinder_einzel(pos_x, -y_reihe);  // Reihe 1 – vorne
        zylinder_einzel(pos_x, +y_reihe);  // Reihe 2 – hinten
    }
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
    zylinder_raster();
    if (mit_stuetzen) {
        eckstuetzen();
    }
}
