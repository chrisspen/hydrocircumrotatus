$fn = 96;

/* Bibliothek für Evolventen-Zahnräder

Enthält die Module
1. spur_gear(modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0)
1. arrow_wheel(modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0)
3. hohlrad(modul, number_of_teeth, height, randbreite, engagement_angle = 20, angle_of_inclination = 0
4. pfeilhohlrad(modul, number_of_teeth, height, randbreite, engagement_angle = 20, angle_of_inclination = 0)
5. planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, height, randbreite, bore, engagement_angle=20, angle_of_inclination=0)
6. kegelrad(modul, number_of_teeth, teilkegelwinkel, tooth_width, bore, engagement_angle = 20)
7. pfeilkegelrad(modul, number_of_teeth,  teilkegelwinkel, tooth_width, bore, engagement_angle = 20, angle_of_inclination=10)
8. kegelradpaar(modul, tooth_number_wheel, tooth_number_curve, tooth_width, bore, engagement_angle = 20, angle_of_inclination=0)

Beispiele für jedes Modul befinden sich auskommentiert am Ende dieser Datei

Autor:		Dr Jörg Janssen
Stand:		20. Juni 2016
Version:	1.3
Lizenz:		Creative Commons - Attribution, Non Commercial, Share Alike

Erlaubte Module nach DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3  0.4  0.5  0.6
0.7  0.8  0.9  1    1.25 1.5
2    2.5  3    4    5    6
8    10   12   16   20   25
32   40   50   60

*/


// Allgemeine Variablen
pi = 3.14159;
rad = 57.29578;
spiel = 0.05;	// Spiel zwischen Zähnen

/*	Wandelt Radian in Grad um */
function grad(engagement_angle) =  engagement_angle*rad;

/*	Wandelt Grad in Radian um */
function radian(engagement_angle) = engagement_angle/rad;

/*	Wandelt 2D-Polarkoordinaten in kartesische um
    Format: radius, phi; phi = Winkel zur x-Achse auf xy-Ebene */
function pol_zu_kart(polvect) = [
	polvect[0]*cos(polvect[1]),  
	polvect[0]*sin(polvect[1])
];

/*	Kreisevolventen-Funktion:
    Gibt die Polarkoordinaten einer Kreisevolvente aus
    r = Radius des Grundkreises
    rho = Abrollwinkel in Grad */
function ev(r,rho) = [
	r/cos(rho),
	grad(tan(rho)-radian(rho))
];

/*  Kugelevolventen-Funktion
    Gibt den Azimutwinkel einer Kugelevolvente aus
    theta0 = Polarwinkel des Kegels, an dessen Schnittkante zum Großkugel die Evolvente abrollt
    theta = Polarwinkel, für den der Azimutwinkel der Evolvente berechnet werden soll */
function kugelev(theta0,theta) = 1/sin(theta0)*acos(cos(theta)/cos(theta0))-acos(tan(theta0)/tan(theta));

/*  Wandelt Kugelkoordinaten in kartesische um
    Format: radius, theta, phi; theta = Winkel zu z-Achse, phi = Winkel zur x-Achse auf xy-Ebene */
function kugel_zu_kart(vect) = [
	vect[0]*sin(vect[1])*cos(vect[2]),  
	vect[0]*sin(vect[1])*sin(vect[2]),
	vect[0]*cos(vect[1])
];

/*	prüft, ob eine Zahl gerade ist
	= 1, wenn ja
	= 0, wenn die Zahl nicht gerade ist */
function istgerade(zahl) =
	(zahl == floor(zahl/2)*2) ? 1 : 0;

/*	größter gemeinsamer Teiler
	nach Euklidischem Algorithmus.
	Sortierung: a muss größer als b sein */
function ggt(a,b) = 
	a%b == 0 ? b : ggt(b,a%b);

/*  Stirnrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    number_of_teeth = Anzahl der Radzähne
    height = Höhe des Zahnrads
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung */
module spur_gear(modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0) {

