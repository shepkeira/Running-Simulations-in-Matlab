function val = util_help( needHelp )
% function val = util( readHints )
%
% action = is to give hint
% needHelp = 1 (false), 2 (true)
%
% utility_value \in [-5,+5]
%

% reference point
val = 0;

% doing stuff for the user gets a disruption penalty
val = val - 1; 

% help action given will largely depend on whether user needs help
if needHelp == 1,
  val = val - 4; %if we help the user when they do not need help, it will disrupt them and they are less likely to remember next time
else
  val = val + 5; %if we help the user when they need help, its the best outcome!
end;
