function [J, grad] = linearRegCostFunction(X, y, theta, lambda)
%LINEARREGCOSTFUNCTION Compute cost and gradient for regularized linear 
%regression with multiple variables
%   [J, grad] = LINEARREGCOSTFUNCTION(X, y, theta, lambda) computes the 
%   cost of using theta as the parameter for linear regression to fit the 
%   data points in X and y. Returns the cost in J and the gradient in grad

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

cost = X*theta -y;

J = (1 / (2*m)) * sum( cost .^ 2 );
punish = (lambda/(2*m)) * sum(theta(2:length(theta)) .^ 2);
J = J + punish;

grad = (1 / m) * cost' * X ; 

regulation = (lambda/m)*theta;
regulation(1, 1) = 0;
grad = grad + regulation';


% =========================================================================

% Plot progress
global Jplotting;
Jplotting = [Jplotting J];
if mod(length(Jplotting), 10) == 0
  subplot(2, 3, 4);
  plot(Jplotting);
  title("J-Progress");
  pause(0.01);
endif


end