	// Dimensions-Berechnungen	
	d = modul * number_of_teeth;								// Teilkreisdurchmesser
	r = d / 2;											// Teilkreisradius
	alpha_stirn = atan(tan(engagement_angle)/cos(angle_of_inclination));	// Schrägungswinkel im Stirnschnitt
	db = d * cos(alpha_stirn);							// Grundkreisdurchmesser
	rb = db / 2;										// Grundkreisradius
	da = (modul <1)? d + modul * 2.2 : d + modul * 2;	// Kopfkreisdurchmesser nach DIN 58400 bzw. DIN 867
	ra = da / 2;										// Kopfkreisradius
	c = modul / 6;										// Kopfspiel
	df = d - 2 * (modul + c);							// Fußkreisdurchmesser
	rf = df / 2;										// Fußkreisradius
	rho_ra = acos(rb/ra);								// maximaler Abrollwinkel;
														// Evolvente beginnt auf Grundkreis und endet an Kopfkreis
	rho_r = acos(rb/r);									// Abrollwinkel am Teilkreis;
														// Evolvente beginnt auf Grundkreis und endet an Kopfkreis
	phi_r = grad(tan(rho_r)-radian(rho_r));				// Winkel zum Punkt der Evolvente auf Teilkreis
	gamma = rad*height/(r*tan(90-angle_of_inclination));	// Torsionswinkel für Extrusion
	schritt = rho_ra/16;								// Evolvente wird in 16 Stücke geteilt
	tau = 360/number_of_teeth;									// Teilungswinkel

	// Zeichnung
	rotate([0,0,-phi_r-90*(1-spiel)/number_of_teeth]){				// Zahn auf x-Achse zentrieren;
															// macht Ausrichtung mit anderen Rädern einfacher

		linear_extrude(height = height, twist = gamma){
			difference(){
				union(){
					tooth_width = (180*(1-spiel))/number_of_teeth+2*phi_r;
					circle(rf);										// Fußkreis	
					for (rot = [0:tau:360]){
						rotate (rot){								// "Zahnzahl-mal" kopieren und drehen
							polygon(concat(							// Zahn
								[[0,0]],							// Zahnsegment beginnt und endet im Ursprung
								[for (rho = [0:schritt:rho_ra])		// von null Grad (Grundkreis)
																	// bis maximalen Evolventenwinkel (Kopfkreis)
									pol_zu_kart(ev(rb,rho))],		// Erste Evolventen-Flanke

								[pol_zu_kart(ev(rb,rho_ra))],		// Punkt der Evolvente auf Kopfkreis

								[for (rho = [rho_ra:-schritt:0])	// von maximalen Evolventenwinkel (Kopfkreis)
																	// bis null Grad (Grundkreis)
									pol_zu_kart([ev(rb,rho)[0], tooth_width-ev(rb,rho)[1]])]
																	// Zweite Evolventen-Flanke
																	// (180*(1-spiel)) statt 180 Grad,
																	// um Spiel an den Flanken zu erlauben
								)
							);
						}
					}
				}
				circle(r = bore/2);								// Bohrung
			}
		}
	}
}


