$fn = 96;

/* Library for involute gears

Contains the modules
1. spur_gear (modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0)
1. arrow_wheel (modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0)
3. hollow_wheel (modul, number_of_teeth, height, edge_width, engagement_angle = 20, angle_of_inclination = 0
4. arrow_ring_gear (modul, number_of_teeth, height, edge_width, engagement_angle = 20, angle_of_inclination = 0)
5. planetary_gear_unit (modul, number_of_teeth, tooth_number_planet, height, edge_width, bore, engagement_angle = 20, angle_of_inclination = 0)
6. bevel_gear (modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20)
7. pipe_bevel_gear (modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 10)
8. bevel_gear_pair (modul, tooth_number_wheel, tooth_number_curve, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 0)

Examples for each module are found at the end of this file

Author: Dr Jörg Janssen
Stand: June 20, 2016
Version: 1.3
License: Creative Commons - Attribution, Non Commercial, Share Alike

Permitted modules according to DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3 0.4 0.5 0.6
0.7 0.8 0.9 1 1.25 1.5
2 2.5 3 4 5 6
8 10 12 16 20 25
32 40 50 60

Translated from the original German at http://www.thingiverse.com/thing:1604369.

*/


// General variables
pi = 3.14159;
rad = 57.29578;
game = 0.05; // Play between teeth

/* Convert Radian to degrees */
function degree(v) = v * rad;

/* Converts degrees to radians */
function radian (v) = v / rad;

/* Convert 2D polar coordinates to Cartesian
    Format: radius, phi; Phi = angle to x-axis on xy-plane */
function pol_to_kart(polvect) = [
    polvect[0] * cos(polvect [1]),
    polvect[0] * sin(polvect [1])
];

/* Circular flow function:
    Outputs the polar coordinates of a circular arc
    R = radius of the base circle
    Rho = rolling angle in degrees */
function ev (r, rho) = [
    r / cos(rho),
    degree (tan (rho) - radian (rho))
];

/* Headlamp function
    Returns the azimuth angle of a spherical lens
    Theta0 = Polar angle of the cone, at the cutting edge of which the roller is rolled
    Theta = polar angle for which the azimuth angle of the involute is to be calculated */
function kugelev (theta0, theta) = 1 / sin(theta0) * acos(cos(theta) / cos(theta0)) - acos(tan (theta0) / tan (theta));

/* Converts spherical coordinates into Cartesian
    Format: radius, theta, phi; Theta = angle to z-axis, phi = angle to x-axis on xy-plane */
function kugel_zu_kart (vect) = [
    vect [0] * sin(vect [1]) * cos(vect [2]),
    vect [0] * sin(vect [1]) * sin(vect [2]),
    vect [0] * cos(vect [1])
];

/* Checks whether a number is even
= 1, if so
= 0 if the number is not even */
function is_even(number) = (number == floor (number / 2) * 2) ? 1: 0;

/* greatest common divisor
According to Euclidean algorithm.
Sorting: a must be greater than b */
function ggt(a,b) = 
    a%b == 0 ? b : ggt(b,a%b);

/* spur_gear
    Modul = height of the tooth head above the subcircuit
    number_of_teeth = number of wheel teeth
    Height = height of the gear wheel
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = angle_of_inclination to the axis of rotation; 0 ° = straight toothing */
module spur_gear(modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0) {

