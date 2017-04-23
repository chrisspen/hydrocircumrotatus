use <model.scad>;

rotate([0,180,0])
union(){
    intersection(){
        turntable_top(simple=0);
        translate([0,0,-6]) turntable_mesh_outline_top();
    }
    rotate([0,180,0]) make_gears(a=1, b=0);
}
