/**
 * VideoPlayer - 视频播放页面
 * 播放本地rawfile视频，支持播放/暂停切换
 */

@Entry
@Component
struct VideoPlayer {
  @State private isPlaying: boolean = false
  @State private currentTime: number = 0
  @State private duration: number = 0
  @State private isPrepared: boolean = false

  private controller: VideoController = new VideoController()

  private formatTime(seconds: number): string {
    const s = Math.floor(seconds)
    const min = Math.floor(s / 60)
    const sec = s % 60
    const minStr = min < 10 ? "0" + min : "" + min
    const secStr = sec < 10 ? "0" + sec : "" + sec
    return minStr + ":" + secStr
  }

  private togglePlay(): void {
    if (!this.isPrepared) return
    if (this.isPlaying) {
      this.controller.pause()
    } else {
      this.controller.start()
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text("视频播放").fontSize(20).fontWeight(FontWeight.Bold).fontColor("#1A1A1A")
        Blank()
        Text(this.isPlaying ? "播放中" : "已暂停")
          .fontSize(13).fontColor(this.isPlaying ? "#4CAF50" : "#999999")
      }.width("100%").padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 视频播放区域
      Stack({ alignContent: Alignment.Center }) {
        // 原生Video组件
        Video({
          src: $rawfile("demo.mp4"),
          controller: this.controller
        })
        .width("100%")
        .height(240)
        .autoPlay(false)
        .objectFit(ImageFit.Contain)
        .backgroundColor("#000000")
        .onStart(() => { this.isPlaying = true })
        .onPause(() => { this.isPlaying = false })
        .onFinish(() => { this.isPlaying = false; this.currentTime = 0 })
        .onPrepared((event) => {
          this.duration = event.duration
          this.isPrepared = true
        })
        .onUpdate((event) => { this.currentTime = event.time })
        .onError(() => { console.log("Video error occurred") })

        // 中央大按钮（仅未播放时显示）
        if (!this.isPlaying) {
          Button() {
            Text("▶").fontSize(40).fontColor("#FFFFFF")
          }
          .width(80).height(80).borderRadius(40)
          .backgroundColor("#88000000")
          .onClick(() => { this.togglePlay() })
        }
      }
      .width("100%")
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .clip(true)
      .shadow({ radius: 12, color: "#1A000000", offsetY: 4 })

      // 进度信息
      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text("当前进度").fontSize(11).fontColor("#999999")
          Text(this.formatTime(this.currentTime)).fontSize(16).fontWeight(FontWeight.Bold).fontColor("#333333")
        }.alignItems(HorizontalAlign.Center)
        Column({ space: 4 }) {
          Text("总时长").fontSize(11).fontColor("#999999")
          Text(this.formatTime(this.duration)).fontSize(16).fontWeight(FontWeight.Bold).fontColor("#333333")
        }.alignItems(HorizontalAlign.Center)
      }
      .width("100%").padding({ top: 20 })
      .justifyContent(FlexAlign.Center)

      // 进度条
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Row().width("100%").height(6).backgroundColor("#E0E0E0").borderRadius(3)
          Row()
            .width(this.duration > 0 ? (this.currentTime / this.duration * 100) + "%" : "0%")
            .height(6).backgroundColor("#667eea").borderRadius(3)
        }.layoutWeight(1).height(6)
      }
      .width("100%").padding({ left: 24, right: 24, top: 12 })

      // 播放控制按钮
      Row({ space: 24 }) {
        // 重新播放
        Button() {
          Text("⏮").fontSize(22).fontColor("#FFFFFF")
        }.width(52).height(52).borderRadius(26)
        .backgroundColor("#999999")
        .onClick(() => {
          if (this.isPrepared) this.controller.setCurrentTime(0)
        })

        // 播放/暂停
        Button() {
          Text(this.isPlaying ? "⏸" : "▶")
            .fontSize(28).fontColor("#FFFFFF")
        }.width(64).height(64).borderRadius(32)
        .backgroundColor("#667eea")
        .shadow({ radius: 8, color: "#44667eea", offsetY: 4 })
        .onClick(() => { this.togglePlay() })

        // 快进10秒
        Button() {
          Text("⏩").fontSize(22).fontColor("#FFFFFF")
        }.width(52).height(52).borderRadius(26)
        .backgroundColor("#999999")
        .onClick(() => {
          if (this.isPrepared) {
            let pos = this.currentTime + 10
            if (pos > this.duration) pos = this.duration
            this.controller.setCurrentTime(pos)
          }
        })
      }
      .width("100%").padding({ top: 28 })
      .justifyContent(FlexAlign.Center)

      // 视频信息
      Column({ space: 8 }) {
        Divider().color("#F0F0F0").margin({ top: 24, bottom: 8 })
        Text("演示视频").fontSize(16).fontWeight(FontWeight.Bold).fontColor("#1A1A1A")
        Text("播放项目本地视频，支持播放/暂停、进度显示、重新播放和快进控制。")
          .fontSize(14).fontColor("#666666").lineHeight(22)
      }.width("100%").padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width("100%").height("100%").backgroundColor("#F5F5F5")
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}