/*  Pfeilrad; verwendet das Modul "spur_gear"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    number_of_teeth = Anzahl der Radzähne
    height = Höhe des Zahnrads
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module arrow_wheel(modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0){

	height = height/2;

	translate([0,0,height]){
		union(){
			spur_gear(modul, number_of_teeth, height, bore, engagement_angle, angle_of_inclination);		// untere Hälfte
			mirror([0,0,1]){
				spur_gear(modul, number_of_teeth, height, bore, engagement_angle, angle_of_inclination);	// obere Hälfte
			}
		}
	}
}


/*	Hohlrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    number_of_teeth = Anzahl der Radzähne
    height = Höhe des Zahnrads
	randbreite = Breite des Randes ab Fußkreis
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module hohlrad(modul, number_of_teeth, height, randbreite, engagement_angle = 20, angle_of_inclination = 0) {

	// Dimensions-Berechnungen	
	ha = (number_of_teeth >= 20) ? 0.02 * atan((number_of_teeth/15)/pi) : 0.6;	// Verkürzungsfaktor Zahnkopfhöhe
	d = modul * number_of_teeth;											// Teilkreisdurchmesser
	r = d / 2;														// Teilkreisradius
	alpha_stirn = atan(tan(engagement_angle)/cos(angle_of_inclination));// Schrägungswinkel im Stirnschnitt
	db = d * cos(alpha_stirn);										// Grundkreisdurchmesser
	rb = db / 2;													// Grundkreisradius
	c = modul / 6;													// Kopfspiel
	da = (modul <1)? d + (modul+c) * 2.2 : d + (modul+c) * 2;		// Kopfkreisdurchmesser
	ra = da / 2;													// Kopfkreisradius
	df = d - 2 * modul * ha;										// Fußkreisdurchmesser
	rf = df / 2;													// Fußkreisradius
	rho_ra = acos(rb/ra);											// maximaler Evolventenwinkel;
																	// Evolvente beginnt auf Grundkreis und endet an Kopfkreis
	rho_r = acos(rb/r);												// Evolventenwinkel am Teilkreis;
																	// Evolvente beginnt auf Grundkreis und endet an Kopfkreis
	phi_r = grad(tan(rho_r)-radian(rho_r));							// Winkel zum Punkt der Evolvente auf Teilkreis
	gamma = rad*height/(r*tan(90-angle_of_inclination));				// Torsionswinkel für Extrusion
	schritt = rho_ra/16;											// Evolvente wird in 16 Stücke geteilt
	tau = 360/number_of_teeth;												// Teilungswinkel

	// Zeichnung
	rotate([0,0,-phi_r-90*(1+spiel)/number_of_teeth])						// Zahn auf x-Achse zentrieren;
																	// macht Ausrichtung mit anderen Rädern einfacher
	linear_extrude(height = height, twist = gamma){
		difference(){
			circle(r = ra + randbreite);							// Außenkreis
			union(){
				tooth_width = (180*(1+spiel))/number_of_teeth+2*phi_r;
				circle(rf);											// Fußkreis	
				for (rot = [0:tau:360]){
					rotate (rot) {									// "Zahnzahl-mal" kopieren und drehen
						polygon( concat(
							[[0,0]],
							[for (rho = [0:schritt:rho_ra])			// von null Grad (Grundkreis)
																	// bis maximaler Evolventenwinkel (Kopfkreis)
								pol_zu_kart(ev(rb,rho))],
							[pol_zu_kart(ev(rb,rho_ra))],
							[for (rho = [rho_ra:-schritt:0])		// von maximaler Evolventenwinkel (Kopfkreis)
																	// bis null Grad (Grundkreis)
								pol_zu_kart([ev(rb,rho)[0], tooth_width-ev(rb,rho)[1]])]
																	// (180*(1+spiel)) statt 180,
																	// um Spiel an den Flanken zu erlauben
							)
						);
					}
				}
			}
		}
	}

	echo("Außendurchmesser Hohlrad = ", 2*(ra + randbreite));
	
}

/*  Pfeil-Hohlrad; verwendet das Modul "hohlrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    number_of_teeth = Anzahl der Radzähne
    height = Höhe des Zahnrads
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module pfeilhohlrad(modul, number_of_teeth, height, randbreite, engagement_angle = 20, angle_of_inclination = 0) {

	height = height / 2;
	translate([0,0,height])
		union(){
		hohlrad(modul, number_of_teeth, height, randbreite, engagement_angle, angle_of_inclination);		// untere Hälfte
		mirror([0,0,1])
			hohlrad(modul, number_of_teeth, height, randbreite, engagement_angle, angle_of_inclination);	// obere Hälfte
	}
}

/*	Planetengetriebe; verwendet die Module "arrow_wheel" und "pfeilhohlrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    zahnzahl_sonne = Anzahl der Zähne des Sonnenrads
    zahnzahl_planet = Anzahl der Zähne eines Planetenrads
    height = Höhe des Zahnrads
	randbreite = Breite des Randes ab Fußkreis
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, height, randbreite, bore, engagement_angle=20, angle_of_inclination=0){

	// Dimensions-Berechnungen
	d_sonne = modul*zahnzahl_sonne;										// Teilkreisdurchmesser Sonne
	d_planet = modul*zahnzahl_planet;									// Teilkreisdurchmesser Planeten
	achsabstand = (modul*zahnzahl_sonne +  modul*zahnzahl_planet) / 2;	// Abstand von Sonnenrad-/Hohlradachse und Planetenachse
	zahnzahl_hohlrad = zahnzahl_sonne + 2*zahnzahl_planet;				// Anzahl der Zähne des Hohlrades

	drehen = istgerade(zahnzahl_planet);								// Muss das Sonnenrad gedreht werden?
		
	n_planeten = (zahnzahl_planet>zahnzahl_sonne) ? ggt(zahnzahl_planet,zahnzahl_sonne) : ggt(zahnzahl_sonne,zahnzahl_planet);
																		// Anzahl Planetenräder = größter gemeinsamer
																		// Teiler von Anzahl der Zähne des Sonnen- und
																		// Planetenrads
	
	// Zeichnung
	rotate([0,0,180/zahnzahl_sonne*drehen]){
		arrow_wheel (modul, zahnzahl_sonne, height, bore, engagement_angle, -angle_of_inclination);		// Sonnenrad
	}

	for(rot=[0:360/n_planeten:360/n_planeten*(n_planeten-1)]){
		translate(kugel_zu_kart([achsabstand,90,rot]))
			arrow_wheel (modul, zahnzahl_planet, height, bore, engagement_angle, angle_of_inclination);	// Planetenräder
		}
	
	pfeilhohlrad (modul, zahnzahl_hohlrad, height, randbreite, engagement_angle, angle_of_inclination);	// Hohlrad
}

/*  Kegelrad
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    number_of_teeth = Anzahl der Radzähne
    teilkegelwinkel = (Halb)winkel des Kegels, auf dem das jeweils andere Hohlrad abrollt
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
	angle_of_inclination = Schrägungswinkel, Standardwert = 0° */
