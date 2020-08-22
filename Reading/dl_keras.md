# Deep Learning with Python

## Chapter 1
* Kaggle竞赛两大主流方法(2016-2017年)
    * 结构化数据: 梯度提升机(gradient boosting machine) - XGBoost库
    * 图像分类等感知问题: Deep Learning - Keras库
* 深度学习爆发的算法层面的原因
    * 更好的激活函数
    * 更好的权重初始化方案
    * 更好的优化方案, 比如RMSProp和Adam
    * 其他有助于梯度传播的方法: batch normalization, residual connection, **深度可分离卷积**

## Chapter 2
### 2.1 初始神经网络
这一节展示了第一个Keras的例子
```python
# numpy中的dtype可以用字符串表示, 但是不推荐
train_images = train_images.astype('float32') / 255
# to_categorical 将整数label转换为one hot label
train_labels = to_categorical(train_labels)
```

### 2.2 神经网络的数据表示
* n维张量 = nD张量 = n轴张量 = n阶张量 (推荐)
* 维度既可以表示沿着某个轴上的元素个数(比如5D向量), 也可以表示张量中轴的个数(5D张量)
* 张量的三个关键属性:
    - 轴的个数 ndim
    - 形状 shape
    - 数据类型 dtype
* Numpy (以及大多数其他库) 中不存在字符串张量, 因为张量存储在预先分配的连续内存段中, 而字符串的长度是可变的, 无法用这种方式存储

## Chapter 3
### 3.1 神经网络剖析
* 层&模型
* 输入数据&目标
* 损失函数
* 优化器

#### 层 - 深度学习的基础组件
* 简单的向量数据(samples, feature): 全连接层(fully connected layer) / 密集连接层(densely connected layer)
* 序列数据(samples, timesteps, features): 循环层(recurrent layer) 比如Keras的LSTM层
* 图像数据(samples, height, width, color_depth): 二维卷积层 Keras的Conv2D

#### 模型 - 层构成的网络
模型是层构成的**有向无环图**, 常见的网络拓扑结构:
* 线性堆叠
* 双分支(two-branch)网络
* 多头(multihead)网络
* Inception模块

#### 损失函数&优化器
* 具有多个输出的网络可能具有多个损失函数, 但是梯度下降过程必须基于单个标量损失值, 需要将所有损失函数取平均, 变成一个标量值
* 二分类问题: 二元交叉熵(binary crossentropy)
* 多分类问题: 分类交叉熵(categorical crossentropy)
* 回归问题: 均方误差(mean-squared error)
* 序列学习问题: 联结主义时序分类(CTC, connectionist temporal classification)损失函数

### Keras简介
#### 重要特性
* 代码可以在CPU或GPU上无缝切换运行
* 用户友好API, 快速开发DL原型
* 内置支持卷积网络, 循环网络以及两者的任意组合
* 支持任意网络架构: 多输入或多输出模型, 层共享, 模型共享等等. 能够构建任意深度学习模型, 无论是生成式对抗网络还是神经图灵机

Keras是一个模型级的库, 不处理张量操作, 求微分等低层次的运算. 它依赖一个专门的, 高度优化的张量库来完成这些运算,
这个库就是Keras的后端引擎(backend engine), 有多种后端实现, 最常见的是Tensorflow

#### 典型的Keras工作流
1. 定义训练数据: 输入张量和目标张量
2. 定义层组成的模型, 将输入映射到目标
3. 配置学习过程(compile): 选择损失函数, 优化器和需要监控的指标
4. 调用模型的fit方法在训练数据上进行迭代

定义模型的两种方法, 一旦定义好了模型架构, 接下来的步骤是相同的
* Sequential类(仅用于层的线性堆叠)
* 函数式API(functional API, 用于层构成的有向无环图, 可以构建任意形式的架构)

## Chapter 4
### 4.1 机器学习的四个分支
* 监督学习
* 无监督学习
    - 无监督学习是数据分析的必备技能, 在解决监督学习之前, 为了更好地了解数据集, 它通常是一个必要步骤.
    - 尝试掌握该必备技能!
* 自监督学习
    - 自编码器
    - 时序监督学习: 给定视频中过去的帧来预测下一帧, 文本中前面的词预测下一个词
    - 取决你关注的是学习机制还是应用场景, 自监督学习可以重新被解释为监督学习或无监督学习
* 强化学习

**P.S.**
* 多标签分类(multilabel classification) 每个输入样本都可以分配多个标签, 每个样本的标签个数通常是可变的.
* minibatch中的样本数通常取2的幂, 这样便于GPU上的内存分配

### 4.2 评估机器学习模型
* 为什么需要 **训练集**, **验证集** 和 **测试集** ? 而不是仅仅只有训练集和测试集
因为超参数的调整本质上也是一种学习, 如果基于模型在测试集上的性能来调整模型配置, 很快就会导致模型在测试集上过拟合,
造成这一现象的关键在于信息泄露.

#### 三种经典评估方法:
1. 简单留出法: 简单地划分成训练集、验证集和测试集三个集合
    - 缺点: 可用数据过少时， 验证集和测试集没有代表性
2. K折交叉验证法: 将数据划分成K份, 依次以其中K-1份上训练, 剩余的1份上验证, 最后计算K个验证分数的平均值
3. 带有打乱数据的重复K折验证: 重复P次K折验证, 每次划分数据前打乱数据
    - 优点: 当可用数据较少时, 仍能相对准确地评估模型

#### 评估模型的注意事项:
1. 数据代表性
2. 时间箭头 (如果想根据过去预测未来, 应该确保测试集中所有数据都晚于训练集数据)
3. 数据冗余