    // Dimensions calculations
    d = modul * number_of_teeth; // pitch circle diameter
    r = d / 2; // circle radius
    alpha_stirn = atan (tan (engagement_angle) / cos(angle_of_inclination)); // angle_of_inclination in the face section
    db = d * cos(alpha_stirn); // Base diameter
    rb = db / 2; // Base radius
    da = (modul <1)? D + modul * 2.2: d + modul * 2; // Head circle diameter according to DIN 58400 or DIN 867
    ra = da / 2; // Head circle radius
    c = modul / 6; // Head game
    df = d - 2 * (modul + c); // Foot circle diameter
    rf = df / 2; // Root circle radius
    rho_ra = acos(rb / ra);    // maximum unwinding angle;
                                // Evolvente starts on the basic circle and ends at the top of the circle
    rho_r = acos(rb / r);      // roll-off angle at the pitch circle;
                                // Evolvente starts on the basic circle and ends at the top of the circle
    phi_r = degree(tan (rho_r) -radian (rho_r)); // Angle to the point of the involute on a circle
    gamma = rad * height / (r * tan (90 - angle_of_inclination)); // Torsion angle for extrusion
    step = rho_ra / 16; // Evolvente is divided into 16 pieces
    tau = 360 / number_of_teeth; // Pitch angle

    // drawing
    rotate([0,0, -phi_r-90 * (1-game) / number_of_teeth]) {// center tooth on x-axis;
        // makes alignment with other wheels easier
        linear_extrude(height = height, twist = gamma) {
            difference() {
                union(){
                    tooth_width = (180 * (1-game)) / number_of_teeth + 2 * phi_r;
                    circle(rf); // Foot circle
                    for(red = [0: tau: 360]) {
                        rotate(red) {// Copy "number_of_teeth" and rotate
                            polygon(concat (// Zah
                                [[0,0]], // tooth segment starts and ends in the origin
                                [for(rho = [0: step: rho_ra]) // from zero degree (basic circle)
                                    // to maximum involute angle (head circle)
                                    pol_to_kart (ev (rb, rho))], // First involute flank

                                [pol_to_kart (ev (rb, rho_ra))], // point of the involute on the head circle

                                [for(rho = [rho_ra: step: 0]) // of maximum involute angle (head circle)
                                    // to zero degree (basic circle)
                                    pol_to_kart([ev(rb, rho)[0], tooth_width-ev(rb, rho)[1]])]
						          //pol_to_kart([ev(rb, rho)[0], zahnbreite -ev(rb, rho)[1]])]
                                    // Second involute flank
                                    // (180 * (1-game)) instead of 180 degrees,
                                    // to allow play on the flanks
                                )
                            );
                        }
                    }
                }
                circle(r = bore / 2); // Drilling
            }
        }
    }
}


/* arrow_wheel; Uses the "spur"
    Modul = height of the tooth head above the subcircuit
    number_of_teeth = number of wheel teeth
    Height = height of the gear wheel
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = angle_of_inclination to the rotation axis, standard value = 0 ° (straight toothing) */
module arrow_wheel (modul, number_of_teeth, height, bore, engagement_angle = 20, angle_of_inclination = 0) {

    Height = height / 2;

    translate([0,0, height]) {
        union(){
            spur_gear (modul, number_of_teeth, height, bore, engagement_angle, angle_of_inclination); // bottom half
            mirror([0,0,1]) {
                spur_gear (modul, number_of_teeth, height, bore, engagement_angle, angle_of_inclination); // upper half
            }
        }
    }
}


/* Ring gear
    Modul = height of the tooth head above the subcircuit
    number_of_teeth = number of wheel teeth
    Height = height of the gear wheel
edge_width = width of edge from root circle
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = angle_of_inclination to the rotation axis, standard value = 0 ° (straight toothing) */
module hollow_wheel (modul, number_of_teeth, height, edge_width, engagement_angle = 20, angle_of_inclination = 0) {

