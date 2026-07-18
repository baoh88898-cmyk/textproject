/**
 * Settings - 交互式系统设置页面
 * 演示 ArkTS Tabs：底部导航、顶部滑动标签、垂直模式、自定义 TabBar、懒加载与切换监听。
 */

interface SettingSwitchItem {
  icon: string
  title: string
  desc: string
  enabled: boolean
}

interface TabLogItem {
  time: string
  text: string
}

@Component
struct LazyPanel {
  @Prop title: string
  @Prop detail: string

  aboutToAppear(): void {
    console.info(`LazyPanel appear: ${this.title}`)
  }

  aboutToDisappear(): void {
    console.info(`LazyPanel disappear: ${this.title}`)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#F4F8FF', 0], ['#FFFFFF', 1]]
        })

      Column({ space: 14 }) {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18202F')
        Text(this.detail)
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#667085')
          .textAlign(TextAlign.Center)
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#2F6BFF')
      }
      .padding(20)
    }
    .width('100%')
    .height(220)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .border({ width: 1, color: '#E6ECF5' })
    .shadow({ radius: 16, color: '#140B1F33', offsetY: 8 })
  }
}

@Entry
@Component
struct Settings {
  @State bottomIndex: number = 0
  @State topIndex: number = 0
  @State verticalIndex: number = 0
  @State customIndex: number = 0
  @State lazyIndex: number = 0
  @State lastChange: string = '等待 TabContent 切换'
  @State toastMessage: string = ''
  @State showToast: boolean = false
  @State settingItems: SettingSwitchItem[] = [
    { icon: '🔔', title: '推送通知', desc: '接收系统与应用提醒', enabled: true },
    { icon: '🌙', title: '深色模式', desc: '跟随低亮度偏好', enabled: false },
    { icon: '📶', title: '仅 WiFi 下载', desc: '节省移动数据流量', enabled: true },
    { icon: '🔒', title: '隐私保护', desc: '限制敏感数据访问', enabled: true }
  ]
  @State logs: TabLogItem[] = []

  private topTabs: string[] = ['通知', '显示', '声音', '隐私', '存储', '账号']
  private verticalTabs: string[] = ['网络', '权限', '应用', '系统']
  private customTabs: string[] = ['概览', '安全', '同步']

  private showMessage(message: string): void {
    this.toastMessage = message
    this.showToast = true
    setTimeout(() => {
      this.showToast = false
    }, 1800)
  }

  private pushLog(text: string): void {
    const now = new Date()
    const time = `${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`
    const logItem: TabLogItem = { time: time, text: text }
    this.lastChange = text
    this.logs = [logItem].concat(this.logs).slice(0, 8)
  }

