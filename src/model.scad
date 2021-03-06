use <lib/openscad-extra/tube.scad>;
//use <lib/gear_library.scad>;
use <lib/getriebe.scad>;
use <lib/openscad-extra/torus.scad>;
use <lib/openscad-extra/countersink.scad>;

$fn = 100;

pi = 3.14159265359;

gap = 0.5;

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

gear_axle_slot = 2;
gear_axle_d = gear_axle_slot + gap;

angle_of_inclination = 30;

turntable_teeth = 105;
drive_gear_teeth = 51;
middle_gear_teeth = 21;
small_gear_teeth = 9;

//arch_diameter = 30;
arch_offset = -turntable_base_height/2/2+5/2;
//arch_angle = 36;
arch_angle = 30;
column_diameter = 5;

inside_diameter = diameter-outer_wall_thickness*2;

roller_diameter = 5;

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
                
                // middle support grate
                difference(){
                    union(){
                        // support grate
                        //for(i=[0:10:180])
                        for(i=[0:20:180])
                        rotate([0,0,i+5])
                        translate([0,0,outer_wall_thickness/2])
                        cube([diameter-outer_wall_thickness/2, 1, outer_wall_thickness], center=true);
                    }
                    // grate drainage hole
                    cylinder(d=(diameter-outer_wall_thickness*2)*1/3, h=100, center=true);
                }
                
                // inner support grate
                difference(){
                    union(){
                        // support grate
                        //for(i=[0:10:180])
                        for(i=[0:20:180])
                        rotate([0,0,i+5+10])
                        translate([0,0,outer_wall_thickness/2])
                        cube([diameter-outer_wall_thickness/2, 1, outer_wall_thickness], center=true);
                    }
                    // grate drainage hole
                    cylinder(d=(diameter-outer_wall_thickness*2)*1/10, h=100, center=true);
                }
                
            }
            
            // anti-drip lip
            cylinder(
                d2=drainage_hole_diameter+outer_wall_thickness,
                d1=drainage_hole_diameter,
                h=outer_wall_thickness/2, center=true);
            
        }
        
        // drainage hole
        //if(!simple)
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
    //difference(){
        union(){
            // outer most ring
            cylinder(d=diameter+20, h=h);
            
            // upper most ring
            translate([0,0,2])
            cylinder(d=diameter-(outer_lip_a+outer_lip_b)*2, h=h);
        }
        
        // ring cutout
        //translate([0,0,52-gap/2])
        //turntable_roller_ring(padding=gap);
    //}
}

module turntable_roller(){
    cylinder(d=5, h=outer_lip_e, center=true);
}

module vertical_axle_support(height=27.5, width=15, thickness=2){
    translate([0,0,0]) rotate([90,0,0]) cylinder(d=width, h=thickness, center=true);
    translate([0,0,-height/2]) cube([width, thickness, height], center=true);
}

module turntable_base(simple=0){
    
    cone_offset = -3.5;
    
    number_of_columns = 360/arch_angle;
    
    free_circumference = pi*diameter - number_of_columns*outer_wall_thickness;
    
    arch_diameter = free_circumference/12;
    
    vertical_bar_offset_z = 3.9;
    
    difference(){
        cylinder(d=diameter, h=turntable_base_height, center=true, $fn=100);
        cylinder(d=diameter-outer_wall_thickness*2, h=turntable_base_height+1, center=true, $fn=100);
        
        if(!simple)
        translate([0,0,arch_offset+1.45])
        cylinder(d=diameter+1, h=turntable_base_height/2, center=true, $fn=100);
        
        // archway cutouts
        //if(!simple)
        for(i=[0:arch_angle:180])
        rotate([0,0,i+arch_angle/2])
        translate([0,0,-arch_offset/2 - 5/2]){
            rotate([90,0,0])
            color("red") cylinder(d=arch_diameter, h=diameter*2, center=true);
            translate([0,0,-arch_diameter/2/2])
            cube([arch_diameter, diameter, arch_diameter/2], center=true);
        }
        
    }// end diff
    
