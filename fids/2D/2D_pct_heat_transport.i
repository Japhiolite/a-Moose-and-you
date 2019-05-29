# 2D heat transport

[Mesh]
  file = create_mesh_2D_in.e
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [./temp]
    initial_condition = 290
  [../]
[]

[Kernels]
  [./energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = temp
  [../]
  [./heat_conduction]
    type = PorousFlowHeatConduction
    variable = temp
  [../]
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'temp'
    number_fluid_phases = 0
    number_fluid_components = 0
  [../]
[]

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
    block = '10'
    dry_thermal_conductivity = '5.2 0 0    0 5.2 0   0 0 0'
  [../]
  [./thermal_conductivity_grabenfill]
    type = PorousFlowThermalConductivityIdeal
    block = '9'
    dry_thermal_conductivity = '2.0 0 0   0 2.0 0   0 0 0'
  [../]
  [./thermal_conductivity_top]
    type = PorousFlowThermalConductivityIdeal
    block = '6'
    dry_thermal_conductivity = '1.7 0 0   0 1.7 0   0 0 0'
  [../]
  [./thermal_conductivity_rest]
    type = PorousFlowThermalConductivityIdeal
    block = '8 7'
    dry_thermal_conductivity = '3.0 0 0   0 3.0 0   0 0 0'
  [../]
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 2.2
    density = 0.5
  [../]
[]

[BCs]
  # left = bottom, right = top
  [./left]
    type = DirichletBC
    boundary = left
    value = 400
    variable = temp
  [../]
  [./right]
    type = DirichletBC
    boundary = right
    value = 290
    variable = temp
  [../]
[]

[Preconditioning]
  [./prec]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = ' bcgs      bjacobi  1e-13      1e-10      10000'
  [../]
[]


[Executioner]
  type = Transient
  solve_type = Newton
  dtmax = 1e6
  end_time = 1e7
  petsc_options = '-ksp_converged_reason'
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 4
    #time_t = '0 100 200 1e8'
    #time_dt = '1 0.1 0.1 1000'
  [../]
  steady_state_detection = true
  steady_state_start_time = 1e4
  steady_state_tolerance = 1e-7
  # controls for linear iterations
  l_max_its = 50
  l_tol = 1e-7

  # controls for nonlinear iterations
  nl_max_its = 40
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-9
[]


[Outputs]
  [./out]
    type = Exodus
    execute_on = 'initial timestep_end'
  [../]
[]