    // Dimensions calculations
    ha = (number_of_teeth >= 20)? 0.02 * atan ((number_of_teeth / 15) / pi): 0.6; // Shortening factor tooth height
    d = modul * number_of_teeth; // pitch circle diameter
    r = d / 2; // circle radius
    alpha_stirn = atan(tan(engagement_angle) / cos(angle_of_inclination)); // angle_of_inclination in the face section
    db = d * cos(alpha_stirn); // Base diameter
    rb = db / 2; // Base radius
    c = modul / 6; // Head game
    da = (modul <1)? d + (modul + c) * 2.2: d + (modul + c) * 2; // Head circle diameter
    ra = da / 2; // Head circle radius
    df = d - 2 * modul * ha; // Foot circle diameter
    rf = df / 2; // Root circle radius
    rho_ra = acos(rb / ra); // maximum involute angle;
    // Evolvente starts on the basic circle and ends at the top of the circle
    rho_r = acos(rb / r); // involute angle at the pitch circle;
    // Evolvente starts on the basic circle and ends at the top of the circle
    phi_r = degree(tan (rho_r) -radian (rho_r)); // Angle to the point of the involute on a circle
    gamma = rad * height / (r * tan (90 - angle_of_inclination)); // Torsion angle for extrusion
    step = rho_ra / 16; // Evolvente is divided into 16 pieces
    tau = 360 / number_of_teeth; // Pitch angle

    // drawing
    rotate([0,0, -phi_r-90 * (1 + game) / number_of_teeth]) // Center tooth on x-axis;
    // makes alignment with other wheels easier
    linear_extrude(height = height, twist = gamma) {
        difference() {
            circle(r = ra + edge_width); // Outside circle
            union(){
                tooth_width = (180 * (1 + game)) / number_of_teeth + 2 * phi_r;
                circle(rf); // Foot circle
                for(red = [0: tau: 360]) {
                    rotate(red) {// Copy "number_of_teeth" and rotate
                        polygon (concat (
                            [[0,0]],
                            [for(rho = [0: step: rho_ra]) // from zero degree (basic circle)
                            // to maximum involute angle (head circle)
                            pol_to_kart (ev (rb, rho))],
                            [pol_to_kart (ev (rb, rho_ra))],
                            [for(rho = [rho_ra: step: 0]) // of the maximum involute angle (head circle)
                                // to zero degree (basic circle)
                            pol_to_kart ([ev (rb, rho) [0], tooth_width-ev (rb, rho) [1]])]
                                // (180 * (1 + game)) instead of 180,
                                // to allow play on the flanks
                            )
                        );
                    }
                }
            }
        }
    }
    
    echo ("outside diameter of the ring gear", 2 * (ra + edge_width));

}

/* Arrow ring gear; Uses the module "hollow_wheel"
    Modul = height of the tooth head above the part cone
    number_of_teeth = number of wheel teeth
    Height = height of the gear wheel
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = angle_of_inclination to the rotation axis, standard value = 0 ° (straight toothing) */
module arrow_ring_gear(modul, number_of_teeth, height, edge_width, engagement_angle = 20, angle_of_inclination = 0) {
    Height = height / 2;
    translate([0.0, height])
    union(){
        hollow_wheel (modul, number_of_teeth, height, edge_width, engagement_angle, angle_of_inclination); // bottom half
        mirror([0,0,1])
        hollow_wheel (modul, number_of_teeth, height, edge_width, engagement_angle, angle_of_inclination); // upper half
    }
}

/* Planetary gear; Uses the modules "arrow_wheel" and "arrow_wheel"
    Modul = height of the tooth head above the part cone
    number_of_teeth of the sun gear
    number_of_teeth of a planetary gear
    Height = height of the gear wheel
edge_width = width of edge from root circle
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = angle_of_inclination to the rotation axis, standard value = 0 ° (straight toothing) */
module planetary_gear_unit (modul, tooth_number_sun, tooth_number_planet, height, edge_width, bore, engagement_angle = 20, angle_of_inclination = 0) {

    // Dimensions calculations
    d_sonne = modul * tooth_number_sun; // Particle diameter of the sun
    d_planet = modul * tooth_number_planet; // Particle diameter planet
    axis_distance = (modul * tooth_number_sun + modul * tooth_number_planet) / 2; // Distance from sun gear / ring gear axis and planetary axis
    number_of_teeth = tooth_number_sun + 2 * tooth_number_planet; // number_of_teeth of the ring gear

