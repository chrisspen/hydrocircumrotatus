from __future__ import print_function, division

def get_force_lever(Fa, a, b):
    return a/b*Fa

def get_force_gear(Fa, driven_teeth, driving_teeth):
    ratio = driven_teeth/driving_teeth
    return Fa * ratio

# Before
#https://en.wikipedia.org/wiki/Lever#/media/File:Lever_(PSF).png
# Fb/Fa = a/b
water_wheel_radius = 22 #mm
driver_gear_radius = 25 #!driver gear teeth=51, radius=25mm?
tiny_gear_radius = 11/2.
tiny_gear_teeth = 9
medium_gear_radius = 9*3/2.
medium_gear_teeth = 21

Fa = 1
#!T1 = F1*a*T2 = F2*b
Fb = get_force_lever(Fa, a=water_wheel_radius, b=driver_gear_radius)
print('Fa:', Fa)
print('Fb:', Fb)

print('-')
# After
Fb1 = get_force_lever(Fa, a=water_wheel_radius, b=tiny_gear_radius)# output from water wheel small gear
print('Fb1:', Fb1)
Fb2 = get_force_gear(Fb1, driven_teeth=medium_gear_teeth, driving_teeth=tiny_gear_teeth)#water wheel small gear to middle gear
print('Fb2:', Fb2)

Fb2f = get_force_lever(Fb2, a=medium_gear_radius, b=driver_gear_radius)# output from water wheel small gear
print('Fb2f:', Fb2f)

Fb3 = get_force_lever(Fb2, a=medium_gear_radius, b=tiny_gear_radius)# middle gear to small gear
print('Fb3:', Fb3)
Fb4 = get_force_gear(Fb3, driven_teeth=medium_gear_teeth, driving_teeth=tiny_gear_teeth)#small gear to middle gear
print('Fb4:', Fb4)
Fb5 = get_force_lever(Fb4, a=medium_gear_radius, b=tiny_gear_radius)# middle gear to small gear
print('Fb5:', Fb5)

Fb6 = get_force_gear(Fb5, driven_teeth=medium_gear_teeth, driving_teeth=tiny_gear_teeth)#small gear to middle gear
print('Fb6:', Fb6)

Fb6f = get_force_lever(Fb6, a=medium_gear_radius, b=driver_gear_radius)# output from water wheel small gear
print('Fb6f:', Fb6f)
