$fn = 100;

// All units in mm.
diameter = 125;
outer_wall_thickness = 5;
turntable_base_height = 50;
drainage_hole_diameter = 10;

inside_diameter = diameter-outer_wall_thickness*2;

module turntable_top(){

    difference(){
        union(){
            difference(){
                cylinder(d=diameter, h=10, center=true, $fn=100);
                translate([0,0,-outer_wall_thickness])
                cylinder(d=inside_diameter, h=10, center=true, $fn=100);
                
                // drainage gradient
                color("blue")
                translate([0,0,outer_wall_thickness/2/2+outer_wall_thickness/2])
                cylinder(d2=inside_diameter+18, d1=drainage_hole_diameter, h=outer_wall_thickness/2+1, center=true);
                
                    
            }

            // outer support grate
            difference(){
                union(){
                    // support grate
                    for(i=[0:10:180])
                    rotate([0,0,i])
                    translate([0,0,outer_wall_thickness/2])
                    cube([diameter-outer_wall_thickness/2, 1, outer_wall_thickness], center=true);
                }
                // grate drainage hole
                cylinder(d=drainage_hole_diameter*7, h=100, center=true);
            }
            
            // inner support grate
            difference(){
                union(){
                    // support grate
                    for(i=[0:10:180])
                    rotate([0,0,i+5])
                    translate([0,0,outer_wall_thickness/2])
                    cube([diameter-outer_wall_thickness/2, 1, outer_wall_thickness], center=true);
                }
                // grate drainage hole
                cylinder(d=drainage_hole_diameter*3, h=100, center=true);
            }
        }
        
        // drainage hole
        cylinder(d=drainage_hole_diameter, h=100, center=true);
    }

}

module water_funnel(){
    cylinder(d1=diameter/2, d2=diameter, h=5, center=true, $fn=100);
}

module turntable_base(){
    difference(){
        cylinder(d=diameter, h=turntable_base_height, center=true, $fn=100);
        cylinder(d=diameter-outer_wall_thickness*2, h=turntable_base_height+1, center=true, $fn=100);
    }
}

if(1) difference(){
turntable_top(diameter);
//color("red")translate([0,-200/2,-200/2]) cube([200,200,200]);
}

if(0)
translate([0,0,-15])
water_funnel();

if(1)
translate([0,0,-50])
turntable_base();
