/**
 * BusinessCard - 个人名片页面
 * 综合运用 Image / Text / Row / Column 核心布局组件
 * 实现美观的个人名片展示与'关注'交互
 */

@Entry
@Component
struct BusinessCard {
  // ── 用户信息状态 ──────────────────────────────────
  @State nickName: string = 'ZMJQKA'
  @State title: string = 'Let"go!!!!!!!!'
  @State signature: string = '我是冠军🏆你是什么O.o?'
  @State avatar: Resource = $r('app.media.avatar')
  @State isFollowed: boolean = false
  @State followerCount: number = 1280

  // ── 用户标签 ──────────────────────────────────────
  private tags: string[] = ['酱味大鸡', '', '', '', '']

  /**
   * '关注'按钮点击处理
   */
  private toggleFollow(): void {
    this.isFollowed = !this.isFollowed
    this.followerCount += this.isFollowed ? 1 : -1
  }

  /**
   * 格式化关注数
   */
  private formatCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + 'w'
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'k'
    }
    return count.toString()
  }

  build() {
    // ── 最外层：全屏容器 + 渐变背景 ──────────────────
    Column() {
      Scroll() {
        Column({ space: 0 }) {
          // ═══════════════════════════════════════════
          // 顶部装饰区域（渐变背景条 + 圆点装饰）
          // ═══════════════════════════════════════════
          Column() {
            // 装饰圆点组
            Row({ space: 8 }) {
              ForEach([0, 1, 2], () => {
                Circle()
                  .width(6)
                  .height(6)
                  .fill('#FFFFFF')
                  .opacity(0.4)
              }, (_: number, i: number) => i.toString())
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding({ top: 16, right: 20 })

            Blank()
              .height(40)
          }
          .width('100%')
          .height(180)
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0],
              ['#764ba2', 1]
            ]
          })
          .borderRadius({ bottomLeft: 40, bottomRight: 40 })

          // ═══════════════════════════════════════════
          // 名片主卡片（负边距实现重叠效果）
          // ═══════════════════════════════════════════
          Column({ space: 0 }) {
            // ── 头像区域 ────────────────────────────
            Column({ space: 0 }) {
              // 头像外圈装饰
              Stack({ alignContent: Alignment.Center }) {
                // 外圈光晕
                Circle()
                  .width(118)
                  .height(118)
                  .fill('#00000000')
                  .stroke('#667eea')
                  .strokeWidth(2)
                  .opacity(0.3)

                // 内圈描边
                Circle()
                  .width(108)
                  .height(108)
                  .fill('#00000000')
                  .stroke('#667eea')
                  .strokeWidth(1)
                  .opacity(0.5)

                // 头像本体
                Image(this.avatar)
                  .width(100)
                  .height(100)
                  .borderRadius(50)
                  .border({ width: 3, color: '#FFFFFF' })
                  .objectFit(ImageFit.Cover)
                  .shadow({
                    radius: 12,
                    color: '#33667eea',
                    offsetY: 4
                  })
              }
              .margin({ top: -60 })
            }

            // ── 昵称 ────────────────────────────────
            Text(this.nickName)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a2e')
              .margin({ top: 12 })
              .lineHeight(32)

            // ── 称号 ────────────────────────────────
            Text(this.title)
              .fontSize(14)
              .fontColor('#667eea')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 4 })
              .letterSpacing(1)
              .lineHeight(20)

            // ── 分隔装饰线 ──────────────────────────
            Row({ space: 6 }) {
              Circle()
                .width(4)
                .height(4)
                .fill('#667eea')
                .opacity(0.5)
              Divider()
                .width(40)
                .height(1)
                .color('#667eea')
                .opacity(0.3)
              Circle()
                .width(4)
                .height(4)
                .fill('#667eea')
                .opacity(0.5)
            }
            .margin({ top: 14, bottom: 14 })
            .alignItems(VerticalAlign.Center)

            // ── 个性签名 ────────────────────────────────
            Row() {
              Text(this.signature)
                .fontSize(15)
                .fontColor('#555555')
                .textAlign(TextAlign.Center)
                .lineHeight(22)
                .padding({ left: 4, right: 4 })
            }
            .width('90%')
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .backgroundColor('#f8f5ff')
            .borderRadius(12)
            .border({ width: 1, color: '#efeaff' })

            // ── 统计信息行 ──────────────────────────
            Row({ space: 0 }) {
              // 关注数
              Column({ space: 2 }) {
                Text(this.formatCount(this.followerCount))
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a2e')
                Text('粉丝')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Divider()
                .vertical(true)
                .height(32)
                .color('#e8e8e8')

              // 关注中
              Column({ space: 2 }) {
                Text('256')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a2e')
                Text('关注')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Divider()
                .vertical(true)
                .height(32)
                .color('#e8e8e8')

              // 获赞数
              Column({ space: 2 }) {
                Text('3.6k')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a2e')
                Text('获赞')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 16, bottom: 12 })
            .margin({ top: 12 })

            // ── '关注' 交互按钮 ─────────────────────
            Button() {
              Row({ space: 8 }) {
                if (this.isFollowed) {
                  Text('✓')
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                } else {
                  Text('+')
                    .fontSize(20)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Lighter)
                }

                Text(this.isFollowed ? '已关注' : '关 注')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
                  .letterSpacing(2)
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .width(160)
            .height(46)
            .backgroundColor(this.isFollowed ? '#909090' : '#667eea')
            .borderRadius(23)
            .shadow({
              radius: this.isFollowed ? 4 : 8,
              color: this.isFollowed ? '#40000000' : '#44667eea',
              offsetY: this.isFollowed ? 2 : 4
            })
            .onClick(() => {
              this.toggleFollow()
            })

            // ── 标签行 ──────────────────────────────
            Column({ space: 8 }) {
              Text('🏷️ 兴趣标签')
                .fontSize(12)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Start)

              Flex({
                direction: FlexDirection.Row,
                wrap: FlexWrap.Wrap,
                justifyContent: FlexAlign.Start,
                alignItems: ItemAlign.Center
              }) {
                ForEach(this.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(13)
                    .fontColor('#667eea')
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor('#f0ecff')
                    .borderRadius(14)
                    .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 16 })
          }
          .width('90%')
          .padding({ left: 20, right: 20, top: 0, bottom: 24 })
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({
            radius: 20,
            color: '#1a000000',
            offsetY: 6
          })
          .alignItems(HorizontalAlign.Center)
          .margin({ top: -40 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 32 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f2f5')
  }
}