    turning = is_even(tooth_number_planet); // Does the sun gear have to be turned?

    n_planet = (tooth_number_planet> tooth_number_sun)? Ggt (tooth_number_planet, tooth_number_sun): ggt (tooth_number_sun, tooth_number_planet);
    // number of planetary gears = largest common
    // Divisor of the number_of_teeth of the sun and
    // planetary gear

    // drawing
    rotate([0,0,180 / tooth_number_set]) {
        arrow_wheel (modul, tooth_number_sun, height, bore, engagement_angle, angle_of_inclination); // sun wheel
    }

    for(red = [0: 360 / n_planet: 360 / n_planet * (n_planet-1)]) {
        translate(kugel_zu_kart ([center_distance, 90, red]))
            arrow_wheel (modul, tooth_number_planet, height, bore, engagement_angle, angle_of_inclination); // Planet wheels
    }

    arrow_ring_gear(modul, number_of_teeth, inner_radius, height, edge_width, engagement_angle, angle_of_inclination); // Ring gear
}

/* bevel_gear
    Modul = height of the tooth head above the part cone; Indication for the outside of the cone
    number_of_teeth = number of wheel teeth
    partial_cone_angle = (half) angle of the cone, on which the respective other ring gear rolls
    tooth_width = width of the teeth from the outer side in the direction of the cone tip
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
angle_of_inclination = helix angle, standard value = 0 ° */
module bevel_gear(modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 0) {

    // Dimensions calculations
    d_aussen = modul * number_of_teeth; // Partial cone diameter on the cone base,
    // corresponds to the chord in the spherical section
    r_aussen = d_aussen / 2; // Partial cone radius on the cone base
    rg_aussen = r_aussen / sin(partial_cone_angle); // large cone radius for tooth outer side, corresponds to the length of the cone edge;
    rg_innen = rg_aussen - tooth_width; // Large conical radius for tooth inner side
    r_innen = r_aussen * rg_innen / rg_aussen;
    alpha_stirn = atan (tan (engagement_angle) / cos(angle_of_inclination)); // angle_of_inclination in the face section
    delta_b = asin(cos(alpha_stirn) * sin(partial_cone_angle)); // Basic cone angle
    da_aussen = (modul <1)? d_aussen + (modul * 2.2) * cos(partial_cone_angle): d_aussen + modul * 2 * cos(partial_cone_angle);
    ra_aussen = da_aussen / 2;
    delta_a = asin(ra_aussen / rg_aussen);
    c = modul / 6; // Head game
    df_aussen = d_aussen - (modul + c) * 2 * cos(partial_cone_angle);
    rf_aussen = df_aussen / 2;
    delta_f = asin(rf_aussen / rg_aussen);
    rkf = rg_aussen * sin(delta_f); // Radius of the cone foot
    hoehe_f = rg_aussen*cos(delta_f);                               // Höhe des Kegels vom Fußkegel

    echo ("partial cone diameter on the cone base =", d_aussen);

    // Sizes for complementary frustum
    height_k = (rg_aussen - tooth_width) / cos(partial_cone_angle); // Height of complementary cone for correct tooth length
    rk = (rg_aussen - tooth_width) / sin(partial_cone_angle); // Foot radius of the complementary cone
    rfk = rk * height_k * tan (delta_f) / (rk + height_k * tan (delta_f)); // Head radius of the cylinder for
    // Complementary truncated cone
    hoehe_fk = rk * height_k / (height_k * tan (delta_f) + rk); // height of complementary frustum

    echo ("bevel_gear =", hoehe_f-hoehe_fk);

    phi_r = kugelev (delta_b, partial_cone_angle); // Angle to the point of the involute on partial cone

