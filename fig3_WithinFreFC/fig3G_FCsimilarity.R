# 加载必要的库
library(ggplot2)
library(R.matlab)
library(ggsci)
library(tidyverse)
library(ggtext)
library(dplyr)
library(gghalves)
library(showtext)

# 设置工作环境
font_add('Arial', '/Library/Fonts/Arial.ttf')  # 修改字体路径
showtext_auto()

# 设置主题
theme_niwot <- function(){
  theme_bw() + 
    theme(text = element_text(family = "Arial"),
          axis.line.x = element_line(color="black", size = 0.6), 
          axis.line.y = element_line(color="black", size = 0.6),
          axis.text.y = element_text(family = "Arial", size = 13, color = "black"),
          panel.border = element_blank(),
          axis.title.x = element_text(margin = margin(t = 10), size = 13, family = "Arial", color = "black", hjust = 0.5, vjust = 3),
          axis.title.y = element_text(margin = margin(r = 10), size = 13, family = "Arial", color = "black", hjust = 0.5, vjust = 1),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(), 
          legend.title = element_blank(),
          legend.key = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.background = element_rect(color = "black", fill = "transparent", size = 2, linetype = "blank"))
}

# 加载数据
Rvalue <- readMat('github_replication/fig3_WithinFreFC/s02_FCloadSimilarity/sub-All_WM_FC_loadingEffect_interzerow.mat')

# 提取每个列表中的数据
corr1 <- Rvalue$loadingEffect.data[[1]]
corr2 <- Rvalue$loadingEffect.data[[2]]
corr3 <- Rvalue$loadingEffect.data[[3]]
corr4 <- Rvalue$loadingEffect.data[[4]]
corr5 <- Rvalue$loadingEffect.data[[5]]

# 提取每个矩阵的三列数据
matrix_corr1 <- corr1[[1]]
matrix_corr2 <- corr2[[1]]
matrix_corr3 <- corr3[[1]]
matrix_corr4 <- corr4[[1]]
matrix_corr5 <- corr5[[1]]

# 获取最大长度
max_length <- max(
  length(matrix_corr1[, 1]),
  length(matrix_corr2[, 1]),
  length(matrix_corr3[, 1]),
  length(matrix_corr4[, 1]),
  length(matrix_corr5[, 1])
)

# 对每列进行填充，使其长度一致
corr1_1 <- c(matrix_corr1[, 1], rep(NA, max_length - length(matrix_corr1[, 1])))
corr1_2 <- c(matrix_corr1[, 2], rep(NA, max_length - length(matrix_corr1[, 2])))
corr1_3 <- c(matrix_corr1[, 3], rep(NA, max_length - length(matrix_corr1[, 3])))
corr1_4 <- c(matrix_corr1[, 4], rep(NA, max_length - length(matrix_corr1[, 4])))

corr2_1 <- c(matrix_corr2[, 1], rep(NA, max_length - length(matrix_corr2[, 1])))
corr2_2 <- c(matrix_corr2[, 2], rep(NA, max_length - length(matrix_corr2[, 2])))
corr2_3 <- c(matrix_corr2[, 3], rep(NA, max_length - length(matrix_corr2[, 3])))
corr2_4 <- c(matrix_corr2[, 4], rep(NA, max_length - length(matrix_corr2[, 4])))

corr3_1 <- c(matrix_corr3[, 1], rep(NA, max_length - length(matrix_corr3[, 1])))
corr3_2 <- c(matrix_corr3[, 2], rep(NA, max_length - length(matrix_corr3[, 2])))
corr3_3 <- c(matrix_corr3[, 3], rep(NA, max_length - length(matrix_corr3[, 3])))
corr3_4 <- c(matrix_corr3[, 4], rep(NA, max_length - length(matrix_corr3[, 4])))

corr4_1 <- c(matrix_corr4[, 1], rep(NA, max_length - length(matrix_corr4[, 1])))
corr4_2 <- c(matrix_corr4[, 2], rep(NA, max_length - length(matrix_corr4[, 2])))
corr4_3 <- c(matrix_corr4[, 3], rep(NA, max_length - length(matrix_corr4[, 3])))
corr4_4 <- c(matrix_corr4[, 4], rep(NA, max_length - length(matrix_corr4[, 4])))

corr5_1 <- c(matrix_corr5[, 1], rep(NA, max_length - length(matrix_corr5[, 1])))
corr5_2 <- c(matrix_corr5[, 2], rep(NA, max_length - length(matrix_corr5[, 2])))
corr5_3 <- c(matrix_corr5[, 3], rep(NA, max_length - length(matrix_corr5[, 3])))

