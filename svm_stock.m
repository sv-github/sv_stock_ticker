
% SVM ideas for classifying stock price 0,1,2,3,4   (-2, -1, 0, 1, 2)
% input: last 20 stock prices
% output: -2,-1 (for price drop) 0 (for no change) and 1,2 (for price increase)
% predice stock price 3 time points away from current point. 15 minutes away if using 5min MSN money data


% -- load in apple stock and volume as features, apply linear svm to learn
% weights, then can test on held out set of data.


% load stock data for 10 days
XX = zeros(10,158);        % 10 days, 158 features  (price and volume)

for i = 1:10                        
    stock_dir = sprintf('./aapl_days/appl_%g.xls', i);    % load 10 days
    D = xlsread(stock_dir);                               % price and volume
    X = D(:,[1 5]); X = X(:); X = X';    % example in row
    XX(i,:) = X;
end

% testing example --v--
D = xlsread('./aapl_days/appl_0.xls');
T = D(:,[1 5]); T = T(:); T = T';    % example in row   (T - Test)



% example has price from 1 to 79, and volume (79 + i)80 to 158 
% can use from 1:20 ... 60:79 as examples     , use end+3 - end for prediction labels

acc = zeros(35,1);

%%% --- tuning the 'window size'   --- %%%
for windo = 20:20
                % 10 window size                    (79-9-3)  9->window, 3->room for predicted values
                % 30   "

                               % 57 (not 60) examples per day, 57*10 = 570 examples total
X2 = zeros((79-windo-2)*10,windo*2);            %20 prices, 20 volumes
Y = zeros((79-windo-2)*10,1);



for j = 1:10      % 10 examples
    for i = 1:(79-windo-2)
        vect_data = zeros(1,windo*2);
        vect_data = XX(j, i:i+(windo-1));
        vect_data = [vect_data XX(j, 79+i:79+i+(windo-1))];
        X2((j-1)*(79-windo-2)+i,:) = vect_data;
        
        %label               %i+19+3
        Y((j-1)*(79-windo-2)+i,1) = XX(j,i+(windo+2)) - vect_data(1,windo);
    end
end

%%% don't have mclass svm     , can email it from work

%%% try svm for now

Y2 = sign(Y); % take sign of Y
Y2(Y2==0) = -1;   % replace zero values with -1

% - normalize features,       have to zscore 1:20 21:40 separately
for i = 1:size(X2,1)
    X2(i,:) = [zscore(X2(i,1:windo)) zscore(X2(i,windo+1:windo*2))];
end
   

a = svm;
a.optimizer = 'andre';    % had problem with default optimizer on first run

[tr m] = train(a,data(X2,Y2));              % matrix is close to singular or badly scaled
                                        %%%%  try perceptron  %%%%


%%% --- test on day_0, day before day_1 - 9/3/14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D = xlsread('./aapl_days/appl_0.xls');
% T = D(:,[1 5]); T = T(:); T = T';    % example in row   (T - Test)

T2 = zeros((79-windo-2),windo*2);
T_Y = zeros((79-windo-2),1);

for i = 1:(79-windo-2)
    vect_data = zeros(1,windo*2);
    vect_data = T(1, i:i+(windo-1));
    vect_data = [vect_data T(1, 79+i:79+i+(windo-1))];
    T2(i,:) = vect_data;
    
    %label               %i+19+3
    T_Y(i,1) = T(1,i+(windo+2)) - vect_data(1,windo);
end

% prepare data X,Y, and normalize
T_Y = sign(T_Y); % take sign of Y
T_Y(T_Y==0) = -1;   % replace zero values with -1

for i = 1:size(T2,1)
    T2(i,:) = [zscore(T2(i,1:windo)) zscore(T2(i,windo+1:windo*2))];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%
           %
           %  esting model
           %    
test_model=test(m,data(T2,T_Y),'class_loss')
% .2982 loss with 570 examples on normalized data (windo=20)
% .5075 loss with 670 examples     "               windo=10
% .383 loss with  470 examples     "               windo=30

acc(windo,1) = 1-test_model.Y;

end % loop window parameter                   % window of 20 has highest accuracy - 70%




test_model=test(m,data(T2,T_Y));          % not class loss, get predicted values


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% train svm again
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = svm;
a.optimizer = 'andre';    

[tr m] = train(a,data(X2(1:20,:),Y2(1:20,:)));              % try 30 examples - no longer singular matrix
test_model=test(m,data(T2,T_Y),'class_loss')
% .3509 loss with 20 examples (windo=20)
% .3333 loss with 10 examples  windo=20
% .6809 loss with 20 examples  windo=30








% get predicted results and plot test example stock price
plot(1:size(T2(:,20)),T2(:,20));

test_model=test(m,data(T2,T_Y));
result = test_model.X;
truthy = test_model.Y;



%%% --- may try normalizing data and then training, testing (maybe volume features are dominating price)




%%% --- tuning parameter: how many points to use as features (currently 20 points used
%%% --- tuning the 'window size'



% %%% --- trying perceptron,       svm has singular matrix
% 
% [tr_p, mdl]=train(dualperceptron('max_loops=1000'),data(X2,Y2));   % default perceptron
% 
% test_model=test(mdl,data(T2,T_Y),'class_loss')
% % .4737 loss with 570 examples on normalized data ,      1000 max loops




%%%%% NOTES :
%%%%%%%%%%%%%%
% Try using moving average and momentum instead of stock price, moving
% average smoothes out ambiguous /\/\/\/ up,down oscillations