    // Torsional angle gamma from helix angle
    gamma_g = 2 * atan (tooth_width * tan (angle_of_inclination) / (2 * rg_aussen - tooth_width));
    gamma = 2 * asin(rg_aussen / r_aussen * sin(gamma_g / 2));

    step = (delta_a-delta_b) / 16;
    tau = 360 / number_of_teeth; // Pitch angle
    start = (delta_b> delta_f)? delta_b: delta_f;
    mirror_point = (180 * (1-game)) / number_of_teeth + 2 * phi_r;

    // Zeic
    rotate([0,0, phi_r + 90 * (1-game) / number_of_teeth]) {// center tooth on x-axis;
    // makes alignment with other wheels easier
    translate([0,0, hoehe_f]) rotate(a = [0,180,0]) {
    union(){
    translate([0,0, hoehe_f]) rotate(a = [0,180,0]) {// truncated cone
        difference() {
            linear_extrude(height = hoehe_f-hoehe_fk, scale = rfk / rkf) circle(rkf);
            translate([0,0, -1]) {
                cylinder (h = hoehe_f-hoehe_fk + 2, r = bore / 2); // Drilling
            }
        }
    }
    for(red = [0: tau: 360]) {
        rotate(red) {// Copy "number_of_teeth" and rotate
            union(){
                if (delta_b> delta_f) {
                    // Tooth base
                    flankenpunkt_unten = 1 * mirror_point;
                    flankenpunkt_oben = kugelev (delta_f, start);
                    polyhedron (
                        points = [
                        kugel_zu_kart ([rg_aussen, start * 1.001, flankenpunkt_unten]), // 1 promille Overlapping with tooth
                        kugel_zu_kart ([rg_innen, start * 1.001,  flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_innen, start * 1.001, mirror_point-flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_aussen, start * 1.001, mirror_point-flankenpunkt_unten]),
                        kugel_zu_kart ([rg_aussen, delta_f, flankenpunkt_unten]),
                        kugel_zu_kart ([rg_innen, delta_f, flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_innen, delta_f, mirror_point-flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_aussen, delta_f, mirror_point-flankenpunkt_unten])
                        ],
                        faces = [[0,1,2], [0,2,3], [0,4,1], [1,4,5], [1,5,2], [2,5,6] , [2,6,3], [3,6,7], [0,3,7], [0,7,4], [4,6,5], [4,7,6]],
                        convexity = 1
                    );
                }
                // Tooth
                for(delta = [start: step: delta_a-step]) {
                    flankenpunkt_unten = kugelev (delta_b, delta);
                    flankenpunkt_oben = kugelev (delta_b, delta + step);
                    polyhedron (
                        points = [
                        kugel_zu_kart ([rg_aussen, delta, flankenpunkt_unten]),
                        kugel_zu_kart ([rg_innen, delta, flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_innen, delta, mirror_point-flankenpunkt_unten + gamma]),
                        kugel_zu_kart ([rg_aussen, delta, mirror_point-flankenpunkt_unten]),
                        kugel_zu_kart ([rg_aussen, delta + step, flankenpunkt_oben]),
                        kugel_zu_kart ([rg_innen, delta + step, flankenpunkt_oben + gamma]),
                        kugel_zu_kart ([rg_innen, delta + step, mirror_point-flankenpunkt_oben + gamma]),
                        kugel_zu_kart ([rg_aussen, delta + step, mirror_point-flankenpunkt_oben])
                        ],
                        faces = [[0,1,2], [0,2,3], [0,4,1], [1,4,5], [1,5,2], [2,5,6] , [2,6,3], [3,6,7], [0,3,7], [0,7,4], [4,6,5], [4,7,6]],
                        convexity = 1
                    );
                }
            }
        }
    }
    }
    }
    }
}

/* Arrow bevel_gear; Uses the module "bevel_gear"
    Modul = height of the tooth head above the subcircuit
    number_of_teeth = number of wheel teeth
    Height = height of the gear wheel
    Hole = diameter of the center hole
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = helix angle, standard value = 0 ° */
module arrow_bevel_gear(modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 0) {

