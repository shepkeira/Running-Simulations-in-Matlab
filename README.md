# Running-Simulations-in-Matlab

## To run the simulations
1. Build the dbns with ```dbn_hints = mk_hints``` and ```dbn_help = mk_needhelp```
2. Using these models you can run the related simulations with ```sim_hints_decision(dbn_hints, ex)``` and ```sim_help_decision(dbn_help, ex)```
3. ex is the type of model we are building. 
   - Setting 1 (ex=1) is sampled_dbn
   - Setting 2 (ex=2) is preset variables view the code to change to preset values
   - Setting 3 (ex=3) is random values with a model that is reset with a value towards Help/Hint which can also be changed in the code

## Viewing the figures
You can recreate the figures yourself or view the precreated figures in their folders
- Plotting Your Results: figures from sim_help_decisions the title shows which combination of variables were set with setting 2 (correctness-tasktime)
- New Plot Setting2: figures from sim_both the title shows which combination of variales were set with setting 2 (open=timeopen-correct=correctness-task=tasktime)
- New Plot Setting3: figures from sim_both the title shows which combiantion of user models were used with setting 3 (Read-NeedHelp)
