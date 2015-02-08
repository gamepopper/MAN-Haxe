# MAN-Haxe
This is the library version of the Procedural Noise Algorithms for Haxe project that was first submitted for PROCJAM 2014.

It's now renamed to MAN-Haxe, an acronym meaning **M**azes **A**nd **N**oises.

Try out the sample here: ![Demo](https://dl.dropboxusercontent.com/u/78698224/MANHaxe.swf "Flash Demo")

![alt-text](https://raw.githubusercontent.com/gamepopper/MAN-Haxe/master/sample/screenshot.png "MAN-Haxe Sample Screenshot")

## How to use the library
Using the library should be as easy as including classes in your project. You can either clone the repo and reference them, copy the folder into your project or reference them from [haxelib](http://lib.haxe.org/p/MAN-Haxe).

Each class has a *generateIntMatrix*, *generateMatrixString* and a *ConvertMatrixToString* static function, and Noise classes should also have a *generateFloatMatrix* function as well.

The Generate Int/Float Matrix functions will return a 2D array (e.g. Array*<*Array*<*Int*>>*) of numbers, floats will be between *0* and *1* while int will be between *0* and *NumOctaves-1*.

The Generate String functions will return a multi-line string separated by commas. The values will be in the same format as the Generate Int, with exceptions to the Maze class which have the specific values:
* 0 - Empty Spaces
* 1 - Walls
* 2 - Start Point
* 3 - End Point

## References
The following resources detail the algorithms used:

**Value Noise**
* http://devmag.org.za/2009/04/25/perlin-noise/

**Worley Noise**
* https://code.google.com/p/fractalterraingeneration/wiki/Cell_Noise

**Midpoint Displacement**
* https://code.google.com/p/fractalterraingeneration/wiki/Midpoint_Displacement
* http://stackoverflow.com/questions/26877634/midpoint-displacement-2d-algorithm-producing-unusual-patterns

**Prim's Algorithm**
* http://jonathanzong.com/blog/2012/11/06/maze-generation-with-prims-algorithm