    // Dimensions calculations

    tooth_width = tooth_width / 2;

    d_aussen = modul * number_of_teeth; // Partial cone diameter on the cone base,
    // corresponds to the chord in the spherical section
    r_aussen = d_aussen / 2; // Partial cone radius on the cone base
    rg_aussen = r_aussen / sin(partial_cone_angle); // large cone radius, corresponds to the length of the cone edge;
    c = modul / 6; // Head game
    df_aussen = d_aussen - (modul + c) * 2 * cos(partial_cone_angle);
    rf_aussen = df_aussen / 2;
    delta_f = asin(rf_aussen / rg_aussen);
    hoehe_f = rg_aussen*cos(delta_f);                           // Höhe des Kegels vom Fußkegel

    // Torsional angle gamma from helix angle
    gamma_g = 2 * atan (tooth_width * tan (angle_of_inclination) / (2 * rg_aussen - tooth_width));
    gamma = 2 * asin(rg_aussen / r_aussen * sin(gamma_g / 2));

    echo ("partial cone diameter on the cone base =", d_aussen);

    // Sizes for complementary frustum
    height_k = (rg_aussen - tooth_width) / cos(partial_cone_angle); // Height of complementary cone for correct tooth length
    rk = (rg_aussen - tooth_width) / sin(partial_cone_angle); // Foot radius of the complementary cone
    rfk = rk * height_k * tan (delta_f) / (rk + height_k * tan (delta_f)); // Head radius of the cylinder for
    // Complementary truncated cone
    hoehe_fk = rk * height_k / (height_k * tan (delta_f) + rk); // height of complementary frustum

    modul_innen = modul-tooth_width / rg_aussen;

    union(){
        // bottom half
        //modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 0
        bevel_gear(
            modul=modul,
            number_of_teeth=number_of_teeth,
            partial_cone_angle=partial_cone_angle-0,
            tooth_width=tooth_width,
            bore=bore,
            engagement_angle=engagement_angle,
            angle_of_inclination=angle_of_inclination);
        
        // upper half
        translate([0,0, hoehe_f-hoehe_fk])
        rotate(a = -gamma, v = [0,0,1])
        mirror([0,1,0])
        //modul, number_of_teeth, partial_cone_angle, tooth_width, bore, engagement_angle = 20, angle_of_inclination = 0
        bevel_gear(
            modul=modul_innen,
            number_of_teeth=number_of_teeth,
            partial_cone_angle=partial_cone_angle,
            tooth_width=tooth_width,
            bore=bore,
            engagement_angle=engagement_angle,
            angle_of_inclination=angle_of_inclination); 
        
    }
}

/* bevel_gear_pair with any axis_angle; Uses the module "bevel_gear"
Modul = height of the tooth head above the part cone; Indication for the outside of the cone
    number_of_teeth on the wheel
    number_of_teeth on the pinion
axis_angle = angle between the axes of the wheel and pinion
    tooth_width = width of the teeth from the outer side in the direction of the cone tip
    Hole_wheel = diameter of the center hole of the wheel
    bore_curler = diameter of the center bores of the pinion
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
angle_of_inclination = helix angle, standard value = 0 ° */
module bevel_gear_pair(modul, tooth_number_wheel, tooth_number_curve, axis_angle = 90, tooth_width, bore_wheel, bore_curler, engagement_angle = 20, angle_of_inclination = 0, together_build=1, show_a=1, show_b=1){
     
