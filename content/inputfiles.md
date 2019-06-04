# The Input file 

The syntax shown in the section about [mesh generation](https://github.com/Japhiolite/a-Moose-and-you/blob/master/content/makemesh.md) already hints how MOOSE input files are structured. Basically, they are collections of `blocks`, each telling MOOSE a different model-specific information.  
Some of these information are crucial for a successful (and correct) simulation:  
* Equations to solve (what do I want to simulate)  
* A (numerical) grid, i.e. the geometry of the model
* Necessary parameters to populate said grid  
* Initial values for the primary variables (e.g. in most geothermal Simulations **T**emperature, and/or **P**ressure)  
* Boundary conditions for the (active) vairables

In the following, we go through a conductive temperature simulation of the structure generated in the [mesh generation](https://github.com/Japhiolite/a-Moose-and-you/blob/master/content/makemesh.md) section.

## Specify the grid

We generated the grid beforehand, but actually, we ran a MOOSE simulation where only the grid was generated. Because this can be the case: you build your grid at the beginning of a simulation. With complicated geometries in geological simulations however, this is not reasonable. So instead of generating a mesh, we can specify the file containing the grid:  
```
[Mesh]
  file = output_of_mesh_generation.e
[]
```