module kegelrad(modul, number_of_teeth, teilkegelwinkel, tooth_width, bore, engagement_angle = 20, angle_of_inclination=0) {

	// Dimensions-Berechnungen
	d_aussen = modul * number_of_teeth;									// Teilkegeldurchmesser auf der Kegelgrundfläche,
																	// entspricht der Sehne im Kugelschnitt
	r_aussen = d_aussen / 2;										// Teilkegelradius auf der Kegelgrundfläche 
	rg_aussen = r_aussen/sin(teilkegelwinkel);						// Großkegelradius für Zahn-Außenseite, entspricht der Länge der Kegelflanke;
	rg_innen = rg_aussen - tooth_width;								// Großkegelradius für Zahn-Innenseite	
	r_innen = r_aussen*rg_innen/rg_aussen;
	alpha_stirn = atan(tan(engagement_angle)/cos(angle_of_inclination));// Schrägungswinkel im Stirnschnitt
	delta_b = asin(cos(alpha_stirn)*sin(teilkegelwinkel));			// Grundkegelwinkel		
	da_aussen = (modul <1)? d_aussen + (modul * 2.2) * cos(teilkegelwinkel): d_aussen + modul * 2 * cos(teilkegelwinkel);
	ra_aussen = da_aussen / 2;
	delta_a = asin(ra_aussen/rg_aussen);
	c = modul / 6;													// Kopfspiel
	df_aussen = d_aussen - (modul +c) * 2 * cos(teilkegelwinkel);
	rf_aussen = df_aussen / 2;
	delta_f = asin(rf_aussen/rg_aussen);
	rkf = rg_aussen*sin(delta_f);									// Radius des Kegelfußes
	hoehe_f = rg_aussen*cos(delta_f);								// Höhe des Kegels vom Fußkegel
	
	echo("Teilkegeldurchmesser auf der Kegelgrundfläche = ", d_aussen);
	
	// Größen für Komplementär-Kegelstumpf
	hoehe_k = (rg_aussen-tooth_width)/cos(teilkegelwinkel);			// Höhe des Komplementärkegels für richtige Zahnlänge
	rk = (rg_aussen-tooth_width)/sin(teilkegelwinkel);				// Fußradius des Komplementärkegels
	rfk = rk*hoehe_k*tan(delta_f)/(rk+hoehe_k*tan(delta_f));		// Kopfradius des Zylinders für 
																	// Komplementär-Kegelstumpf
	hoehe_fk = rk*hoehe_k/(hoehe_k*tan(delta_f)+rk);				// Hoehe des Komplementär-Kegelstumpfs