  @Builder
  BottomTabBar(icon: string, title: string, badge: number, index: number) {
    Column({ space: 3 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Text(icon)
          .fontSize(this.bottomIndex === index ? 23 : 21)
          .opacity(this.bottomIndex === index ? 1 : 0.55)
        if (badge > 0) {
          Text(badge > 99 ? '99+' : `${badge}`)
            .fontSize(9)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width(badge > 99 ? 24 : 16)
            .height(16)
            .padding({ left: 3, right: 3 })
            .backgroundColor('#F04438')
            .borderRadius(8)
            .position({ x: 16, y: -4 })
        }
      }
      .width(32)
      .height(26)
      Text(title)
        .fontSize(11)
        .fontColor(this.bottomIndex === index ? '#2F6BFF' : '#667085')
        .fontWeight(this.bottomIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height(58)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.bottomIndex === index ? '#EEF4FF' : '#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  PillTab(title: string, index: number) {
    Text(title)
      .fontSize(14)
      .fontColor(this.topIndex === index ? '#FFFFFF' : '#475467')
      .fontWeight(this.topIndex === index ? FontWeight.Bold : FontWeight.Normal)
      .height(36)
      .padding({ left: 18, right: 18 })
      .backgroundColor(this.topIndex === index ? '#2F6BFF' : '#FFFFFF')
      .borderRadius(18)
      .border({ width: 1, color: this.topIndex === index ? '#2F6BFF' : '#E4EAF2' })
      .shadow({ radius: this.topIndex === index ? 10 : 0, color: '#202F6BFF', offsetY: 4 })
  }

  @Builder
  SideTab(title: string, index: number) {
    Row({ space: 8 }) {
      Row()
        .width(4)
        .height(28)
        .borderRadius(2)
        .backgroundColor(this.verticalIndex === index ? '#2F6BFF' : '#00000000')
      Text(title)
        .fontSize(14)
        .fontColor(this.verticalIndex === index ? '#18202F' : '#667085')
        .fontWeight(this.verticalIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .width(92)
    .height(48)
    .padding({ left: 8 })
    .backgroundColor(this.verticalIndex === index ? '#EEF4FF' : '#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  CustomTab(title: string, index: number) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.customIndex === index ? '#2F6BFF' : '#667085')
      Row()
        .width(this.customIndex === index ? 26 : 8)
        .height(3)
        .borderRadius(2)
        .backgroundColor(this.customIndex === index ? '#2F6BFF' : '#D0D5DD')
        .animation({ duration: 180 })
    }
    .height(48)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 18, right: 18 })
  }

  @Builder
  SectionTitle(title: string, desc: string) {
    Column({ space: 5 }) {
      Text(title)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18202F')
      Text(desc)
        .fontSize(13)
        .fontColor('#667085')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 18, right: 18, top: 16, bottom: 12 })
  }

  @Builder
  HeroHeader() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 5 }) {
          Text('系统设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('ArkTS Tabs 交互组件演示')
            .fontSize(13)
            .fontColor('#DCE8FF')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('Tabs')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#33FFFFFF')
          .borderRadius(14)
      }
      .width('100%')

      Row({ space: 10 }) {
        this.StatChip('6', '用法')
        this.StatChip(`${this.logs.length}`, '日志')
        this.StatChip('实时', '监听')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 22, bottom: 18 })
    .linearGradient({
      angle: 135,
      colors: [['#2764E8', 0], ['#5E7CE2', 0.55], ['#27B3A8', 1]]
    })
    .borderRadius({ bottomLeft: 24, bottomRight: 24 })
  }

  @Builder
  StatChip(value: string, label: string) {
    Row({ space: 6 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text(label)
        .fontSize(11)
        .fontColor('#DCE8FF')
    }
    .layoutWeight(1)
    .height(34)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#24FFFFFF')
    .borderRadius(10)
  }

  @Builder
  SettingRow(item: SettingSwitchItem, index: number) {
    Row({ space: 12 }) {
      Text(item.icon)
        .fontSize(20)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor(index % 2 === 0 ? '#EEF4FF' : '#ECFDF3')
        .borderRadius(12)
      Column({ space: 3 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#18202F')
        Text(item.desc)
          .fontSize(12)
          .fontColor('#98A2B3')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: item.enabled })
        .onChange((value: boolean) => {
          this.settingItems[index].enabled = value
          this.showMessage(`${item.title}${value ? '已开启' : '已关闭'}`)
        })
    }
    .width('100%')
    .height(68)
    .padding({ left: 14, right: 14 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#F1F4F9' })
  }

  @Builder
  SettingsList(kind: string) {
    Column({ space: 0 }) {
      ForEach(this.settingItems, (item: SettingSwitchItem, index: number) => {
        this.SettingRow(item, index)
      }, (item: SettingSwitchItem) => `${kind}-${item.title}`)
    }
    .width('100%')
    .clip(true)
    .borderRadius(18)
    .shadow({ radius: 16, color: '#100B1F33', offsetY: 6 })
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  BottomDemo() {
    Column() {
      this.HeroHeader()
      this.SectionTitle('底部导航栏', '固定底部 TabBar，包含图标、文字和消息角标')
      this.SettingsList('bottom')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  @Builder
  TopScrollableDemo() {
    Column() {
      this.HeroHeader()
      this.SectionTitle('顶部滑动标签栏', 'BarMode.Scrollable 适合多个设置分类横向切换')
      Tabs({ index: this.topIndex, barPosition: BarPosition.Start }) {
        ForEach(this.topTabs, (tab: string, index: number) => {
          TabContent() {
            Scroll() {
              Column({ space: 12 }) {
                Text(`${tab}设置`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#18202F')
                  .width('100%')
                this.SettingsList(`top-${tab}`)
              }
              .width('100%')
              .padding({ top: 14 })
            }
          }
          .tabBar(this.PillTab(tab, index))
        }, (tab: string) => tab)
      }
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.topIndex = index
        this.pushLog(`顶部滑动标签切换到：${this.topTabs[index]}`)
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  @Builder
  VerticalDemo() {
    Column() {
      this.HeroHeader()
      this.SectionTitle('垂直模式 Tabs', 'TabBar 放在侧边，适合平板或复杂设置分组')
      Tabs({ index: this.verticalIndex, barPosition: BarPosition.Start }) {
        ForEach(this.verticalTabs, (tab: string, index: number) => {
          TabContent() {
            Column({ space: 14 }) {
              Text(`${tab}管理`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#18202F')
                .width('100%')
              this.SettingsList(`vertical-${tab}`)
            }
            .width('100%')
            .height('100%')
            .padding({ top: 12 })
          }
          .tabBar(this.SideTab(tab, index))
        }, (tab: string) => tab)
      }
      .vertical(true)
      .barWidth(104)
      .backgroundColor('#F5F7FB')
      .onChange((index: number) => {
        this.verticalIndex = index
        this.pushLog(`垂直 Tabs 切换到：${this.verticalTabs[index]}`)
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  @Builder
  CustomDemo() {
    Column() {
      this.HeroHeader()
      this.SectionTitle('自定义 TabBar 样式', '使用 Builder 自定义选中颜色、下划线和动画')
      Tabs({ index: this.customIndex, barPosition: BarPosition.Start }) {
        ForEach(this.customTabs, (tab: string, index: number) => {
          TabContent() {
            Column({ space: 12 }) {
              Text(`${tab}面板`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#18202F')
              Text('这里的 TabBar 不是默认文本，而是完全自定义的 Builder 结构。')
                .fontSize(14)
                .lineHeight(22)
                .fontColor('#667085')
              this.SettingsList(`custom-${tab}`)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })
          }
          .tabBar(this.CustomTab(tab, index))
        }, (tab: string) => tab)
      }
      .onChange((index: number) => {
        this.customIndex = index
        this.pushLog(`自定义 TabBar 切换到：${this.customTabs[index]}`)
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  @Builder
  LazyAndListenerDemo() {
    Column() {
      this.HeroHeader()
      this.SectionTitle('懒加载与切换监听', '首次进入 TabContent 时创建内容，onChange 记录切换事件')
      Tabs({ index: this.lazyIndex, barPosition: BarPosition.Start }) {
        TabContent() {
          LazyPanel({ title: '性能监控', detail: 'aboutToAppear 会在内容创建时输出日志。' })
        }
        .tabBar('性能')
        TabContent() {
          LazyPanel({ title: '权限审计', detail: '切换到该页时才渲染对应内容。' })
        }
        .tabBar('审计')
        TabContent() {
          LazyPanel({ title: '同步任务', detail: '可以把耗时初始化放进子组件生命周期中。' })
        }
        .tabBar('同步')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.lazyIndex = index
        this.pushLog(`懒加载 Tabs 切换到第 ${index + 1} 项`)
      })
      .height(300)
      .padding({ left: 16, right: 16 })

      Column({ space: 8 }) {
        Text('TabContent 切换监听')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18202F')
          .width('100%')
        Text(this.lastChange)
          .fontSize(13)
          .fontColor('#2F6BFF')
          .width('100%')
        ForEach(this.logs, (item: TabLogItem) => {
          Row({ space: 8 }) {
            Text(item.time)
              .fontSize(11)
              .fontColor('#98A2B3')
              .width(52)
            Text(item.text)
              .fontSize(12)
              .fontColor('#667085')
              .layoutWeight(1)
          }
          .width('100%')
        }, (item: TabLogItem, index: number) => `${item.time}-${index}`)
      }
      .width('100%')
      .padding(16)
      .margin({ left: 16, right: 16, top: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .shadow({ radius: 16, color: '#100B1F33', offsetY: 6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ index: this.bottomIndex, barPosition: BarPosition.End }) {
        TabContent() {
          this.BottomDemo()
        }
        .tabBar(this.BottomTabBar('⚙️', '设置', 0, 0))

        TabContent() {
          this.TopScrollableDemo()
        }
        .tabBar(this.BottomTabBar('📌', '顶部', 6, 1))

        TabContent() {
          this.VerticalDemo()
        }
        .tabBar(this.BottomTabBar('↕', '垂直', 0, 2))

        TabContent() {
          this.CustomDemo()
        }
        .tabBar(this.BottomTabBar('🎛', '自定义', 2, 3))

        TabContent() {
          this.LazyAndListenerDemo()
        }
        .tabBar(this.BottomTabBar('🧭', '监听', 1, 4))
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.bottomIndex = index
        const names: string[] = ['设置', '顶部滑动', '垂直模式', '自定义', '懒加载']
        this.pushLog(`底部导航切换到：${names[index]}`)
      })
      .width('100%')
      .height('100%')

      if (this.showToast) {
        Text(this.toastMessage)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#18202F')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .position({ x: '50%', y: '86%' })
          .translate({ x: '-50%' })
          .zIndex(10)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