    // Dimensions calculations
    r_rad = modul * tooth_number_wheel / 2; // partial cone radius of the wheel
    delta_rad = atan (sin(axis_angle) / (tooth_number_curve / tooth_number_wheel + cos(axis_angle))); // Taper angle of the wheel
    delta_critical = atan (sin(axis_angle) / (tooth_number_wheel / tooth_number_curve + cos(axis_angle))); // // Cone angle of the pinion
    rg = r_rad / sin(delta_rad); // Radius of the ball
    c = modul / 6; // Head game
    df_ritzel = 4 * pi * rg * delta_critical / 360-2 * (modul + c); // Foot conical diameter on the large ball
    rf_ritzel = df_ritzel / 2; // Foot cone radius on the large sphere
    delta_f_ritzel = rf_ritzel / (2 * pi * rg) * 360; // Head cone angle
    rkf_ritzel = rg * sin(delta_f_ritzel); // Radius of the cone foot
    height_f_ritzel = rg * cos(delta_f_ritzel); // Height of the cone from the foot cone

    echo ("cone angle wheel =", delta_rad);
    echo ("angle_of_inclination pinion =", delta_critical);
     
    df_rad = 4 * pi * rg * delta_rad / 360-2 * (modul + c); // Foot conical diameter on the large ball
    rf_rad = df_rad / 2; // Foot cone radius on the large sphere
    delta_f_rad = rf_rad / (2 * pi * rg) * 360; // Head cone angle
    rkf_rad = rg * sin(delta_f_rad); // Radius of the cone foot
    height_f_rad = rg * cos(delta_f_rad); // Height of the cone from the foot cone

    echo ("height wheel =", height_f_rad);
    echo ("height pinion =", height_f_ritzel);

    turning = is_even(tooth_number_curve);

    // drawing
    // Wheel
    if(show_a)
    rotate([0,0,180 * (1-game) / tooth_number_wheel * turning])
    bevel_gear (modul, tooth_number_wheel, delta_rad, tooth_width, bore_wheel, engagement_angle, angle_of_inclination);

    // Pinions
    if(show_b){
        mirror([0,1,0])
        if (together_build == 1)
            //mirror([0,1,0])
            translate([-height_f_ritzel * cos(90-axis_angle), 0, height_f_rad - height_f_ritzel * sin(90-axis_angle)])
                rotate([0, axis_angle, 0])
                    bevel_gear (modul, tooth_number_curve, delta_critical, tooth_width, bore_curler, engagement_angle, angle_of_inclination);
        else
            translate([rkf_ritzel * 2 + modul + rkf_rad, 0,0])
                bevel_gear (modul, tooth_number_curve, delta_critical, tooth_width, bore_curler, engagement_angle, angle_of_inclination);
    }
}

/* Arrow-bevel_gear_pair with any axis_angle; Uses the module "pfeilkegelrad"
    Modul = height of the tooth head above the part cone; Indication for the outside of the cone
    number_of_teeth on the wheel
    number_of_teeth on the pinion
axis_angle = angle between the axes of the wheel and pinion
    tooth_width = width of the teeth from the outer side in the direction of the cone tip
    Hole_wheel = diameter of the center hole of the wheel
    bore_curler = diameter of the center bores of the pinion
    engagement_angle = engagement_angle, standard value = 20 ° according to DIN 867
    angle_of_inclination = helix angle, standard value = 0 ° */
module arrow_bevel_gear_pair (modul, tooth_number_wheel, tooth_number_curve, axis_angle = 90, tooth_width, bore_wheel, bore_curler, engagement_angle = 20, angle_of_inclination = 10, together_building = 1, show_a=1, show_b=1){
 
    r_rad = modul * tooth_number_wheel / 2; // partial cone radius of the wheel
    delta_rad = atan (sin(axis_angle) / (tooth_number_curve / tooth_number_wheel + cos(axis_angle))); // Taper angle of the wheel
    delta_critical = atan (sin(axis_angle) / (tooth_number_wheel / tooth_number_curve + cos(axis_angle))); // // Cone angle of the pinion
    rg = r_rad / sin(delta_rad); // Radius of the ball
    c = modul / 6; // Head game
    df_ritzel = 4 * pi * rg * delta_critical / 360-2 * (modul + c); // Foot conical diameter on the large ball
    rf_ritzel = df_ritzel / 2; // Foot cone radius on the large sphere
    delta_f_ritzel = rf_ritzel / (2 * pi * rg) * 360; // Head cone angle
    rkf_ritzel = rg*sin(delta_f_ritzel); // Radius of the cone foot
    height_f_ritzel = rg * cos(delta_f_ritzel); // Height of the cone from the foot cone

