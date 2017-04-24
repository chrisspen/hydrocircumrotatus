use <model.scad>;

difference(){
    translate([0,0,2.25])
    rotate([0,-1,0])
    rotate([180,0,0])
    water_guide();

    translate([0,0,-10/2])
    cube([200, 50, 10], center=true);
}
