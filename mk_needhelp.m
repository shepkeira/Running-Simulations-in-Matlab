function DBN = mk_needhelp

names = {'NeedHelp', 'TaskTime', 'Correct'};   % easier to refer to later
ss    = length( names );
DBN   = names;

% intra-stage dependencies
intrac = {...
'NeedHelp', 'TaskTime'; 'NeedHelp', 'Correct'};
[intra, names] = mk_adj_mat( intrac, names, 1 );
DBN = names;   % potentially re-ordered names

%inter-stage dependencies
interc = {...
'NeedHelp', 'NeedHelp'};
inter = mk_adj_mat( interc, names, 0 );

% observations
onodes = [ find(cellfun(@isempty, strfind(names,'TaskTime'))==0), ...
    find(cellfun(@isempty, strfind(names,'Correct'))==0) ];

% discretize nodes
NH      = 2;     % two hidden states
TT      = 3;     % three observable states
C      = 2;
ns     = [NH TT C];
dnodes = 1:ss;

% define equivalence classes
ecl1 = [1 2 3];
ecl2 = [4 2 3];

% create the dbn structure based on the components defined above
bnet = mk_dbn( intra, inter, ns, ...
  'discrete', dnodes, ...
  'eclass1', ecl1, ...
  'eclass2', ecl2, ...
  'observed', onodes, ...
  'names', names );
DBN  = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to define CPTs for 
% prior, Pr(NeedHelp0)
% transition function, Pr(NeedHelp_t|NeedHelp_t-1)
% observation function, Pr(TaskTime_t|NeedHelp_t)
% observation function, Pr(Correct_t|NeedHelp_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NeedHelp0    = 1;
TaskTime = 2;
Correct = 3;
NeedHelp1    = 4;

% prior, Pr(NeedHelp0)
% start with the assumption that its an equal change of needing help and
% not needing help
cpt = normalize( ones(NH,1) );
bnet.CPD{NeedHelp0} = tabular_CPD( bnet, NeedHelp0, 'CPT', cpt );

% transition function, Pr(NeedHelp_t|NeedHelp_t-1)
% NH0     NH1=false, true
%  false  0.75       0.25
%  true   0.2        0.8

% Given that you did not need help before I think likely you will not need
% help next time, however it is likely you will need help since appyling
% your learnings to a new situation can be difficult

% Given that you needed help before I think it is very likely you will need
% help again however there is a decent change that with help previously you
% will be able to complete the next task on your own

cpt = [.75 .2 .25 .8];
bnet.CPD{NeedHelp1} = tabular_CPD( bnet, NeedHelp1, 'CPT', cpt );

% observation function, Pr(TimeTask_t|NeedHelp_t)
% NH     time=short, onTask, long
% false  0.2         0.7     0.1 
% true   0.25        0.05    0.7      

% Given that the user does not need help, I think they would likely be on
% task. There is a small probability that the user is very fast at
% answering the question, and another smaller chance that they have for any
% number of reasons taken longer on the question (gotten distracted, had to
% redo the question, stopped to answer a text etc.)

% Given that the user does need help, I think they would likely take too
% long to answer a question. They would be struggling to come up with an
% answer. However there is a significant chance they just guess an answer
% very quickly, or are very fast to answer a wrong, or just submit an
% answer by mistake. There is also a small possibility they happen to
% answer on time, but still need help.
cpt = [.2 .25 ...
       .7 .05 ...
       .1 .7];
bnet.CPD{TaskTime} = tabular_CPD(bnet, TaskTime, 'CPT', cpt ); 

% observation function, Pr(Correct_t|NeedHelp_t)
% NH     correct=false,  true
% false  0.1             0.9
% true   0.5             0.5

% Given that the user does not need help it is very likely they get the
% correct answer however they could still get the wrong answer (e.g.
% misread the question or answer, enter the wrong answer by mistake, submit
% too early by accient, small algebra errors etc.)

% Givent that the user does need help, I think the user has about an even
% change of getting the question right or wrong. They might be able to
% guess their way into a correct answer or be able to get to the answer but
% not know why that works (such as following a guide without understanding
% it). They might have a friend tell them the correct answer or remember
% this problem from class and not know why that is correct etc.)
cpt = [.1 .5 ...
       .9 .5];
bnet.CPD{Correct} = tabular_CPD(bnet, Correct, 'CPT', cpt ); 

DBN = bnet;