    echo ("cone angle wheel =", delta_rad);
    echo ("angle_of_inclination pinion =", delta_critical);
     
    df_rad = 4 * pi * rg * delta_rad / 360-2 * (modul + c); // Foot conical diameter on the large ball
    rf_rad = df_rad / 2; // Foot cone radius on the large sphere
    delta_f_rad = rf_rad / (2 * pi * rg) * 360; // Head cone angle
    rkf_rad = rg * sin(delta_f_rad); // Radius of the cone foot
    height_f_rad = rg * cos(delta_f_rad); // Height of the cone from the foot cone

    echo ("height wheel =", height_f_rad);
    echo ("height pinion =", height_f_ritzel);

    turning = is_even(tooth_number_curve);

    // Wheel
    if(show_a)
    rotate([0,0,180 * (1-game) / tooth_number_wheel * turning])
    arrow_bevel_gear(modul, tooth_number_wheel, delta_rad, tooth_width, bore_wheel, engagement_angle, angle_of_inclination);

    // Pinions
    if(show_b){
        mirror([0,1,0])
        if (together_building == 1)
            translate([-height_f_ritzel * cos(90-axis_angle), 0, height_f_rad-height_f_ritzel * sin(90-axis_angle)])
                rotate([0, axis_angle, 0])
                    arrow_bevel_gear(modul, tooth_number_curve, delta_critical, tooth_width, bore_curler, engagement_angle, angle_of_inclination);
        else
            translate([rkf_ritzel * 2 + modul + rkf_rad, 0,0])
                arrow_bevel_gear(modul, tooth_number_curve, delta_critical, tooth_width, bore_curler, engagement_angle, angle_of_inclination);
    }
}

//spur_gear (modul = 1, number_of_teeth = 30, height = 5, bore = 0, engagement_angle = 20, angle_of_inclination = 20);

//arrow_wheel (modul = 1, number_of_teeth = 30, height = 5, bore = 4, engagement_angle = 20, angle_of_inclination = 30);

//hollow_wheel (modul = 1, number_of_teeth = 30, height = 5, edge_width = 5, engagement_angle = 20, angle_of_inclination = 20);

//arrow_ring_gear (modul = 1, number_of_teeth = 30, height = 5, edge_width = 5, engagement_angle = 20, angle_of_inclination = 30);

//planetary_gear_unit (modul = 1, number_of_teeth = 15, number_of_teeth = 12, height = 6, edge_width = 5, bore = 4, engagement_angle = 20, angle_of_inclination = 30);

//bevel_gear(modul = 1, number_of_teeth = 30, partial_cone_angle = 45, tooth_width = 5, bore = 4, engagement_angle = 20, angle_of_inclination = 20);

//arrow_bevel_gear (modul = 1, number_of_teeth = 30, partial_cone_angle = 45, tooth_width = 5, bore = 4, engagement_angle = 20, angle_of_inclination = 30);

//bevel_gear_pair (modul = 1, tooth_number_wheel = 30, tooth_number_curve = 11, axis_angle = 100-10, tooth_width = 5, bore = 4, engagement_angle = 20, angle_of_inclination = 20, together_build = 1);

arrow_bevel_gear_pair (modul = 1, tooth_number_wheel = 30, tooth_number_curve = 11, axis_angle = 90, tooth_width = 5,
    bore_wheel = 4,
    bore_curler = 1,
    engagement_angle = 20, angle_of_inclination = 30, together_build = 1, show_a=1, show_b=1);