    //axle pedestals
    intersection(){
        union(){
            
            difference(){
                for(i=[0:1])
                mirror([0,i,0]){
                    // floor bar
                    color("purple")
                    translate([0,39,-22.5])
                    cube([diameter,15,5], center=true);
                    
                    // water wheel axle vertical bar
                    color("red")
                    translate([15,36,vertical_bar_offset_z])
                    vertical_axle_support();
                }
                
                union(){
                    //water wheel axle left
                    color("blue")
                    translate([15,diameter/2,vertical_bar_offset_z])
                    rotate([90,0,0])
                    cylinder(d=gear_axle_slot, h=diameter*.5, center=true);
            
                    //water wheel axle right
                    color("blue")
                    translate([15,-diameter/2,vertical_bar_offset_z])
                    rotate([90,0,0])
                    cylinder(d=gear_axle_d, h=diameter*.5, center=true);
                }
            }
            
            // driver axle vertical bar
            color("red")
            translate([0,-42,4])
            vertical_axle_support();
           
        }
        
        cylinder(d=diameter, h=100, center=true);
    }
    
    // bulk head to strengthen screw hole
    //for(i=[0:1])
    //mirror([0,i,0])
    for(i=[0:10])
    if(i == 0 || i == 4 || i == 8)
    rotate([0,0,-i*arch_angle])
    color("green")
    translate([0,-60-cone_offset/2,3.9])
    rotate([90,0,0])
    cylinder(d2=12, d1=4, h=13+cone_offset, center=true);
    
    if(!simple){
        for(i=[0:arch_angle:360])
        rotate([0,0,i]){
            translate([0,-diameter/2+column_diameter/2,-10])
            cylinder(d=column_diameter, h=30, center=true);
            
            // bottom column base
            color("red")
            translate([0,-diameter/2+column_diameter/2,-21.5])
            cube([7,7,5+2], center=true);
            
            // big bottom column flair
            translate([0,-diameter/2+column_diameter/2,-20.5+5/2+.25])
            torus(r1=0.5, r2=column_diameter/2);
            
            // big top column flair
            translate([0,-diameter/2+column_diameter/2,3.5])
            torus(r1=0.5, r2=column_diameter/2);
            
        }
        
        // bottom ring flair
        translate([0,0,-21])
        tube(d=diameter-outer_wall_thickness*.5, t=outer_wall_thickness*.5, h=1);
        
    }
    
    // middle reinforcing ring
    //translate([0,0,5])
    //tube(d=diameter-outer_wall_thickness*.5, t=outer_wall_thickness*.5, h=1);
    translate([0,0,2])
    tube(d=diameter-outer_wall_thickness*0, t=outer_wall_thickness*1, h=.5);
    
    // extra arch support
    //translate([0,0,4])
    //tube(d=diameter-outer_wall_thickness+0.5, t=0.5, h=15);
    
}

module turntable_base_complete(simple=0){
    difference(){
        intersection(){
            translate([0,0,-(30+gap)]) turntable_base(simple=simple);
            translate([0,0,-57-gap]) turntable_mesh_outline_bottom();
        }
        //color("red")translate([0,-200/2,-200/2]) cube([200,200,200]);
        
        /*
        for(i=[0:10])
        if(i == 0 || i == 4 || i == 8)
        rotate([0,0,-i*arch_angle])
        translate([0,0,-26.6])
        translate([0,-diameter/2,0])
        rotate([90,0,0])
        make_countersink(inner=gear_axle_slot);
        */
        
        //if(!simple)
        //arch_recess_cutout();//production
     
        //translate([0,0,-3.5])
        //water_guide_holes();   
        color("blue")
        for(i=[0:2])
        rotate([0,0,120*i]) translate([0,-53+3,-26.6]) make_small_gear_cutout();

        // bottom drain holes
        for(i=[0:30:180])
            color("blue")
            translate([0,0,-55.5])
            rotate([90,0,i])
            cylinder(d=5, h=200, center=true);
    }
    
}

