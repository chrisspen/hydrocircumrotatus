use <lib/openscad-extra/tube.scad>;
//use <lib/gear_library.scad>;
use <lib/getriebe.scad>;
use <lib/openscad-extra/torus.scad>;

$fn = 100;

// All units in mm.
diameter = 125;
outer_wall_thickness = 5;
turntable_base_height = 50;
drainage_hole_diameter = 10;

outer_lip_a = 1;
outer_lip_b = .5;
outer_lip_c = 1;
outer_lip_d = .25;
outer_lip_e = 1;
outer_lip_f = .25;
outer_lip_g = 1;

inside_diameter = diameter-outer_wall_thickness*2;

roller_diameter = 5;

gap = 0.5;

module turntable_top(extra_height=5, simple=0){

    difference(){
        union(){
            difference(){
                // main body
                translate([0,0,-extra_height/2])
                cylinder(d=diameter, h=10+extra_height, center=true, $fn=100);
                
                // inner cutout
                translate([0,0,-outer_wall_thickness-1/2])
                cylinder(d=inside_diameter, h=10+1, center=true, $fn=100);
                
                // drainage gradient
                if(!simple)
                //color("blue")
                translate([0,0,outer_wall_thickness/2/2+outer_wall_thickness/2])
                cylinder(d2=inside_diameter+18, d1=drainage_hole_diameter, h=outer_wall_thickness/2+1, center=true);

            }

            if(!simple){
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
                    cylinder(d=(diameter-outer_wall_thickness*2)*2/3, h=100, center=true);
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
                    cylinder(d=(diameter-outer_wall_thickness*2)*1/3, h=100, center=true);
                }
                
                // anti-drip lip
                cylinder(
                    d2=drainage_hole_diameter+outer_wall_thickness,
                    d1=drainage_hole_diameter,
                    h=outer_wall_thickness/2, center=true);
            }
            
        }
        
        // drainage hole
        if(!simple)
        cylinder(d=drainage_hole_diameter, h=100, center=true);
    }
    
}

module turntable_mesh_outline_top(h=50){
    
    inner_rise = 1;
    extra_outer = 10;
    
    // 1mm reference ring
    //translate([0,0,-2]) tube(d=diameter, t=1, h=1);
    
    // outer most ring
    translate([0,0,-1])
    tube(d=diameter+extra_outer, t=1/2+outer_lip_a+extra_outer/2-gap, h=h);
    
    // top most ring
    translate([0,0,inner_rise+roller_diameter/2-0.5/2])
    cylinder(d=diameter, h=h);
    
    // middle ring
    translate([0,0,inner_rise])
    tube(d=diameter, t=outer_lip_a+outer_lip_b+outer_lip_c, h=h);
    
    // inner most ring
    translate([0,0,inner_rise])
    cylinder(d=diameter-outer_wall_thickness*2+outer_lip_g*2, h=h);

}

module turntable_roller_ring(padding=0){
    translate([0,0,-2])
    tube(d=diameter-(outer_lip_a+outer_lip_b+outer_lip_c+outer_lip_d)*2+padding, t=outer_lip_e+padding, h=roller_diameter);
}

module turntable_mesh_outline_bottom(h=50){
    difference(){
        union(){
            // outer most ring
            cylinder(d=diameter+1, h=h);
            
            // upper most ring
            translate([0,0,2])
            cylinder(d=diameter-(outer_lip_a+outer_lip_b)*2, h=h);
        }
        
        // ring cutout
        translate([0,0,52-gap/2])
        turntable_roller_ring(padding=gap);
    }
}

module turntable_roller(){
    cylinder(d=5, h=outer_lip_e, center=true);
}

module water_funnel(){
    cylinder(d1=diameter/2, d2=diameter, h=5, center=true, $fn=100);
}

module turntable_base(simple=0){
    arch_diameter = 30;
    arch_offset = -turntable_base_height/2/2+5/2;
    
    arch_angle = 36;
    column_diameter = 5;
    
    difference(){
        cylinder(d=diameter, h=turntable_base_height, center=true, $fn=100);
        cylinder(d=diameter-outer_wall_thickness*2, h=turntable_base_height+1, center=true, $fn=100);
        
        translate([0,0,arch_offset+1.45])
        cylinder(d=diameter+1, h=turntable_base_height/2, center=true, $fn=100);
        
        // archway cutouts
        for(i=[0:arch_angle:180])
        rotate([0,0,i+arch_angle/2])
        translate([0,0,-arch_offset/2 - 5/2])
        rotate([90,0,0])
        color("red") cylinder(d=arch_diameter, h=diameter*2, center=true);
        
    }// end diff
    
