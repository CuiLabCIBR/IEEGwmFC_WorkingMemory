clc;clear;
% 使用randi函数一次性生成1到9之间的40个随机数  
randomNumbers(:,1) = randi([1, 9], 1, 40);  
% 显示生成的随机数  
disp(randomNumbers);