# 创建数据框
mydata <- data.frame(
  F1_1 = corr1_1, F1_2 = corr1_2, F1_3 = corr1_3, F1_4 = corr1_4,
  F2_1 = corr2_1, F2_2 = corr2_2, F2_3 = corr2_3, F2_4 = corr2_4,
  F3_1 = corr3_1, F3_2 = corr3_2, F3_3 = corr3_3, F3_4 = corr3_4,
  F4_1 = corr4_1, F4_2 = corr4_2, F4_3 = corr4_3, F4_4 = corr4_4,
  F5_1 = corr5_1, F5_2 = corr5_2, F5_3 = corr5_3
)

# 将数据框转换为长格式
myiris <- gather(mydata, Frequency_Band, Value)

# 为每列指定颜色
# 为每列指定颜色（确保与legend中的标签对应）
myiris$Group <- case_when(
  grepl("1$", myiris$Frequency_Band) ~ "0-back vs. 1-back",  # F1_1, F2_1, F3_1
  grepl("2$", myiris$Frequency_Band) ~ "0-back vs. 2-back",  # F1_2, F2_2, F3_2
  grepl("3$", myiris$Frequency_Band) ~ "1-back vs. 2-back",   # F1_3, F2_3, F3_3
  grepl("4$", myiris$Frequency_Band) ~ "blank",
)

myiris_clean <- na.omit(myiris)  # 删除包含NA的行


# 绘制小提琴图
myplot <- ggplot(data = myiris_clean, aes(x = Frequency_Band, y = Value)) +  
  geom_half_violin(trim = FALSE, color = "white",  
                   position = position_nudge(x = 0.3),  
                   side = 2, aes(fill = Group), alpha = 0.8, width = 1.3) +  
  geom_point(aes(y = Value, color = Group),  
             position = position_jitter(width = 0.2),  
             size = 3, alpha = 0.6, show.legend = FALSE) + 
  geom_boxplot(
    width = 0.5, outlier.shape = NA, alpha = 0.8,  
    color = 'black', coef = 1.5, aes(fill = Group),  
    show.legend = FALSE
  ) +
  theme(
    panel.background = element_rect(fill = "white", color = NA)  # 背景白色
  )+
  labs(y = NULL, x = NULL) +  
  scale_x_discrete(  
    breaks = c("F1_2", "F2_2", "F3_2", "F4_2", "F5_2"),  
    labels = c("4-8Hz", "8-13Hz", "13-30Hz", "30-70Hz", "70-120Hz")  
  ) +  
 
  scale_y_continuous(limits = c(0.80, 1), breaks = c(0.80, 0.90, 1.00)) +  
  theme_niwot() +  
  theme(  
    axis.text.x = element_text(family = "Arial", angle = 0, hjust = 0.4, size = 22, color = "black",margin = margin(t = 15)),  
    axis.text.y = element_text(family = "Arial", size = 22, color = "black", margin = margin(r = 15)),  
    axis.ticks.length = unit(-0.1, "cm"),  # 刻度向内
    axis.line.x = element_line(color = "black", size = 1),  
    axis.line.y = element_line(color = "black", size = 1),  
    legend.position = c(0.85, 0.9),
    legend.title = element_blank(),
    legend.box = "vertical",  # 确保是水平排列
    legend.spacing = unit(1.5, 'cm'),  # 适当增大横向间距
    legend.margin = margin(t = 20),
    legend.text = element_text(family = "Arial",  size = 22),
    legend.key.width = unit(0.6, "cm"),  # 可以调整legend项的宽度，确保足够空间 
    legend.key.height = unit(0.8, "cm"),
  ) +  
  scale_fill_manual(  
    values = c(  
      "0-back vs. 1-back" = "#F39B7FFF",  
      "0-back vs. 2-back" = "#4DBBD5FF",  
      "1-back vs. 2-back" = "#8491B4FF"  
    ), guide = guide_legend(override.aes = list(shape = NA))  # 隐藏形状 
  ) +  
  scale_color_manual(  
    values = c(  
      "0-back vs. 1-back" = "#F39B7FFF",  
      "0-back vs. 2-back" = "#4DBBD5FF",  
      "1-back vs. 2-back" = "#8491B4FF"  
    ), guide = guide_legend(override.aes = list(shape = NA))  # 隐藏形状 
  ) 
  # annotate("text", x = c(2, 6, 10, 14, 18), y = c(0.805, 0.805, 0.805, 0.805, 0.805),
  #          label = c(expression(theta), expression(alpha), expression(beta), 
  #                    expression(gamma), expression(paste("high ", gamma))),
  #         size = 8, family = "Arial")  # 确保字体支持加粗

# 打印图形
myplot
ggsave("Fig3G_FCSimilarity.pdf", plot = myplot, dpi = 600, width = 15, height = 8)