module make_small_gear_cutout(){
    translate([0,0,0])
    rotate([90,0,0]){
        color("blue")
        cylinder(d=55, h=6, center=true);
        color("red")
        cylinder(d=gear_axle_slot, h=30, center=true);
    }
}
/*
module arch_recess_cutout(count=180){
    difference(){
        //color("blue")
        translate([0,0,-23])tube(d=diameter+2, t=1.5, h=10);
    
        // archway cutouts
        for(i=[0:arch_angle:count])
        rotate([0,0,i+arch_angle/2])
        translate([0,0,-arch_offset/2 - 5/2 - 30])
        rotate([90,0,0])
        //color("red")
        cylinder(d=arch_diameter+5, h=diameter*2, center=true);
    }
}*/

module make_gears(a=1, b=1, show_axle=0, show_blades=1, show_cutouts=0){
    difference(){
        rotate([0,0,90])
        arrow_bevel_gear_pair(
            modul = 1,
            tooth_number_wheel = turntable_teeth,
            tooth_number_curve = drive_gear_teeth,
            axis_angle = 90,
            tooth_width = 5,
            //bore_wheel = 4,
            //bore_wheel = drainage_hole_diameter,
            bore_wheel=diameter - outer_wall_thickness*6.5,
            bore_curler=gear_axle_d,
            engagement_angle = 20,
            angle_of_inclination = 35,
            together_build = 1,
            show_a=a,
            show_b=b
        );
        
        if(show_cutouts){
            translate([0,-50,26.6])
            rotate([90,0,0]){
                difference(){
                    color("blue")
                    cylinder(d=40, h=10, center=true);
                    
                    cylinder(d=3+5, h=20, center=true);
                        
                    for(i=[0:6])
                    rotate([0,0,i*60])
                    translate([0,-10.5,0])
                    cube([3,20,20], center=true);
                }
            }
        }
    }
    
    if(b){
        translate([0,0,26.6]){
            
            // axle marker
            if(show_axle)
            rotate([90,0,0]){
                color("red")
                cylinder(d=1, h=1000, center=true);
            }
            
            if(show_blades){
                // blades
                for(i=[0:30:360])
                color("red")
                rotate([0,i,0])
                translate([0,-26+5,-17])
                rotate([0,50,0])
                translate([0,0,1])
                cube([1, 60, 13+2], center=true);
                
                // inner wall
                color("green") translate([0,-26+5,0]) rotate([90,0,0]) tube(d=27.5, t=1, h=60, center=true);
                
                // end cap
                color("red") translate([0,-3.5+12.5,0]) rotate([90,0,0]) tube(d=44, t=10, h=1, center=true);
            }
        }
    }
}

module make_drive_gear(simple=1, show_cutouts=1, extra_gear=0){
    
    hole_centering = 17;
    
    difference(){
        union(){
            if(simple){        
                translate([0,-50,27])
                rotate([90,0,0]){
                    color("blue")
                    cylinder(d=55, h=6, center=true);
                }
            }else{
                make_gears(
                    a=0,
                    b=1, show_axle=0, show_blades=0, show_cutouts=show_cutouts);
            }
            if(extra_gear){
                translate([0,0,26.6]){
                    color("orange")
                    translate([0,-13,0])
                    flat_middle_gear(flip=1);
                    
                    translate([0,-48,0])
                    rotate([90,0,0]){
                        color("blue")
                        cylinder(d=23, h=3, center=true);
                    }
                }
            }
        }
        
        // axle hole
        translate([0,-15,26.6])
        rotate([90,0,0])
        cylinder(d=gear_axle_d, h=100, center=true);
            
        // null space cutouts
        color("blue")
        for(i=[0:30:360])
            //translate([0,-15,26.6])
            translate([0,-15,26.6])
            rotate([0,i,0])
            translate([0,-15,-hole_centering])
            rotate([90,0,0])
            cylinder(d=7.5, h=100, center=true);

    }//end diff
}