	echo("Höhe Kegelrad = ", hoehe_f-hoehe_fk);
	
	phi_r = kugelev(delta_b, teilkegelwinkel);						// Winkel zum Punkt der Evolvente auf Teilkegel
		
	// Torsionswinkel gamma aus Schrägungswinkel
	gamma_g = 2*atan(tooth_width*tan(angle_of_inclination)/(2*rg_aussen-tooth_width));
	gamma = 2*asin(rg_aussen/r_aussen*sin(gamma_g/2));
	
	schritt = (delta_a - delta_b)/16;
	tau = 360/number_of_teeth;												// Teilungswinkel
	start = (delta_b > delta_f) ? delta_b : delta_f;
	spiegelpunkt = (180*(1-spiel))/number_of_teeth+2*phi_r;

	// Zeichnung
	rotate([0,0,phi_r+90*(1-spiel)/number_of_teeth]){						// Zahn auf x-Achse zentrieren;
																	// macht Ausrichtung mit anderen Rädern einfacher
		translate([0,0,hoehe_f]) rotate(a=[0,180,0]){
			union(){
				translate([0,0,hoehe_f]) rotate(a=[0,180,0]){								// Kegelstumpf							
					difference(){
						linear_extrude(height=hoehe_f-hoehe_fk, scale=rfk/rkf) circle(rkf);
						translate([0,0,-1]){
							cylinder(h = hoehe_f-hoehe_fk+2, r = bore/2);				// Bohrung
						}
					}	
				}
				for (rot = [0:tau:360]){
					rotate (rot) {															// "Zahnzahl-mal" kopieren und drehen
						union(){
							if (delta_b > delta_f){
								// Zahnfuß
								flankenpunkt_unten = 1*spiegelpunkt;
								flankenpunkt_oben = kugelev(delta_f, start);
								polyhedron(
									points = [
										kugel_zu_kart([rg_aussen, start*1.001, flankenpunkt_unten]),	// 1 promille Überlappung mit Zahn
										kugel_zu_kart([rg_innen, start*1.001, flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_innen, start*1.001, spiegelpunkt-flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_aussen, start*1.001, spiegelpunkt-flankenpunkt_unten]),								
										kugel_zu_kart([rg_aussen, delta_f, flankenpunkt_unten]),
										kugel_zu_kart([rg_innen, delta_f, flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_innen, delta_f, spiegelpunkt-flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_aussen, delta_f, spiegelpunkt-flankenpunkt_unten])								
									],
									faces = [[0,1,2],[0,2,3],[0,4,1],[1,4,5],[1,5,2],[2,5,6],[2,6,3],[3,6,7],[0,3,7],[0,7,4],[4,6,5],[4,7,6]],
									convexity =1
								);
							}
							// Zahn
							for (delta = [start:schritt:delta_a-schritt]){
								flankenpunkt_unten = kugelev(delta_b, delta);
								flankenpunkt_oben = kugelev(delta_b, delta+schritt);
								polyhedron(
									points = [
										kugel_zu_kart([rg_aussen, delta, flankenpunkt_unten]),
										kugel_zu_kart([rg_innen, delta, flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_innen, delta, spiegelpunkt-flankenpunkt_unten+gamma]),
										kugel_zu_kart([rg_aussen, delta, spiegelpunkt-flankenpunkt_unten]),								
										kugel_zu_kart([rg_aussen, delta+schritt, flankenpunkt_oben]),
										kugel_zu_kart([rg_innen, delta+schritt, flankenpunkt_oben+gamma]),
										kugel_zu_kart([rg_innen, delta+schritt, spiegelpunkt-flankenpunkt_oben+gamma]),
										kugel_zu_kart([rg_aussen, delta+schritt, spiegelpunkt-flankenpunkt_oben])									
									],
									faces = [[0,1,2],[0,2,3],[0,4,1],[1,4,5],[1,5,2],[2,5,6],[2,6,3],[3,6,7],[0,3,7],[0,7,4],[4,6,5],[4,7,6]],
									convexity =1
								);
							}
						}
					}
				}	
			}
		}
	}
}

