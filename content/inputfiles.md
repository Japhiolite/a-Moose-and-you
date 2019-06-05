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

## The Dictator

Heat and mass transport in the subsurface can usually be modelled as transport through a porous medium. Hence, in MOOSE we often use the PorousFlow module for that purpose.
If using the PorousFlow module, we **must** specify a so called [PorousFlowDictator](https://www.mooseframework.org/modules/porous_flow/dictator.html#the-porousflowdictator). 
  This object contains information about nonlinear variables in the module, the number of fluid phases (and components) etc. You can think of it as the base of the simulation you are setting up with the input file. You can read about the number of input parameters [here](https://www.mooseframework.org/source/userobjects/PorousFlowDictator.html).

In the example input file (2D heat conduction) attached here, we specify the `PorousFlowDictator` as follows:  
```python  
[GlobalParams]
  PorousFlowDictator = dictator
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'temp'
    number_fluid_phases = 0
    number_fluid_components = 0
  [../]
[]
```

Note the indentated brackets with `[./dictator]
[../]`? These can be treated as user-named collections of information, used for referencing in your input file. For instance, we define the Object `dictator` which gets called in the `GlobalParams` field above. We could name it as we want, e.g. `[./chancellor]
[../]`, but would need to change the object-call to `PorousFlowDictator = chancellor` in the `GlobalParams` field.

The PorousFlowDictator gets queried by other user-defined fields in an input file, such as `Materials` or `Kernels`. So it really is vital to a functioning simulation. 