module make_idler_gear(simple=1){
    hole_centering = 14.5;
    difference(){
        make_gears(
            a=0,//TODO:revert
            b=1, show_axle=0, show_blades=0, show_cutouts=!simple);
        
        // null space cutouts
        color("blue")
        for(i=[0:60:360])
            //translate([0,-15,26.6])
            translate([0,-15,26.6])
            rotate([0,i,0])
            translate([0,-15,-hole_centering])
            rotate([90,0,0])
            cylinder(d=13, h=100, center=true);
        
        // countersink cutout
        color("red")
        translate([0,-15+15,26.6])
        rotate([90,0,0])
        cylinder(d=43, h=100, center=true);
    }
}

module water_guide(hole_offset=-20, hole_size=15){
    rotate([0,-1,0]){
        color("blue")
        difference(){
            for(i=[0:1])
            mirror([0,i,0])
            rotate([10,0,0])
            translate([0,10/2,0])
            cube([diameter-outer_wall_thickness*2.5, 10, 1], center=true);
            
            translate([hole_offset,0,0])
            cylinder(d=hole_size-2, h=50, center=true);
        }
        
        // downward chute
        if(0)
        difference(){
            translate([hole_offset,0,-10])
            tube(d=hole_size, t=1, h=25, center=true);
        
            translate([15/2+hole_offset,0,0])
            cube([15,25,55], center=true);
             
            translate([0,0,-23])
            rotate([90,0,0])
            cylinder(d=50, h=50, center=true);
        }
        
    }
    
    difference(){
        intersection(){
            for(i=[0:1])
            mirror([i,0,0])
            translate([diameter/2-outer_wall_thickness-5/2,0,-3.5+.8])
            cube([5,20,12], center=true);
             
            union(){
                translate([0,0,20/2-2])
                cylinder(d=diameter-outer_wall_thickness*2-1, h=20, center=true);
            
                translate([0,0,-20/2-2])
                cylinder(d=diameter-outer_wall_thickness*2, h=20, center=true);
            }   
        }

        color("green")
        translate([-(diameter/2-outer_wall_thickness-5/2),0,7.25])
        cube([6,21,12], center=true);    
        
        water_guide_holes();
    }
    
}

module water_guide_holes(){
    for(i=[0:1])
    mirror([i,0,0])
    translate([diameter/2,0,-7])
    rotate([0,90,0])
    make_countersink(inner=20);
    
}