/*  Pfeil-Kegelrad; verwendet das Modul "kegelrad"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    number_of_teeth = Anzahl der Radzähne
    height = Höhe des Zahnrads
    bore = Durchmesser der Mittelbohrung
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel, Standardwert = 0° */
module pfeilkegelrad(modul, number_of_teeth, teilkegelwinkel, tooth_width, bore, engagement_angle = 20, angle_of_inclination=0){

	// Dimensions-Berechnungen
	
	tooth_width = tooth_width / 2;
	
	d_aussen = modul * number_of_teeth;								// Teilkegeldurchmesser auf der Kegelgrundfläche,
																// entspricht der Sehne im Kugelschnitt
	r_aussen = d_aussen / 2;									// Teilkegelradius auf der Kegelgrundfläche 
	rg_aussen = r_aussen/sin(teilkegelwinkel);					// Großkegelradius, entspricht der Länge der Kegelflanke;
	c = modul / 6;												// Kopfspiel
	df_aussen = d_aussen - (modul +c) * 2 * cos(teilkegelwinkel);
	rf_aussen = df_aussen / 2;
	delta_f = asin(rf_aussen/rg_aussen);
	hoehe_f = rg_aussen*cos(delta_f);							// Höhe des Kegels vom Fußkegel

	// Torsionswinkel gamma aus Schrägungswinkel
	gamma_g = 2*atan(tooth_width*tan(angle_of_inclination)/(2*rg_aussen-tooth_width));
	gamma = 2*asin(rg_aussen/r_aussen*sin(gamma_g/2));
	
	echo("Teilkegeldurchmesser auf der Kegelgrundfläche = ", d_aussen);
	
	// Größen für Komplementär-Kegelstumpf
	hoehe_k = (rg_aussen-tooth_width)/cos(teilkegelwinkel);		// Höhe des Komplementärkegels für richtige Zahnlänge
	rk = (rg_aussen-tooth_width)/sin(teilkegelwinkel);			// Fußradius des Komplementärkegels
	rfk = rk*hoehe_k*tan(delta_f)/(rk+hoehe_k*tan(delta_f));	// Kopfradius des Zylinders für 
																// Komplementär-Kegelstumpf
	hoehe_fk = rk*hoehe_k/(hoehe_k*tan(delta_f)+rk);			// Hoehe des Komplementär-Kegelstumpfs
	
	modul_innen = modul-tooth_width/rg_aussen;

		union(){
		kegelrad(modul, number_of_teeth, teilkegelwinkel, tooth_width, bore, engagement_angle, angle_of_inclination);		// untere Hälfte
		translate([0,0,hoehe_f-hoehe_fk])
			rotate(a=-gamma,v=[0,0,1])
				kegelrad(modul_innen, number_of_teeth, teilkegelwinkel, tooth_width, bore, engagement_angle, -angle_of_inclination);	// obere Hälfte
	}
}

/*	Kegelradpaar mit beliebigem Achsenwinkel; verwendet das Modul "kegelrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    tooth_number_wheel = Anzahl der Radzähne am Rad
    tooth_number_curve = Anzahl der Radzähne am Ritzel
	axis_angle = Winkel zwischen den Achsen von Rad und Ritzel
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    bore_wheel = Durchmesser der Mittelbohrung des Rads
    bore_curler = Durchmesser der Mittelbohrungen des Ritzels
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
	angle_of_inclination = Schrägungswinkel, Standardwert = 0° */
module kegelradpaar(modul, tooth_number_wheel, tooth_number_curve, axis_angle=90, tooth_width, bore_wheel, bore_curler, engagement_angle=20, angle_of_inclination=0, together_build=1){
 
