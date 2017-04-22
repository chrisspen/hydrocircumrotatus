diameter = 125;

if(1)
cylinder(d=diameter, h=10, center=true, $fn=100);

if(1)
translate([0,0,-15])
cylinder(d1=diameter/2, d2=diameter, h=5, center=true, $fn=100);

if(1)
translate([0,0,-50])
cylinder(d=diameter, h=50, center=true, $fn=100);
