clc; clear; close all;

%% 创建 A4 尺寸画布
figure;
% set(gcf, 'Units', 'inches', 'Position', [0 0 8.27 11.69]);
% set(gcf, 'PaperUnits', 'inches', 'PaperSize', [8.27 11.69], 'PaperPosition', [0 0 8.27 11.69]);
set(gcf, 'Units', 'inches', 'Position', [0 0 8.27 10]);
set(gcf, 'PaperUnits', 'inches', 'PaperSize', [8.27 10], 'PaperPosition', [0 0 8.27 10]);

%% 加载数据并自动获取行数
load('newUniqueWMatlasLabel_new.mat'); % 假设变量名为 newUniqueWMatlasLabel_new
data1 = newUniqueWMatlasLabel_new;
rows1 = size(data1,1);

% load('newUniqueWMatlasLabel_above20.mat'); % 假设变量名为 newUniqueWMatlasLabel_20
% data2 = newUniqueWMatlasLabel_above20;
% rows2 = size(data2,1);

%% 手动设置子图位置（归一化坐标）
% 定义左右边距、上下边距和子图间隔（归一化单位）
left_margin   = 0.22;  % 左边距
width_sub     = 0.70; % 子图宽度
bottom_margin = 0.05;  % 下边距
top_margin    = 0.03;  % 上边距
v_spacing     = 0.07;  % 两子图之间的垂直间隔

% 根据数据行数计算高度比例
sum_rows = rows1 + rows2;
avail_height = 1 - bottom_margin - top_margin - v_spacing;
height1 = avail_height * (rows1 / sum_rows);  % 第一子图高度
height2 = avail_height * (rows2 / sum_rows);  % 第二子图高度

% 计算子图在归一化坐标下的底部位置（从下往上）
bottom_pos2 = bottom_margin;                     % 第二子图位于最下方
bottom_pos1 = bottom_pos2 + height2 + v_spacing;   % 第一子图在第二子图上方

%% 第一幅子图（data1）
%subplot('Position', [left_margin, bottom_pos1, width_sub, height1]);

% 提取数据
names = data1(:,1);
values = cell2mat(data1(:,2));

% 绘制水平柱状图
b = barh(values, 'FaceColor', [0.07, 0.62, 1.00], 'EdgeColor', [0.07, 0.62, 1.00]);
b.FaceAlpha = 0.7;  % 设置填充透明度

% 设置坐标轴属性
ax = gca;
ax.YTick = 1:length(values);
ax.YTickLabel = names;
ax.FontName = 'Arial';
ax.FontSize = 12;
ax.TickLength = [0.005 0.005]; % 缩短刻度长度
ax.LineWidth = 1.5;              % 坐标轴线宽
box off;                     % 去掉外框

% xlabel('Number of contacts', 'FontName', 'Arial', 'FontSize', 20);
% title('White Matter Contact Distribution', 'FontName', 'Arial', 'FontSize', 20);

% 在每个柱状图上添加数值标签
xOffset = max(values) * 0.01;  % 根据最大值设定一个小偏移量
for i = 1:length(values)
    text(values(i) + xOffset, i, num2str(values(i)), ...
         'FontName', 'Arial', 'FontSize', 12, ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end
set(gca, 'FontName', 'Arial', 'FontSize', 12, 'LineWidth', 1.5);
print(gcf, 'figs1.png', '-dpng', '-r600');
%% 第二幅子图（data2）
% subplot('Position', [left_margin, bottom_margin, width_sub, height2]);
% 
% % 提取数据
% names = data2(:,1);
% values = cell2mat(data2(:,2));
% 
% % 绘制水平柱状图
% b = barh(values, 'FaceColor', [0.07, 0.62, 1.00], 'EdgeColor', [0.07, 0.62, 1.00]);
% b.FaceAlpha = 0.7;
% 
% % 设置坐标轴属性
% ax = gca;
% ax.YTick = 1:length(values);
% ax.YTickLabel = names;
% ax.FontName = 'Arial';
% ax.FontSize = 10;
% ax.TickLength = [0.005 0.005];
% ax.LineWidth = 1;
% box off;
% 
% xlabel('Number of contacts', 'FontName', 'Arial', 'FontSize', 10);
% title('Merged White Matter Contact Distribution (>20)', 'FontName', 'Arial', 'FontSize', 10);
% 
% % 为每个柱状体添加数值标签
% xOffset = max(values) * 0.01;
% for i = 1:length(values)
%     text(values(i) + xOffset, i, num2str(values(i)), ...
%          'FontName', 'Arial', 'FontSize', 10, ...
%          'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
% end