	// Dimensions-Berechnungen
	r_rad = modul*tooth_number_wheel/2;							// Teilkegelradius des Rads
	delta_rad = atan(sin(axis_angle)/(tooth_number_curve/tooth_number_wheel+cos(axis_angle)));	// Kegelwinkel des Rads
	delta_ritzel = atan(sin(axis_angle)/(tooth_number_wheel/tooth_number_curve+cos(axis_angle)));// Kegelwingel des Ritzels
	rg = r_rad/sin(delta_rad);								// Radius der Großkugel
	c = modul / 6;											// Kopfspiel
	df_ritzel = 4*pi*rg*delta_ritzel/360 - 2 * (modul + c);	// Fußkegeldurchmesser auf der Großkugel 
	rf_ritzel = df_ritzel / 2;								// Fußkegelradius auf der Großkugel
	delta_f_ritzel = rf_ritzel/(2*pi*rg) * 360;				// Kopfkegelwinkel
	rkf_ritzel = rg*sin(delta_f_ritzel);					// Radius des Kegelfußes
	hoehe_f_ritzel = rg*cos(delta_f_ritzel);				// Höhe des Kegels vom Fußkegel
	
	echo("Kegelwinkel Rad = ", delta_rad);
	echo("Kegelwinkel Ritzel = ", delta_ritzel);
 
	df_rad = 4*pi*rg*delta_rad/360 - 2 * (modul + c);		// Fußkegeldurchmesser auf der Großkugel 
	rf_rad = df_rad / 2;									// Fußkegelradius auf der Großkugel
	delta_f_rad = rf_rad/(2*pi*rg) * 360;					// Kopfkegelwinkel
	rkf_rad = rg*sin(delta_f_rad);							// Radius des Kegelfußes
	hoehe_f_rad = rg*cos(delta_f_rad);						// Höhe des Kegels vom Fußkegel

	echo("Höhe Rad = ", hoehe_f_rad);
	echo("Höhe Ritzel = ", hoehe_f_ritzel);
	
	drehen = istgerade(tooth_number_curve);
	
	// Zeichnung
	// Rad
	rotate([0,0,180*(1-spiel)/tooth_number_wheel*drehen])
		kegelrad(modul, tooth_number_wheel, delta_rad, tooth_width, bore_wheel, engagement_angle, angle_of_inclination);
	
	// Ritzel
	if (together_build == 1)
		translate([-hoehe_f_ritzel*cos(90-axis_angle),0,hoehe_f_rad-hoehe_f_ritzel*sin(90-axis_angle)])
			rotate([0,axis_angle,0])
				kegelrad(modul, tooth_number_curve, delta_ritzel, tooth_width, bore_curler, engagement_angle, -angle_of_inclination);
	else
		translate([rkf_ritzel*2+modul+rkf_rad,0,0])
			kegelrad(modul, tooth_number_curve, delta_ritzel, tooth_width, bore_curler, engagement_angle, -angle_of_inclination);
 }

/*	Pfeil-Kegelradpaar mit beliebigem Achsenwinkel; verwendet das Modul "pfeilkegelrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    tooth_number_wheel = Anzahl der Radzähne am Rad
    tooth_number_curve = Anzahl der Radzähne am Ritzel
	axis_angle = Winkel zwischen den Achsen von Rad und Ritzel
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    bore_wheel = Durchmesser der Mittelbohrung des Rads
    bore_curler = Durchmesser der Mittelbohrungen des Ritzels
    engagement_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867
    angle_of_inclination = Schrägungswinkel, Standardwert = 0° */
module arrow_bevel_gear_pair(modul, tooth_number_wheel, tooth_number_curve, axis_angle=90, tooth_width, bore_wheel, bore_curler, engagement_angle = 20, angle_of_inclination=10, together_build=1, show_a=1, show_b=1){
 
	r_rad = modul*tooth_number_wheel/2;							// Teilkegelradius des Rads
	delta_rad = atan(sin(axis_angle)/(tooth_number_curve/tooth_number_wheel+cos(axis_angle)));	// Kegelwinkel des Rads
	delta_ritzel = atan(sin(axis_angle)/(tooth_number_wheel/tooth_number_curve+cos(axis_angle)));// Kegelwingel des Ritzels
	rg = r_rad/sin(delta_rad);								// Radius der Großkugel
	c = modul / 6;											// Kopfspiel
	df_ritzel = 4*pi*rg*delta_ritzel/360 - 2 * (modul + c);	// Fußkegeldurchmesser auf der Großkugel 
	rf_ritzel = df_ritzel / 2;								// Fußkegelradius auf der Großkugel
	delta_f_ritzel = rf_ritzel/(2*pi*rg) * 360;				// Kopfkegelwinkel
	rkf_ritzel = rg*sin(delta_f_ritzel);					// Radius des Kegelfußes
	hoehe_f_ritzel = rg*cos(delta_f_ritzel);				// Höhe des Kegels vom Fußkegel
	