### 4.3 数据预处理、特征工程和特征学习
#### 数据预处理
1. 向量化
    - 神经网络的所有输入和目标都必须是浮点数张量 (在特定情况下可以是整数张量)
2. 值标准化
    - 取值较小: 大部分值都应该在0~1之间
    - 同质性: 所有特征取值都应该在大致相同的范围内
    - 更严格的标准: 均值为0, 方差为1
3. 处理缺失值
    - 一般来说将缺失值设置为0是安全的, 只要0不是一个有意义的值
    - 如果测试数据中可能有缺失值, 而训练数据中没有, 应该人为生成一些有缺失值的数据

#### 特征工程
是指将数据输入模型之前, 利用你自己关于数据和机器学习算法(这里指神经网络)的知识对数据进行硬编码的变换(不是模型学到的), 以改善模型的效果.

本质: 用更简单的方式表述问题, 从而使问题变得更容易. 它通常需要深入理解问题.

特征工程对深度学习的帮助:
* 良好的特征仍然可以让你用更少的资源更优雅地解决问题.
* 良好的特征可以让你用更少的数据解决问题.

### 4.4 过拟合与欠拟合
* 机器学习的根本问题是 **优化** 和 **泛化** 之间的对立
* 为了解决过拟合, 最优的解决方法是获得更多的训练数据
* 次优解决方法是调整模型允许存储的信息量, 或对模型允许存储的信息加以约束 (正则化)
    - 减小网络的大小 (capacity)
    - 添加权重正则化 (L1正则化 / L2正则化)
    - 添加dropout正则化: 其核心思想是在层的输出值中引入噪声, 打破不显著的偶然模式, 如果没有噪声的话, 网络会记住这些偶然模式.

### 4.5 机器学习的通用工作流程
#### 1. 定义问题, 收集数据集
定义问题时的两个假设:
* 假设输出是可以根据输入进行预测的
* 假设可用的数据包含足够多的信息, 足以学习输入和输出之间的关系

对于非平稳问题(nonstationary problem)
* 不断地利用最新数据重新训练模型
* 或者在一个问题是平稳的时间尺度上收集模型

#### 2. 选择衡量成功的指标
1. 平衡分类问题 (每个类别的可能性相同)
    - 精度 (accuracy)
    - 接收者操作特征曲线下面积 (area under the receiver operating characteristic curve, ROC AUC)
2. 类别不平衡问题
    - 准确率 (precision)
    - 召回率 (recall)
3. 排序和多标签分类
    - 平均准确率均值 (mean average precision)

#### 3. 确定评估方法
只需选择三者之一, 大多数情况下, 第一种方法足以满足要求
* 留出验证集: 数据量很大时采用
* K折交叉验证: 当留出验证的样本量太少, 无法保证可靠性时采用
* 重复的K折验证: 当可用的数据很少, 同时模型评估又需要非常准确时采用

#### 4. 准备数据
* 应该将数据格式化为张量
* 张量的取值通常应该缩放为较小的值, 比如在[-1, 1]区间或者[0, 1]区间
* 如果不同的特征具有不同的取值范围 (异质数据), 那么应该做数据标准化
* 可能需要特征工程, 尤其对于小数据问题

#### 5. 开发比基准更好的模型
目标是获得**统计功效** (statistical power), 即开发一个小型模型, 能够打败纯随机的基准 (dumb baseline)

三个关键参数:
* 最后一层的激活
* 损失函数
* 优化器配置: 大多数情况下, 使用`rmsprop`及其默认的学习率是稳妥的

| 问题类型            | 最后一层激活 | 损失函数                  |
|---------------------|--------------|---------------------------|
| 二分类问题          | sigmoid      | binary_crossentropy       |
| 多分类、单标签      | softmax      | categorical_crossentropy  |
| 多分类、多标签      | sigmoid      | binary_crossentropy       |
| 回归到任意值        | 无           | mse                       |
| 回归到0~1范围内的值 | sigmoid      | mse / binary_crossentropy |

**为什么多分类、多标签用sigmoid作为激活函数?**

**损失函数选择的注意事项**
直接优化衡量问题成功的指标不一定总是可行的, 有时难以将其转化为损失函数. 损失函数需要满足:
* 只有小批量数据时即可计算 (理想情况下, 只有一个数据点时也可计算)
* 必须是可微的

#### 6. 开发过拟合的模型
为了找到欠拟合和过拟合的界限, 必须穿过它
* 添加更多的层
* 让每一层变得更大
* 训练更多的轮次

#### 7. 模型正则化与调节超参数
* 添加dropout
* 尝试不同的架构: 增加或减少层数
* 添加L1和/或L2正则化
* 尝试不同的超参数 (比如每层的单元个数或优化器的学习率)
* (可选) 反复做特征工程: 添加新特征或删除没有信息量的特征

## Chapter 5
### 5.1 卷积神经网络简介
#### 5.1.2 最大池化运算
不使用池化操作的问题:
* 不利于学习特征的空间层级关系, 因为没有下采样, 最后一层卷积层的感受野可能仍然过于局部, 不利提取整体特征
* 最后一层卷积层的维度可能过大, 导致最后一层卷积层和全连接层的参数数量过多, 导致严重的过拟合

最大池化的效果往往好于平均池化和步进卷积 (步幅大于1的卷积)
* 特征中往往编码了某种模式或概念在特征图的不同位置是否存在 (因此得名**特征图**)
* 查看输出的稀疏窗口 (通过步进卷积) 可能导致错过特征
* 对特征取平均可能会淡化特征 (平均池化)