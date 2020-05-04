import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'widget/FluttieAnimationRootWidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class PageState<T extends StatefulWidget> extends State<T>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List items = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // 页面的生命周期，是否在前台或者后台的判断
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        print('这个是状态11111111');
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        print('这个是状态222222>>>>...前台');
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        print('这个是状态33333>>>>...后台');
        break;
      case AppLifecycleState.detached:
        print('这个是状态44444>>>>...好像是断网了');
        break;
    }
  }

  openTwoWidget() {
    _refreshController.requestTwoLevel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;

  disableLoadMore() {
    return false;
  }

  int page = 1;

  getSize() {
    return 10;
  }

  refresh() {
    _refreshController.requestRefresh();
  }

  void onRefresh() async {
    if (mounted) setState(() {});
    page = 1;
    try {
      items = await getData(page);
      _refreshController.refreshCompleted();
      if (items == null || items.length < getSize()) {
        _refreshController.loadNoData();
      }
    } catch (e) {
      print('获取数据出错' + e.toString());
      _refreshController.refreshFailed();
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<List> getData(int page);

  void onLoading() async {
    try {
      page++;
      List list = await getData(page);
      items.addAll(list);
      if (list == null || list.length < getSize()) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
      if (mounted) setState(() {});
    } catch (e) {
      print('加载数据出错' + e);
      _refreshController.loadFailed();
    }
  }

  List get pageData => items;

  void onSupportVisible() {}

  void onSupportInvisible() {}

  @override
  Widget build(BuildContext context) {
    final two = buildTwoLevelWidget();
    final Color cardColor = Theme.of(context).cardColor;
    return VisibilityDetector(
      onVisibilityChanged: (VisibilityInfo info) {
        debugPrint("${info.visibleFraction} of my widget is visible");
        if (info.visibleFraction == 1.0) {
          onSupportVisible();
        } else {
          onSupportInvisible();
        }
      },
      child: RefreshConfiguration(
        enableScrollWhenTwoLevel: two != null,
        headerTriggerDistance: 80.0,
        // 自定义回弹动画,三个属性值意义请查询flutter api
        maxOverScrollExtent: 120,
        // 可以通过惯性滑动触发加载更多
        child: Scaffold(
          appBar: appBar(),
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: !disableLoadMore(),
            enableTwoLevel: two != null,
            header: TwoLevelHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              textStyle: TextStyle(color: Colors.white),
              displayAlignment: TwoLevelDisplayAlignment.fromTop,
              twoLevelWidget: two,
              failedIcon: Icon(Icons.error, color: cardColor),
              completeIcon: Icon(Icons.done, color: cardColor),
              releaseIcon: Icon(Icons.refresh, color: cardColor),
              idleIcon: Icon(Icons.arrow_downward, color: cardColor),
            ),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("上拉加载");
                } else if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("加载失败！点击重试！");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("松手,加载更多!");
                } else {
                  body = Text("我是底线");
                }
                return Container(
                  height: 50,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: onRefresh,
            onLoading: onLoading,
            child: buildAnimatedSwitcher(),
          ),
        ),
      ),
      key: Key('sd'),
    );
  }

  Widget buildAnimatedSwitcher() {
    return buildWidget();
  }

  bool isIdle = false;

  Widget buildWidget() {
    switch (_refreshController.headerStatus) {
      case RefreshStatus.idle:
        if (isIdle) return items.length == 0 ? buildEmptyWidget() : buildBody();
        break;
      case RefreshStatus.canRefresh:
        // TODO: Handle this case.
        break;
      case RefreshStatus.refreshing:
        break;
      case RefreshStatus.completed:
        isIdle = true;
        return items.length == 0 ? buildEmptyWidget() : buildBody();
        break;
      case RefreshStatus.failed:
        return buildFailWidget();
        break;
      case RefreshStatus.canTwoLevel:
        // TODO: Handle this case.
        break;
      case RefreshStatus.twoLevelOpening:
        // TODO: Handle this case.
        break;
      case RefreshStatus.twoLeveling:
        // TODO: Handle this case.
        break;
      case RefreshStatus.twoLevelClosing:
        // TODO: Handle this case.
        break;
    }
    print('sdsd' + _refreshController.headerStatus.toString());
    return buildLoadWidget();
  }

  Widget buildEmptyWidget() {
    return Container(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Center(
                child: FluttieAnimationRootWidget(
              path: 'assets/animations/empty.json',
              autoPlay: true,
            )),
          ),
        ),
      ),
    );
  }

  Widget buildLoadWidget() {
    return Container(
      child: Center(
          child: SizedBox(
              height: 100,
              child: FluttieAnimationRootWidget(
                path: 'assets/animations/loading1.json',
                autoPlay: true,
              ))),
    );
  }

  Widget buildFailWidget() {
    return Container(
      child: Center(
          child: FluttieAnimationRootWidget(
        path: 'assets/animations/load_fail2.json',
        autoPlay: true,
      )),
    );
  }

  Widget buildTwoLevelWidget() {
    return null;
  }

  PreferredSizeWidget appBar() {
    return null;
  }

  Widget buildBody() {
    return ListView.builder(
      itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
      itemExtent: 100.0,
      itemCount: items.length,
    );
  }
}
