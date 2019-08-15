# Generate a mesh

I use MOOSE for large-scale geothermal reservoir models. These subsurface reservoirs can be modelled as porous media, hence I use the `Porous Flow Module` in MOOSE.
There are multiple options for generating a mesh. Geothermal reservoir models often are rectangular boxes containing geometrical information of the different geological layers. These layers need to be discretised for simulations in MOOSE.  
Generating such a _geometry_ (by geological modelling) is a different story, and there are multiple different software packages for geological modelling. For instance, I used [GemPy](https://github.com/cgre-aachen/gempy) to generate a (really, really) simplified model of a graben system.  
![gempy_graben](https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/gempy_graben.png)  

An example output file of GemPy is saved in `fids/lith_vector`. It is a 3D model whose dimensions are written in the file-header, followed by an array containing Litholoy-IDs for each cell in a gridded geological model.  

## Generate a Mesh from an existing geometry

MOOSE can also be used for meshing, i.e. discretising a model for running a simulation in MOOSE. For this, we set up an ´input file´ exclusively for generating a mesh. Note that it is not really necessary to generate the mesh in a separate file, but it really helps keeping the input file for the later simulation tidy.

### Syntax

A typical input file for mesh generation of a geological structure from a different source is as follows:

```python
[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 40
  ny = 10
  nz = 40
  xmin = 0.0
  xmax = 5000.0
  ymin = 0.0
  ymax = 4000.0
  zmin = -5000.0
  zmax = 1000.0
  block_id = '1 2 3 4'
  block_name = 'basement sandstone shale marl'
[]

[MeshModifiers]
  [./subdomains]
    type = AssignElementSubdomainID
    subdomain_ids = ' ' # here you paste the vector with your block_ids
  [../]
[]
```

Note, that for some software, there will be a difference in coordinate system (i.e. which dimension is `x`, `y`, or `z`) between the geological modelling software and MOOSE.  
For instance, between GemPy and MOOSE, `x` and `z` axes are switched. See the example input file `pct_voxel_mesh.i` as an example. A more detailed description is given in section [GemPy 2 MOOSE](content/GemPy2Moose.md).

**Note:**  
Since a recent update in MOOSE, the syntax for a mesh-generation input file changed. The **new** syntax is:  

```python
[MeshGenerators]
    [./gmg]
      type = GeneratedMeshGenerator
      dim = 3
      nx = 50
      ny = 50
      nz = 50
      xmin = 0.0
      xmax = 2000.0
      yim = 0.0
      ymax = 2000.0
      zmin = 0.0
      zmax = 2000.0
      block_id = '1 2 3 4 5 6'
      block_name = 'Main_Fault Sandstone_2 Siltstone Shale Sandstone_1 basement'
    [../]

    [./subdomains]
      type = ElementSubdomainIDGenerator
      input = gmg
      subdomain_ids = ' ' # here you paste the transformed block_id vector
    [../]
[]

[Mesh]
  type = MeshGeneratorMesh
[]
````

### Generate the mesh

What's left is how to create the meshed model file for MOOSE. This is done by running the compiled MOOSE executable witch the optional flag `--mesh-only`. So in my case, using the Porous Flow Module:

```bash
$path_to_moose/moose/modules/porous_flow/porous_flow-opt -i pct_voxel_mesh.i --mesh-only
```  
**Tip**:  
add the path to the executable `porous_flow_opt` to your `.bashrc` (`.bash_profile` on a MAC) as an `alias`, so you just have to type the alias for running a MOOSE model.  
```bash
alias mooseit='$path/to/moose/porous/flow/executable/porous_flow-opt -i'
```  
*Note*, replace `$path/to/moose/porous/flow/executable/` with your path. To get the Path, navigate to your `porous_flow-opt` executable and type `pwd`. The string given by the command line is your current path.  

With an alias set, you can easily run a model (e.g. the mesh generation) from your command line by typing:  
```bash
$ mooseit pct_voxel_mesh.i --mesh-only
```  

### Result

If the mesh generation was successful, you will get a file with a `.e` ending (e.g. pct_voxel_mesh_in.e). This file contains the MOOSE-mesh you can use for simulations. In my example here, it looks like this:  

![pct_mesh](https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/model_mesh.png)
