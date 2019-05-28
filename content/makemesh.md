# Generate a mesh

I use MOOSE for large-scale geothermal reservoir models. These subsurface reservoirs can be modelled as porous media, hence I use the `Porous Flow Module` in MOOSE.
There are multiple options for generating a mesh. Geothermal reservoir models often are rectangular boxes containing geometrical information of the different geological layers. These layers need to be discretised for simulations in MOOSE.  
Generating such a _geometry_ (by geological modelling) is a different story, and there are multiple different software packages for geological modelling. For instance, I used [GemPy](https://github.com/cgre-aachen/gempy) to generate a (really, really) simplified model of a graben system.  
An example output file of GemPy is saved in `fids/lith_vector`. It is a 3D model whose dimensions are written in the file-header, followed by an array containing Litholoy-IDs for each cell in a gridded geological model.