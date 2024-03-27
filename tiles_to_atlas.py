import numpy
import imageio.v3 as iio

tiles_folder = "/home/vassago/My_Projects/godot/Medieval_Castle_Asset_Pack/Tiles"

import os

files = os.listdir(tiles_folder)
files = list(map( lambda x: tiles_folder+"/"+x,   filter(lambda x: '.png' in x[-6:],files)))

images = []
for fi in files:
    fil = iio.imread(fi)
    images += [fil]

tmp_shape = list(images[0].shape)
template_shape = (32,32)

images = list(filter(lambda x: x.shape[:2] == template_shape  ,images))

#es bleiben 124 .. also 128 tiles .. 128 = 16*8, wir machen 16 cols, 8 rows

A = numpy.zeros((17*32,9*32,4),dtype=numpy.uint8)

for i in range(16):
    A[i*32:(i+1)*32,0:32] = images[i]