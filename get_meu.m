function [action, eu_help, eu_hint] = get_meu( prNeedHelp, prRead )
% function [action, eu_help, eu_hint] = get_meu_help( prNeedHelp, prRead )
%

% set default
action = 'None';

% compute expected utility of each action
% EU(A) = sum_NeedHelp Pr(NeedHelp) x U(A, NeedHelp)
%
eu_none = 0;

eu_help = prNeedHelp * util_help( 2 ) + ...
          (1 - prNeedHelp) * util_help( 1 );

% compute expected utility of each action
% EU(A) = sum_Read Pr(Read) x U(A, Read)
%
eu_none = 0;

eu_hint = prRead * util( 2 ) + ...
          (1 - prRead) * util( 1 );



% override default if hinting is a better action
A = [eu_help, eu_hint, eu_none];
maximum = max(A);
x = find(A==maximum);
if x==1,
  action = 'Help';
elseif x==2,
  action = 'Hint';
else
    action = 'None';
end;