    if(!simple){
        for(i=[0:arch_angle:360])
        rotate([0,0,i]){
            translate([0,-diameter/2+column_diameter/2,-10])
            cylinder(d=column_diameter, h=30, center=true);
            /*
            // small bottom flair
            translate([0,-diameter/2+column_diameter/2,-20])
            torus(r1=0.25, r2=column_diameter/2);
            
            // big bottom flair
            translate([0,-diameter/2+column_diameter/2,-20.5])
            torus(r1=0.5, r2=column_diameter/2);
            
            // small top flair
            translate([0,-diameter/2+column_diameter/2,3.5-0.5])
            torus(r1=0.25, r2=column_diameter/2);
            
            // big top flair
            translate([0,-diameter/2+column_diameter/2,3.5])
            torus(r1=0.5, r2=column_diameter/2);
            */
        }
        
        translate([0,0,-21.5])
        tube(d=diameter-outer_wall_thickness*.25, t=outer_wall_thickness*.75, h=1);
    }
    
}

module make_small_gear_cutout(){
    translate([0,0,0])
    rotate([90,0,0]){
        color("blue")
        cylinder(d=55, h=6, center=true);
        color("red")
        cylinder(d=1, h=1000, center=true);
    }
}

module water_cup(size=10){
    difference(){
        sphere(d=size);
        sphere(d=size-1*2);
        translate([0,0,size/2])cube([size*2, size*2, size], center=true);
        translate([0,-size/2,0])cube([size*2, size, size*2], center=true);
    }
}

module make_gears(a=1, b=1){
    rotate([0,0,90])
    arrow_bevel_gear_pair(
        modul = 1,
        tooth_number_wheel = 110-5,
        tooth_number_curve = 11+40,
        axis_angle = 90,
        tooth_width = 5,
        //bore_wheel = 4,
        //bore_wheel = drainage_hole_diameter,
        bore_wheel=diameter - outer_wall_thickness*6.5,
        engagement_angle = 20,
        angle_of_inclination = 35,
        together_build = 1,
        show_a=a,
        show_b=b
    );
    if(b){
        
        translate([0,0,26.6]){
            rotate([90,0,0]){
                color("red")
                cylinder(d=1, h=1000, center=true);
            }
            //for(i=[0:30:360])
            //rotate([0,i,0])translate([0,-49,-17])rotate([0,-90,0])scale([1,10,1])water_cup();
            
            // blades
            for(i=[0:30:360])
            rotate([0,i,0])
            translate([0,-26,-17])
            rotate([0,45,0])
            cube([1, 45, 13], center=true);
            
            // inner wall
            color("green")translate([0,-26,0]) rotate([90,0,0]) tube(d=27.5, t=1, h=45, center=true);
            
            // end cap
            color("red") translate([0,-3.5,0]) rotate([90,0,0]) tube(d=45, t=10, h=1, center=true);
        }
    }
}

//intersection(){
// main turntable top
if(1) difference(){
    intersection(){
        turntable_top(simple=1);
        translate([0,0,-6]) turntable_mesh_outline_top();
    }
    color("red")translate([0,-200/2,-200/2]) cube([200,200,200]);
}

rotate([0,180,0]) make_gears(a=1, b=1);
//}


//color("blue")
//translate([0,-53+3,-26.6])make_small_gear_cutout();

// mockup of turntable top outline
if(0) translate([5,0,-6]) difference(){
turntable_mesh_outline_top();
color("blue")translate([0,-200/2,-200/2]) cube([200,200,200]);
}

if(1) translate([0,0,-3-roller_diameter/2-gap/2]) difference(){
color("green") turntable_roller_ring();
translate([1,-200/2,-200/2]) cube([200,200,200]);
}

// mockup of turntable bottom outline
if(0) translate([0,0,-57-gap]) difference(){
turntable_mesh_outline_bottom();
color("blue")translate([2,-200/2,-200/2]) cube([200,200,200]);
}

if(0)
translate([0,0,-15])
water_funnel();

if(1) difference(){
    intersection(){
        translate([0,0,-(30+gap)]) turntable_base();
        translate([0,0,-57-gap]) turntable_mesh_outline_bottom();
    }
    color("red")translate([0,-200/2,-200/2]) cube([200,200,200]);
}