module water_wheel(show_axle=1){
    blade_extend = 4.5;
    end_cap_d = 44;
    rotate([0,7,0]){
        intersection(){
            union(){
                difference(){
                    union(){
                        // blades
                        for(i=[0:30:360])
                        color("red")
                        rotate([0,i,0])
                        //translate([0,-26+5,0])
                        translate([0,0,-17])
                        rotate([0,50,0])
                        translate([0,0,1+3-blade_extend/2])
                        cube([1, 60, 15+6+blade_extend], center=true);
                        
                        // inner wall
                        //color("green") translate([0,0,0]) rotate([90,0,0]) tube(d=27.5, t=1, h=60, center=true);
                        
                        // end cap
                        for(i=[0:1]) mirror([0,i,0])color("green") translate([0,30,0]) rotate([90,0,0]) cylinder(d=end_cap_d+7, h=1, center=true);
                        
                        // output gear
                        translate([0,-30.5-1,0])
                        //rotate([0,27,0])
                        rotate([90,0,0])
                        translate([0,0,0])
                        arrow_wheel(
                        //spur_gear(
                            modul=1, number_of_teeth=small_gear_teeth, height=3, bore=0, angle_of_inclination=angle_of_inclination);
                        
                        // gear extension support
                        color("purple")
                        translate([0,-30.5,0])
                        rotate([90,0,0])
                        translate([0,0,0])
                        cylinder(d=11, h=1);
                    
                    }

                    rotate([90,0,0])
                    color("red")
                    cylinder(d=gear_axle_d, h=100, center=true);
                
                    union(){
                        // end cutoff so wheel doesn't hit idler axle
                        translate([0,27.5,0])
                        rotate([90,0,0])
                        tube(d=56, t=56-5.5-end_cap_d, h=6.1, center=true);
                        
                        // tapered cutoff so wheel doesn't hit idler
                        color("blue")
                        translate([0,27.5-2.5-5,0])
                        rotate([90,0,0])
                        tube_cone(d1=56, d2=56+10, t=56-5.5-end_cap_d, h=10, center=true);
                    }
                    
            // interior axle spoke cutout
            difference(){
                rotate([90,0,0])
                tube(d=25, t=8.75-2, h=100, center=true);
                for(i=[0:1])
                rotate([0,90*i,0])cube([3,101,100],center=true);
            }
                    
                }// end diff

                // end cutoff wall
                union(){
                    // end cutoff so wheel doesn't hit idler axle
                    translate([0,27.5,0])
                    rotate([90,0,0])
                    tube(d=end_cap_d+1, t=1, h=6.1, center=true);
                    
                    // tapered cutoff so wheel doesn't hit idler
                    color("blue")
                    translate([0,27.5-2.5-5,0])
                    rotate([90,0,0])
                    tube_cone(d1=end_cap_d+1, d2=end_cap_d+1+10, t=1, h=10, center=true);
                }
            }
            
            // overall bounding shape
            rotate([90,0,0])cylinder(d=end_cap_d+7.5, h=100, center=true);
        }

        // interior axle wall
        rotate([90,0,0])tube(d=11.5, t=1, h=60.5, center=true);

        if(show_axle)
        rotate([90,0,0])
        color("red")
        cylinder(d=.5, h=100, center=true);
    }
}

module flat_middle_gear(flip=0){
    translate([0,-30.5-3*flip,0])
    //rotate([0,9,0])
    rotate([0,0,180*flip])
    rotate([90,0,0])
    translate([0,0,0])
    arrow_wheel(
    //spur_gear(
        modul=1,
        number_of_teeth=middle_gear_teeth,
        height=3,
        bore=gear_axle_d,
        angle_of_inclination=angle_of_inclination);
}

module middle_gear(){
    difference(){
        union(){
            color("orange")
            rotate([0,0,0])
            flat_middle_gear(flip=1);
            
            color("green")
            translate([0,-30.5-3,0])
            rotate([90,0,0])
            translate([0,0,0])
            cylinder(d=11, h=3);
            
            color("purple")
            translate([0,-30.5-3-3,0])
            rotate([90,0,0])
            translate([0,0,0])
            arrow_wheel(
            //spur_gear(
                modul=1, number_of_teeth=small_gear_teeth, height=3, bore=0, angle_of_inclination=angle_of_inclination);
        }
        rotate([90,0,0])
        cylinder(d=gear_axle_d, h=100, center=true);
    }
}

module water_trough(width=63, height=17+12+21, depth=30, thickness=1){
    wheel_cutout_d = 52.25;
    wheel_cutout_h = width-1.25;
    difference(){
        union(){
            difference(){
                // main mass
                color("purple")
                translate([0,0,height/2])
                cube([depth, width, height], center=true);
             
                // main wheel cutout
                color("red")
                translate([15,0,55.5-26.6])
                rotate([90,0,0])
                cylinder(d=wheel_cutout_d, h=wheel_cutout_h, center=true);   
                
                color("red")
                translate([15,0,55.5-26.6])
                rotate([90,0,0])
                cylinder(d=30, h=width*2, center=true);
            }
            translate([-12.5,0,6.5]){
                difference(){
                    cube([5,63+10,2.5], center=true);
                    
                    color("red")
                    for(i=[0:1])
                    mirror([0,i,0])
                    translate([0,31.5+2.5,0])
                    cylinder(d=2, h=100, center=true);
                }
                
            }
        }
        
        // useless mass removal
        translate([-12.5,0,6.5])
        color("green")
        rotate([0,45,0])
        cube([50,width-5,15],center=true);
    
        // top wheel cutout
        difference(){
            color("red")
            translate([15,0,55.5-26.6])
            translate([0,0,50/2])
            cube([wheel_cutout_d,wheel_cutout_h,50], center=true);    
            
            color("red")
            translate([0,18,100/2])
            cube([100, 1, 100], center=true);
        }
    }
    
    
    
}

