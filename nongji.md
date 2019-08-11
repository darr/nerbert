# 农机耕作路径与非耕作路径区分

## 前提假设

1. 上传点包含了坐标和位置文本。
2. 上传点数据包含时间戳
3. 上传点包含农机唯一ID

## 目的

主要区分农机在运行状态中是耕作状态和非耕作状态

## 基于人工指标的方法

假设农机在耕作状态运行轨迹多呈平行线，并且运行在低匀速状态。
农机在非耕作状态运行轨迹不规律，并且运行在相对高速状态。

注：上传数据点中包含时间戳和坐标，可以根据位置计算农机速度大小以及方向。

所以目前可以拿到这样的数据：

ID 坐标 位置文本 时间戳 速度 方向

首先根据ID将所有数据分类，即处理相同ID的数据。

现在能用的数据变成：

坐标 位置文本 时间戳 速度 方向

点数据中包含时间戳，所以可以根据时间戳生成运动轨迹线。
这条线是农机运行轨迹的一整条线。包含了农机的耕作路径和非耕作路径。

这是可以根据运行速度是否是低匀速，判断路径是耕作路径或者是非耕作路径。
据此，将农机运行轨迹切成多条。

这可以粗略分出耕作路径与非耕作路径。

进一步判断耕作路径：
仅仅通过低匀速来判断耕作路径，远远不够。可以进一步借助运行轨迹的方向：
比如，正常的耕作路径是规律的平行折线，线和线之间很少会出现交叉。

因此可以进一步对被判定为耕作路径的线，根据运行轨迹的方向改变，切成多条。
判断这些线之间的相交率。根据相交率很大，即判定为非耕作路径。
这个判定的前提假设是，农机的运动路径是规律，并且不复耕。

这里先不讨论对于复耕的判断。

因为我们数据中包含时间戳，时间戳可以作为一种判断农机是否耕作的辅助指标。
例如临近中午，农机很有可能在路上。工作时间，增加农机耕作的概率。

这时我们得到一条我们认为是耕作路径的线，这条线应该可以被抽象成一个地块的区域。
或者我们认为我们得到一个点集。这个点集边缘的联线会形成一个多边形。一般是矩形。

我们有坐标，可以算出这个多边形的面积。集合中的点数也可以算的。
可以根据面积和点数算出这个区域的点密度。这里的假设是农机上传数据的速率相同。

我们假设如果农机正常耕作这个点密度会维持在一定范围。
点密度过高或者过低都可以都可以判定农机在非耕作状态。

这里对农机耕作状态的判断，都偏向严格。 具体结果需要测试。
根据结果修改。

上面对农机耕作状态的判断，主要基于人工指标和假设。

## 基于学习的方法

这里的学习不是指机器学习，或者深度学习的算法。
是指人工的设置一个系统较多的通过人工设置的规则。
提高系统对于农机耕作和非耕作状态判断的准确率。

在人工的方法中，判断出耕作路径，会抽象出地块的概念。
也就是我们上面求到的耕作路径多边形。
将抽象出的置信度比较高的地块，连带地块的属性，边缘点，存入数据库。

同样的，我们也可以存储公路路径，或者如果有接口可以查询到一个上传的
坐标点是否在公路上。

这个数据库可以辅助判断一些不太容易判断的点或路径,是否为耕作路径。
比如，切分过的农机运动轨迹路线，可以与邻近的公路路径判断重合度，
如果重合度大，可以判断为非耕作路径。
同样，如果被包含在附近的地块区域内，活着相交，可以增大耕作路径的概率。

这个是通过历史数据，来辅助当前数据进行判断。
也可以通过当前高置信度的数据，比如地块，公路。来更新历史数据库。
这样提高判断的准确率。

历史数据中应该还有可挖掘点。

## 基于机器学习的方法。

用机器学习的方法，抽象这是一个二分类问题。

首先考虑用监督学习的方法。
用于监督学习的数据可以人工标注。
也可以不通人工标注。例如，可以用上面基于人工指标的方法，得到一些置信度比较高的数据。

我们可以拿出被认为是地块中的数据点做为正例。
被认为是公路的点做为负例子。

现在我们构造输入：
以单个点为单位，应该是不能学到有用的分类依据的。
以地块为单位作为输入，会造成输入序列长度不可控。
以线为单位作为输入，固定线长度。可以学到点在序列上的依赖性。

每个点的特征增加与上一个点和下一个点的距离。这个可以由这个点和上下点的坐标算的

每个点的特征：

坐标， 距上一个点的距离， 距下一个点的距离，速度，原始运动方向, 目前运动方向, 方向改变角度,

然后将获得数据切成等长的线。

这样每条线对应一个标记

我们构造了监督学习的输入。
然后就可以选取，监督学习二分类算法。
这样的机器学习算法可以尝试 感知机 朴素贝叶斯 SVM
基于神经网络的方法，可以尝试 多层神经网络 RNN
各种算法效果未知。
鉴于特征数，耕作状态的标准，k－近邻或许能意外的得到好的效果。


其次考虑基于非监督学习的方法。

利用跟上面监督学习中相似的特征，得到一条线的线特征，计算线之间的余弦相似度，做聚类。

或者使用 k均值聚类
