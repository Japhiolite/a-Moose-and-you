# Run a model

The conductive solution of the graben model with a **Dirichlet** BC at the bottom looks like:  
![cond_graben](https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/conduction_graben_dirichlet.png)  

With a **Neumann** BC, on the other hand, it looks like:  
![cond_graben](https://raw.githubusercontent.com/Japhiolite/a-Moose-and-you/master/imgs/conduction_graben_neumann.png)  

Note that the applied Boundary Conditions (Dirichlet = 400 K, Neumann = 0.07 W m$^{-2}$ ) do not reflect the same thermal conditions. That is why the models differ so strongly. 
