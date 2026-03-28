// ============================================================
// Parametrische Flaschenhalterung mit Eckstützen und Zylinderaufnahme
// ============================================================
// Aufbau:
//   z =  platten_dicke  → Oberkante Platte = Öffnung Zylinder (bündig)
//   z =  0              → Unterkante Platte
//   z = -stuetzen_hoehe → Unterkante Stützen / max. Boden Zylinder
// ============================================================

// --- Parameter (anpassbar) ---
laenge            = 200;  // Länge der Grundplatte in mm
breite            = 123;  // Breite der Grundplatte in mm
stuetzen_hoehe    =  50;  // Höhe der Eckstützen in mm
flaschen_dm       = 114;  // Innendurchmesser des Zylinders (Flaschendurchmesser) in mm
zylinder_tiefe    =  40;  // Gewünschte Tiefe des Zylinders in mm
                          // Wird automatisch auf stuetzen_hoehe begrenzt!
mit_stuetzen      = false; // true = Eckstützen an / false = Eckstützen aus

// --- Konstanten ---
platten_dicke     =   3;  // Dicke der Grundplatte in mm (0,3 cm)
stuetzen_breite   =   5;  // Querschnitt der quadratischen Stützen in mm (0,5 cm)
wandstaerke       =   3;  // Wandstärke des Zylinders in mm

// --- Effektive Zylindertiefe: nie tiefer als die Stützen ---
eff_tiefe = min(zylinder_tiefe, stuetzen_hoehe);

// --- Kreisauflösung ---
$fn = 64;

// ============================================================
// Modul: Grundplatte mit Ausschnitt für den Zylinder
// ============================================================
module grundplatte() {
    difference() {
        translate([-laenge/2, -breite/2, 0])
            cube([laenge, breite, platten_dicke]);

        // Ausschnitt für Zylinder (Außen-DM)
        translate([0, 0, -0.1])
            cylinder(h = platten_dicke + 0.2, d = flaschen_dm + 2 * wandstaerke);
    }
}

// ============================================================
// Modul: Hohler Zylinder hängt UNTER der Grundplatte.
// ============================================================
module flaschenhalter() {
    translate([0, 0, platten_dicke - eff_tiefe])
        difference() {
            cylinder(h = eff_tiefe, d = flaschen_dm + 2 * wandstaerke);
            translate([0, 0, wandstaerke])
                cylinder(h = eff_tiefe, d = flaschen_dm);
        }
}

// ============================================================
// Modul: Eine einzelne Eckstütze
// ============================================================
module stuetze() {
    cube([stuetzen_breite, stuetzen_breite, stuetzen_hoehe]);
}

// ============================================================
// Modul: Alle vier Eckstützen positionieren
// ============================================================
module eckstuetzen() {
    x = laenge/2 - stuetzen_breite;
    y = breite/2  - stuetzen_breite;

    // Vorne links
    translate([-laenge/2, -breite/2, -stuetzen_hoehe]) stuetze();
    // Vorne rechts
    translate([x,          -breite/2, -stuetzen_hoehe]) stuetze();
    // Hinten links
    translate([-laenge/2,  y,         -stuetzen_hoehe]) stuetze();
    // Hinten rechts
    translate([x,          y,         -stuetzen_hoehe]) stuetze();
}

// ============================================================
// Zusammenbau
// ============================================================
union() {
    grundplatte();
    flaschenhalter();
    if (mit_stuetzen) {
        eckstuetzen();
    }
}
