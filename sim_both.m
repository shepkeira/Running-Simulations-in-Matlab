function prNeedHelp = sim_both( dbn_help, dbn_hint, ex )
% function prRead = sim_hints_decision( dbn, ex )
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex  = a specific setting used to generate evidence
%

engine_help = bk_inf_engine( dbn_help );   % set up inference engine 
engine_hint = bk_inf_engine( dbn_hint );   % set up inference engine 
T = 50;                          % define number of time steps in problem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a series of evidence in advance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1,
  ev_help = sample_dbn( dbn_help, T);
  ev_hint = sample_dbn( dbn_hint, T);
  evidence_help = cell( 3, T);
  evidence_hint = cell( 2, T);
  onodes_help   = dbn_help.observed;
  onodes_hint   = dbn_hint.observed;
  evidence_help( onodes_help, : ) = ev_help( onodes_help, : ); % all cells besides onodes are empty
  evidence_hint( onodes_hint, : ) = ev_hint( onodes_hint, : ); % all cells besides onodes are empty
elseif ex == 2,
  evidence_help = cell( 3, T);
  evidence_hint = cell( 2, T);
  for ii=1:T,
    evidence_hint{2,ii} = 2;  % 1 = too short; 2 = ontask; 3 = toolong; %timeopen
    evidence_help{3,ii} = 1;  % 1 = false; 2 = true                     %correct
    evidence_help{2,ii} = 3;  % 1 = too short; 2 = ontask; 3 = toolong; % task time
  end;
else
  readval = 2; % 1 = false; 2 = true
  hintval = 2; % 1 = false; 2 = true
  evidence_help = sampleHelp_seq( dbn_help, readval, T );
  evidence_hint = sampleHint_seq( dbn_hint, hintval, T );
end;
evidence_help
evidence_hint

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inference process: infer if user is reading hints over T time steps
% keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup results to be stored
belief_help = [];
exputil_help = [];
belief_hint = [];
exputil_hint = [];
subplot( 1, 2, 1 );    % setup plot for graph

% at t=0, no evidence has been entered, so the probability is same as the
% prior encoded in the DBN itself
%
prNeedHelp = get_field( dbn_help.CPD{ dbn_help.names('NeedHelp') }, 'cpt' );
belief_help = [belief_help, prNeedHelp(2)];

prRead = get_field( dbn_hint.CPD{ dbn_hint.names('Read') }, 'cpt' );
belief_hint = [belief_help, prRead(2)];

subplot( 1, 2, 1 );
plot( belief_help, 'b*-', 'DisplayName', 'Pr(NeedHelp)' );
hold on;
plot( belief_hint, 'ro-', 'DisplayName', 'Pr(Read)' );

% log best decision
[bestA, euHelp, euHint] = get_meu( prNeedHelp(2), prRead(2) );
exputil_help = [exputil_help, euHelp]; 
exputil_hint = [exputil_hint, euHint]; 
disp(sprintf('t=%d: best action = %s, euHint = %f, euHelp = %f', 0, bestA, euHint, euHelp));
subplot( 1, 2, 2 );
plot( exputil_help, 'b*-', 'DisplayName', 'EU(Help)');
hold on;
plot( exputil_hint, 'ro-', 'DisplayName', 'EU(Hint)');

% at t=1: initialize the belief state 
%
[engine_help, ll(1)] = dbn_update_bel1(engine_help, evidence_help(:,1));

marg_help = dbn_marginal_from_bel(engine_help, 1);

[engine_hint, ll(1)] = dbn_update_bel1(engine_hint, evidence_hint(:,1));

marg_hint = dbn_marginal_from_bel(engine_hint, 1);

prNeedHelp = marg_help.T;
belief_help = [belief_help, prNeedHelp(2)];

prRead = marg_hint.T;
belief_hint = [belief_hint, prRead(2)];

subplot( 1, 2, 1 );
plot( belief_help, 'b*-', 'DisplayName', 'Pr(NeedHelp)' );
hold on;
plot( belief_hint, 'ro-', 'DisplayName', 'Pr(Read)' );

% log best decision
[bestA, euHelp, euHint] = get_meu( prNeedHelp(2), prRead(2) );
exputil_help = [exputil_help, euHelp]; 
exputil_hint = [exputil_hint, euHint]; 
disp(sprintf('t=%d: best action = %s, euHint = %f, euHelp = %f', 0, bestA, euHint, euHelp));
subplot( 1, 2, 2 );
plot( exputil_help, 'b*-' );
hold on;
plot( exputil_hint, 'ro-' );

% Repeat inference steps for each time step
%
for t=2:T,
  % update belief with evidence at current time step
  [engine_help, ll(t)] = dbn_update_bel(engine_help, evidence_help(:,t-1:t));

  % update belief with evidence at current time step
  [engine_hint, ll(t)] = dbn_update_bel(engine_hint, evidence_hint(:,t-1:t));
  
  % extract marginals of the current belief state
  i = 1;
  marg_help = dbn_marginal_from_bel(engine_help, i);
  prNeedHelp = marg_help.T;

  marg_hint = dbn_marginal_from_bel(engine_hint, i);
  prRead = marg_hint.T;

  % log best decision
  [bestA, euHelp, euHint] = get_meu( prNeedHelp(2), prRead(2) );
  exputil_help = [exputil_help, euHelp]; 
  exputil_hint = [exputil_hint, euHint]; 
  disp(sprintf('t=%d: best action = %s, euHint = %f, euHelp = %f', t, bestA, euHint, euHelp));
  subplot( 1, 2, 2 );
  plot( exputil_help, 'b*-' );
  hold on;
  plot( exputil_hint, 'ro-' );
  xlabel( 'Time Steps' );
  ylabel( 'Expected Utility' );
  axis( [ 0 T -5 5] );

  % keep track of results and plot it
  belief_help = [belief_help, prNeedHelp(2)];
  belief_hint = [belief_hint, prRead(2)];
  subplot( 1, 2, 1 );
  plot( belief_help, 'b*-' );
  hold on;
  plot( belief_hint, 'ro-' );
  xlabel( 'Time Steps' );
  ylabel( 'Probability' );
  axis( [ 0 T 0 1] );
  pause(0.25);
end;

subplot( 1, 2, 1 );    % setup plot for graph
hold on;
legend('Pr(NeedHelp)', 'Pr(Read)');
hold off;
subplot( 1, 2, 2 );
hold on;
legend('EU(Help)', 'EU(HInt)');
hold off;

