%%%% build running time series, stock ticker

%%% Load stock price from MSN Money spreadsheet


%D = xlsread('appl_MarketPrice_9_17_14.xls');     % load appl price example
%D = xlsread('tsla_MarketPrice.xls');     % load tesla price example
%D = xlsread('ebay_MarketPrice.xls');
D = xlsread('tsla_google_data_5min.xlsx'); D(:,1)=[]; %clear first column    % load tesla price example, data from google text doc

xx = D(:,1); xx=xx';  vv = D(:,5); vv = vv';     % price and volume

% load svm weights
load('weights_10days_20window_70acc.mat');

vect = zeros(1,40);     % vector to hold current price,volume features

avg = zeros(size(xx));
momtm = zeros(1,size(xx,2));  momtm(1) = 0;   % initial momemtum is zero
bars = zeros(size(momtm));    bars(1) = 0;
lower = zeros(size(momtm));     upper = zeros(size(momtm));     % lower, upper bounds for error bars

%figure; grid on; hold on; set(gcf, 'Position', [50, 50, 1800, 950]);   % figure size
figure; grid on; hold on; set(gcf, 'Position', [50, 50, 1200, 670]);   % laptop size


hold_value = 0;        % holding value of trader, wallet value

for i=1:size(xx,2)
    
    % Create a uicontrol of type "text"     display wallet value
    %textbox = uicontrol('style','text','Position', [15 480 90 12]);     % [x y length height]
    textbox = uicontrol('style','text','Position', [15 480 120 15]);     % [x y length height]
    textString = sprintf('Wallet value: %g',hold_value);  %[20 500 100 12] for desktop
    set(textbox,'String',textString);

    
    % display(xx(i))
    
    % momentum           --- plot a bar at current point. a bar graph originating at current stock price.     p. ||
    %                                                                                                            ||
    if i==1
    else
        momtm(i) = mean(xx(max(i-3,1):i-1));   % take mean of last 3 prices
        bars(i) = xx(i)-momtm(i);            % momentum price - current price, calculate bar height
        lower(i) = min(bars(i),0);      upper(i) = max(bars(i),0);    % for positive and negative momentum case
    end
                                                     
    errorbar(1:size(xx(1:i),2),xx(1:i), lower(1:i), upper(1:i), 'r');    %errorbar(x,y,L,U); Lower, Upper bound for error bars
       
    
    % plot prices
    plot(1:i,xx(1:i),'k');
    
    % moving average
    avg(i) = mean(xx(max(i-5,1):i));
    plot(1:i, avg(1:i),'g');
    
    % x-axis limits
    if (i<30)
        xlim([0,40])
    elseif (i<50 && i>=30)
        xlim([0,60])
    else
        xlim([0,80])
    end
    
    %%% --- use weights  ----
    if (i>=20 && i<=76)  % must have 20 time points to predict
        vect(1:20) = zscore(xx(i-19:i));   vect(21:40) = zscore(vv(i-19:i));
        predict = sign(sum(vect.*weights));
        
        % textbox display up/ down
        % Create a uicontrol of type "text"     display prediction
        pred_box = uicontrol('style','text','Position', [15 320 90 60]);     % [x y length height]
        if (predict > 0)                               %[20 350 150 50]
            predString = sprintf('Prediction for\n 3rd next: \n^\n|');
        else
            predString = sprintf('Prediction for\n 3rd next: \n|\nv');
        end
        set(pred_box,'String',predString);
    end
    
    
    action = '';
    %action = input('>> ','s');    % wait for input (b-buy , s-sell)
    action = waitinput('', 5, 's');   action = action(1); % take the first character
    
    
    if (action == '');       % if no entry, continue
        return;
    elseif (action =='x')    % x - exit
        display('Exited');
        break;
    else 
        if (action == 'b');
            hold_value = hold_value - xx(i);  %baught stock, 'wallet' value decreases
            display(['Buy at ' num2str(xx(i)) '   Wallet value:' num2str(hold_value) ]);
            textString = sprintf('Wallet value: %g',hold_value);
            set(textbox,'String',textString);
        elseif (action == 's');
            hold_value = hold_value + xx(i);   %sold stock, value increases
            display(['Sell at ' num2str(xx(i)) '    Wallet value:' num2str(hold_value) ]);
            textString = sprintf('Wallet value: %g',hold_value);
            set(textbox,'String',textString);
        end
    end
    
   
end

hold off;  
legend('momentum', 'price', 'moving average');        % display legend


% % --- test accuracy of predictor ---     Run svm_stock.m to get model
% %(T - Test)  have xx,vv
% T = [xx vv];
% 
% T2 = zeros((79-windo-2),windo*2);
% T_Y = zeros((79-windo-2),1);
% 
% for i = 1:(79-windo-2)
%     vect_data = zeros(1,windo*2);
%     vect_data = T(1, i:i+(windo-1));
%     vect_data = [vect_data T(1, 79+i:79+i+(windo-1))];
%     T2(i,:) = vect_data;
%     
%     %label               %i+19+3
%     T_Y(i,1) = T(1,i+(windo+2)) - vect_data(1,windo);
% end
% 
% % prepare data X,Y, and normalize
% T_Y = sign(T_Y); % take sign of Y
% T_Y(T_Y==0) = -1;   % replace zero values with -1
% 
% for i = 1:size(T2,1)
%     T2(i,:) = [zscore(T2(i,1:windo)) zscore(T2(i,windo+1:windo*2))];
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
%         %%%%%%%
%            %
%            %  esting model
%            %    
% test_model=test(m,data(T2,T_Y),'class_loss')
% % .5614 loss (.4386 acc) for 9_17_14 stock
% 





% implement b- buy, s- sell    buttons



% SVM ideas for classifying stock price 0,1,2,3,4   (-2, -1, 0, 1, 2)
% input: last 20 stock prices
% output: -2,-1 (for price drop) 0 (for no change) and 1,2 (for price increase)
% predice stock price 3 time points away from current point. 15 minutes away if using 5min MSN money data


% -- load in apple stock and volume as features, apply linear svm to learn
% weights, then can test on held out set of data.



% load weights from svm model
% multiply by 20 stock prices (and volumes)
% display indicator : " predicted +/- 1 on the third next price "


% using trained weights to predict up/down for a time point 3 units away