	echo("Kegelwinkel Rad = ", delta_rad);
	echo("Kegelwinkel Ritzel = ", delta_ritzel);
 
	df_rad = 4*pi*rg*delta_rad/360 - 2 * (modul + c);		// Fußkegeldurchmesser auf der Großkugel 
	rf_rad = df_rad / 2;									// Fußkegelradius auf der Großkugel
	delta_f_rad = rf_rad/(2*pi*rg) * 360;					// Kopfkegelwinkel
	rkf_rad = rg*sin(delta_f_rad);							// Radius des Kegelfußes
	hoehe_f_rad = rg*cos(delta_f_rad);						// Höhe des Kegels vom Fußkegel

	echo("Höhe Rad = ", hoehe_f_rad);
	echo("Höhe Ritzel = ", hoehe_f_ritzel);
	
	drehen = istgerade(tooth_number_curve);
	
	// Rad
	if(show_a)
	rotate([0,0,180*(1-spiel)/tooth_number_wheel*drehen])
		pfeilkegelrad(modul, tooth_number_wheel, delta_rad, tooth_width, bore_wheel, engagement_angle, angle_of_inclination);
	
	// Ritzel
	if(show_b){
	if (together_build == 1)
		translate([-hoehe_f_ritzel*cos(90-axis_angle),0,hoehe_f_rad-hoehe_f_ritzel*sin(90-axis_angle)])
			rotate([0,axis_angle,0])
				pfeilkegelrad(modul, tooth_number_curve, delta_ritzel, tooth_width, bore_curler, engagement_angle, -angle_of_inclination);
	else
		translate([rkf_ritzel*2+modul+rkf_rad,0,0])
			pfeilkegelrad(modul, tooth_number_curve, delta_ritzel, tooth_width, bore_curler, engagement_angle, -angle_of_inclination);
	}

}

translate([0,0,-7])
spur_gear(modul=1, number_of_teeth=30, height=5, bore=0, engagement_angle=20, angle_of_inclination=0);

rotate([0,0,5.5])
color("red")
arrow_wheel(modul=1, number_of_teeth=30, height=5, bore=4, engagement_angle=20, angle_of_inclination=30);

//hohlrad (modul=1, number_of_teeth=30, height=5, randbreite=5, engagement_angle=20, angle_of_inclination=20);

//pfeilhohlrad (modul=1, number_of_teeth=30, height=5, randbreite=5, engagement_angle=20, angle_of_inclination=30);

//planetengetriebe(modul=1, zahnzahl_sonne=15, zahnzahl_planet=12, height=6, randbreite=5, bore=4, engagement_angle=20, angle_of_inclination=30);

//kegelrad(modul=1, number_of_teeth=30,  teilkegelwinkel=45, tooth_width=5, bore=4, engagement_angle=20, angle_of_inclination=20);

//pfeilkegelrad(modul=1, number_of_teeth=30, teilkegelwinkel=45, tooth_width=5, bore=4, engagement_angle=20, angle_of_inclination=30);

//kegelradpaar(modul=1, tooth_number_wheel=30, tooth_number_curve=11, axis_angle=100, tooth_width=5, bore=4, engagement_angle = 20, angle_of_inclination=20, together_build=1);

/*
arrow_bevel_gear_pair(
    modul=1,
    tooth_number_wheel=110,
    tooth_number_curve=11,
    axis_angle=90,
    tooth_width=5,
    bore_wheel=5,
    bore_curler=1,
    engagement_angle = 20,
    //angle_of_inclination=30,
    angle_of_inclination=20,
    //angle_of_inclination=45,
    together_build=1);
*/