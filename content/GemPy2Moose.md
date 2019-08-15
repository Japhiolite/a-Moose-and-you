# Export a GemPy model to MOOSE

This notebook briefly describes how to export a discretized geological model from [GemPy](https://github.com/cgre-aachen/gempy), so that it is directly usable by MOOSE. For this, we use the example model presented in [GemPy tutorial chapter 1, 1-1 Basics](https://nbviewer.jupyter.org/github/cgre-aachen/gempy/blob/master/notebooks/tutorials/ch1-1_Basics.ipynb). This model consists of five stratigraphic units (including the Basement, a default unit created by GemPy), which are folded and faulted after deposition.
The figure below shows a vertical cross-section through the geological voxel-model (i.e. spatially discretized) created by GemPy. This information is stored in a variable called `lith_block`, a 1D array. Assume that the GemPy model is called `geo_model`, then `lith_block` can be accessed via `geo_model.solutions.lith_block`.  

![gempy_fig](https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/GemPy_model_1.png)

## Method for exporting the voxel-model  

One possibility to export the voxel-model is to just save the `lith_block` array. However, this may cause problems with MOOSE, as GemPy and MOOSE populate a grid differently. Now what does this mean? The numbers in `lith_block` essentially just assign an integer number to a grid cell. This integer number represents the ID of a lithological unit. For ensuring that the correct lithological ID is assigned to the correct corresponding grid cell, it is important to know the starting point.  
That is, does `cell(1,1,1)` mean the _front-most_ cell in the lower left corner of a model (_lower-left-front_, like in MOOSE), or the _back-most_ cell in the upper left corner of a model (_upper-left-back_ like in GemPy) or something else?  
Thus, directly exporting the `lith_block` vector, will yield a twisted/mirrored model in MOOSE (where you still have to fiddle around with dimensions, e.g. x -> z and z -> x).  

This is why we implemented an export method in GemPy `export_moose_input(*kwargs)`, which can for example be called via:  

```python  
import gempy.utils.export as export  

export.export_moose_input(geo_model, path='../model_export/')
```

This then exports your current GemPy model `geo_model` to a MOOSE input file which can directly be read by MOOSE.  

```python
def export_moose_input(geo_model, path=None):
    """
    Method to export a 3D geological model as MOOSE compatible input.

    Args:
        path (str): Filepath for the exported input file

    Returns:

    """
    # get model dimensions
    nx, ny, nz = geo_model.grid.regular_grid.resolution
    xmin, xmax, ymin, ymax, zmin, zmax = geo_model.solutions.grid.regular_grid.extent

    # get unit IDs and restructure them
    ids = np.round(geo_model.solutions.lith_block)
    ids = ids.astype(int)

    liths = ids.reshape((nx, ny, nz))
    liths = liths.flatten('F')

    # create unit ID string for the fstring
    idstring = '\n  '.join(map(str, liths))

    # create a dictionary with unit names and corresponding unit IDs
    sids = dict(zip(geo_model.surfaces.df['surface'], geo_model.surfaces.df['id']))
    surfs = list(sids.keys())
    uids = list(sids.values())
    # create strings for fstring, so in MOOSE, units have a name instead of an ID
    surfs_string = ' '.join(surfs)
    ids_string = ' '.join(map(str, uids))

    fstring = f"""[MeshGenerators]
  [./gmg]
  type = GeneratedMeshGenerator
  dim = 3
  nx = {nx}
  ny = {ny}
  nz = {nz}
  xmin = {xmin}
  xmax = {xmax}
  yim = {ymin}
  ymax = {ymax}
  zmin = {zmin}
  zmax = {zmax}
  block_id = '{ids_string}'
  block_name = '{surfs_string}'
  [../]
  
  [./subdomains]
    type = ElementSubdomainIDGenerator
    input = gmg
    subdomain_ids = '{idstring}'
  [../]
[]

[Mesh]
  type = MeshGeneratorMesh
[]
"""
    if not path:
        path = './'
    f = open(path+'geo_model_units_moose_input.i', 'w+')

    f.write(fstring)
    f.close()

    print("Successfully exported geological model as moose input to "+path)
```

The central part of this method is the f-string, which creates a MOOSE-input file, which can be run in the same way as described in [Generate a mesh](https://github.com/Japhiolite/a-Moose-and-you/blob/master/content/makemesh.md).  

## Using the generated mesh  

Once the geological model is integrated in the mesh for MOOSE, we can set up a heat transport model, similarly as described in the [input-file](https://github.com/Japhiolite/a-Moose-and-you/blob/master/content/inputfiles.md) section. Different material parameters for the units can be defined in the `[Materials]` section:  

```python
[Materials]
  [./temperature]
    type = PorousFlowTemperature
    temperature = temp
  [../]
  [./porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  [../]
  [./thermal_conductivity_basement]
    type = PorousFlowThermalConductivityIdeal
    block = '6'
    dry_thermal_conductivity = '3.2 0 0    0 3.2 0   0 0 3.2'
  [../]
  [./thermal_conductivity_sandstone1]
    type = PorousFlowThermalConductivityIdeal
    block = '5'
    dry_thermal_conductivity = '2.5 0 0   0 2.5 0   0 0 2.5'
  [../]
  [./thermal_conductivity_shale]
    type = PorousFlowThermalConductivityIdeal
    block = '4'
    dry_thermal_conductivity = '1.8 0 0   0 1.8 0   0 0 1.8'
  [../]
  [./thermal_conductivity_siltstone]
    type = PorousFlowThermalConductivityIdeal
    block = '3'
    dry_thermal_conductivity = '1.7 0 0   0 1.7 0   0 0 1.7'
  [../]
  [./thermal_conductivity_sandstone2]
    type = PorousFlowThermalConductivityIdeal
    block = '2'
    dry_thermal_conductivity = '3.8 0 0   0 3.8 0   0 0 3.8'
  [../]
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 2.2
    density = 0.5
  [../]
[]
```

Once we successfully completed the simulation (in this case heat diffusion), we have a temperature model corresponding to the geological model built with GemPy.

<p align="center">
    <img src="https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/GemPy_model_Moose_temperature.png" alt="drawing" width="800"/>
</p>
