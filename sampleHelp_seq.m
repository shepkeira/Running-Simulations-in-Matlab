function ev = sampleHelp_seq( dbn, readval, T )

% create empty evidence for T time steps
ev = cell(dbn.nnodes_per_slice, T);

% get index of observation variable
onodeTT = dbn.names('TaskTime');
onodeC = dbn.names('Correct');

for t=1:T,
  % sample value of variable
  oval = stoch_obs( 'TaskTime', dbn, readval );

  % store sampled value into evidence structure
  ev{onodeTT, t} = oval;


  oval = stoch_obs( 'Correct', dbn, readval );

  % store sampled value into evidence structure
  ev{onodeC, t} = oval;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function only used in this file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = stoch_obs( varname, dbn, parentval )
cpt = get_field( dbn.CPD{ dbn.names( varname )}, 'cpt' );
val = sampleRow( cpt( parentval, : ) );

