
%%%% build running time series, stock ticker

xx = [ 45 44 46 47 48 47 48 47 46 49 49 49 50 52 54 50 51 52 53 54 55 54 53 52 51 50 49 48 47 46 44 43 46 47 48 48 48 49 48 49 49 50 50 50 50 49 48 49 50 50 50 50 51 52 52 51 52 51 51 50 50 50];

avg = zeros(size(xx));
momtm = zeros(1,size(xx,2));  momtm(1) = 0;   % initial momemtum is zero
bars = zeros(size(momtm));    bars(1) = 0;
lower = zeros(size(momtm));     upper = zeros(size(momtm));     % lower, upper bounds for error bars

figure; hold on; set(gcf, 'Position', [50, 50, 1800, 950]);   % figure size

for i=1:size(xx,2)
    % display(xx(i))
    pause(0.2)
    
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
   
end

hold off;  
legend('momentum', 'price', 'moving average');        % display legend


%%% --- use 'error bars' for momentum direction
xx=[2 2 3 4 4 5];

bars=[0 0 1 1 1 -2];

for i = 1:size(xx,2)
    lower(i) = min(bars(i),0);      upper(i) = max(bars(i),0);
end

                                               %errorbar(x,y,L,U); Lower, Upper bound for error bars
figure; errorbar(1:size(xx,2),xx, lower(1:size(xx,2)), upper(1:size(xx,2)), 'r');