//intersection(){
// main turntable top
if(0)
difference(){
    union(){
        intersection(){
            turntable_top(simple=1);
            translate([0,0,-6]) turntable_mesh_outline_top();
        }
        //rotate([0,180,0]) make_gears(a=1, b=0);//TODO:enable
    }
    //color("red")translate([0,-200/2,-200/2]) cube([200,200,200]);
    color("red")rotate([0,0,-90])translate([0,-200/2,-200/2]) cube([200,200,200]);
}

//color([0,0,1,0.25])
if(0){
    rotate([0,180,0])
    //translate([0,0,50])//TODO:remove
    make_drive_gear(simple=0, show_cutouts=0, extra_gear=1);
    
    rotate([0,0,120*1]) rotate([0,180,0]) make_drive_gear(simple=1);
    rotate([0,0,120*2]) rotate([0,180,0]) make_drive_gear(simple=1);
}

if(0){
    //rotate([0,0,120]) rotate([0,180,0]) make_idler_gear();
    rotate([0,0,-60]) translate([0,diameter/2-12,-27]) rotate([90,0,0]) import("../parts/idler.stl");
}

if(0)
translate([0,0,-3.5])water_guide();

// mockup of turntable top outline
if(0) translate([5,0,-6]) difference(){
    turntable_mesh_outline_top();
    color("blue")translate([0,-200/2,-200/2]) cube([200,200,200]);
}

if(0) translate([0,0,-3-roller_diameter/2-gap/2]) difference(){
    color("green") turntable_roller_ring();
    translate([1,-200/2,-200/2]) cube([200,200,200]);
}

// mockup of turntable bottom outline
if(0) translate([0,0,-57-gap]) difference(){
    turntable_mesh_outline_bottom();
    color("blue")translate([2,-200/2,-200/2]) cube([200,200,200]);
}

if(1) difference(){
    //translate([0,0,-100])//TODO:remove
    turntable_base_complete(simple=1);
    //intersection(){
    //    translate([0,0,-(30+gap)]) turntable_base();
    //    translate([0,0,-57-gap]) turntable_mesh_outline_bottom();
    //}
    color("red")rotate([0,0,180])translate([0,-200/2,-200/2]) cube([200,200,200]);
    //color("red")rotate([0,0,90])translate([0,-200/2,-200/2]) cube([200,200,200]);
    /*
    translate([0,0,-26.6])
    translate([0,-diameter/2,0])
    rotate([90,0,0])
    make_countersink();
    */
    //arch_recess_cutout(count=arch_angle);//test
    //arch_recess_cutout();//production
}

if(1)
    translate([15,0,-26.6]){
        //water_wheel(show_axle=1);
        rotate([0,10,0])rotate([90,0,0])import("../parts/wheel.stl");
    }

if(1)
    translate([0,-1,-26.6])
    //translate([0,-1,0])
    //rotate([0,-90,0])
    //translate([0,0,9])
    rotate([0,0,0])
    middle_gear();

if(1)
    translate([15,-1-6,-26.6])
    //translate([0,-1,0])
    //rotate([0,-90,0])
    //translate([0,0,9])
    rotate([0,0,0])
    middle_gear();

if(1)
    //translate([15,0,-26.6]){
    translate([0,0,-55.5])
    water_trough();
