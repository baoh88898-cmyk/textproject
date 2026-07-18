/**
 * Login - 登录页面（参考图样式优化，仅账号密码）
 */

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  @State errorMsg: string = ''
  @State showPassword: boolean = false

  get isValid(): boolean {
    return this.username.trim().length > 0 && this.password.trim().length > 0
  }

  private doLogin(): void {
    if (!this.isValid) {
      this.errorMsg = '请输入完整的账号和密码'
      return
    }
    this.errorMsg = ''
    this.isLoading = true
    setTimeout(() => {
      this.isLoading = false
      this.errorMsg = '模拟登录成功 ✓'
    }, 1500)
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 0 }) {
          // ═══ 渐变头部 ════════════════════════════
          this.HeaderSection()

          // ═══ 登录表单卡片 ════════════════════════
          this.LoginForm()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor('#F5F7FA')
  }

  @Builder
  HeaderSection() {
    Column() {
      // Logo 圆形背景
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Image($r('app.media.login_logo'))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Contain)
            .borderRadius(32)
            .border({ width: 2, color: '#4DFFFFFF' })
        }
        .width(80).height(80)
        .borderRadius(40)
        .backgroundColor('#33FFFFFF')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .padding({ top: 48 })

      Text('欢迎回来')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 12 })

      Text('登录您的账号继续')
        .fontSize(14)
        .fontColor(Color.White)
        .opacity(0.85)
        .margin({ top: 4, bottom: 36 })
    }
    .width('100%')
    .linearGradient({
      angle: 135,
      colors: [['#667eea', 0], ['#764ba2', 1]]
    })
    .borderRadius({ bottomLeft: 32, bottomRight: 32 })
  }

  @Builder
  LoginForm() {
    Column({ space: 0 }) {
      // ── 标题 ─────────────────────────────────
      Column({ space: 6 }) {
        Text('账号登录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a2e')
        Text('使用账号密码登录')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // ── 账号输入 ────────────────────────────
      Column({ space: 8 }) {
        Text('账号')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)
        Row({ space: 10 }) {
          Text('👤')
            .fontSize(18)
            .opacity(0.5)
          TextInput({ placeholder: '请输入账号', text: this.username })
            .layoutWeight(1)
            .fontSize(15)
            .fontColor('#333333')
            .placeholderColor('#CCCCCC')
            .backgroundColor('#00000000')
            .onChange((value: string) => {
              this.username = value
              this.errorMsg = ''
            })
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
        .height(48)
        .backgroundColor('#F5F7FA')
        .borderRadius(12)
        .border({ width: 1, color: '#E8ECF0' })
      }
      .width('100%')
      .margin({ top: 24 })

      // ── 密码输入 ────────────────────────────
      Column({ space: 8 }) {
        Text('密码')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)
        Row({ space: 10 }) {
          Text('🔒')
            .fontSize(16)
            .opacity(0.5)
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .showPasswordIcon(false)
            .layoutWeight(1)
            .fontSize(15)
            .fontColor('#333333')
            .placeholderColor('#CCCCCC')
            .backgroundColor('#00000000')
            .onChange((value: string) => {
              this.password = value
              this.errorMsg = ''
            })
          Text(this.showPassword ? '🙈' : '👁')
            .fontSize(18)
            .opacity(0.4)
            .onClick(() => {
              this.showPassword = !this.showPassword
            })
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
        .height(48)
        .backgroundColor('#F5F7FA')
        .borderRadius(12)
        .border({ width: 1, color: '#E8ECF0' })
      }
      .width('100%')
      .margin({ top: 16 })

      // 错误/成功提示
      if (this.errorMsg.length > 0) {
        Text(this.errorMsg)
          .fontSize(13)
          .fontColor(this.errorMsg.includes('成功') ? '#4CAF50' : '#E85D3A')
          .width('100%')
          .margin({ top: 8 })
      }

      // ── 登录按钮 ────────────────────────────
      if (this.isLoading) {
        Button() {
          Row({ space: 8 }) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
            Text('登录中...')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(48)
        .backgroundColor('#8892d9')
        .borderRadius(12)
      } else {
        Button() {
          Text('登 录')
            .fontSize(17)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .letterSpacing(4)
        }
        .width('100%')
        .height(48)
        .backgroundColor(this.isValid ? '#667eea' : '#CCCCCC')
        .borderRadius(12)
        .enabled(this.isValid)
        .shadow({
          radius: this.isValid ? 10 : 0,
          color: '#44667eea',
          offsetY: 4
        })
        .onClick(() => { this.doLogin() })
      }

      // ── 忘记密码 + 注册 ─────────────────────
      Row({ space: 0 }) {
        Text('忘记密码？')
          .fontSize(14)
          .fontColor('#667eea')
        Blank()
        Text('新用户注册')
          .fontSize(14)
          .fontColor('#667eea')
      }
      .width('100%')
      .margin({ top: 20 })

      // ── 分隔线 ─────────────────────────────
      Row({ space: 12 }) {
        Divider().width('30%').color('#E8E8E8')
        Text('or')
          .fontSize(13)
          .fontColor('#BBBBBB')
        Divider().width('30%').color('#E8E8E8')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 28 })

      // ── 社交登录 ───────────────────────────
      Row({ space: 24 }) {
        this.SocialItem('💬', '微信')
        this.SocialItem('🐧', 'QQ')
        this.SocialItem('📱', '手机')
        this.SocialItem('✉️', '邮箱')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })

      // ── 协议文本 ───────────────────────────
      Row({ space: 4 }) {
        Text('登录即代表同意')
          .fontSize(12)
          .fontColor('#BBBBBB')
        Text('《用户协议》')
          .fontSize(12)
          .fontColor('#667eea')
        Text('和')
          .fontSize(12)
          .fontColor('#BBBBBB')
        Text('《隐私政策》')
          .fontSize(12)
          .fontColor('#667eea')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 4 })
    }
    .width('88%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 20, color: '#1A000000', offsetY: 6 })
    .margin({ top: -28 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SocialItem(icon: string, label: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(28)
      Text(label)
        .fontSize(11)
        .fontColor('#888888')
    }
  }
}
