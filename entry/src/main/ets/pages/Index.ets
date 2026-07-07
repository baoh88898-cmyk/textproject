/**
 * 个人信息展示页面
 * 综合运用组件定义、状态管理与UI布局
 */

import { LengthMetrics } from '@kit.ArkUI';

// ─── 联系方式数据模型 ───────────────────────────────
interface ContactItem {
  icon: string
  label: string
  value: string
}

// ─── 技能标签数据模型 ───────────────────────────────
interface SkillTag {
  name: string
  level: number // 1-5
}

@Entry
@Component
struct Index {
  // ── 个人信息状态 ──────────────────────────────────
  @State name: string = '张三'
  @State title: string = '高级软件工程师'
  @State company: string = '华为技术有限公司'
  @State bio: string = '热爱编程，专注于鸿蒙应用开发与前端技术，拥有5年以上移动端开发经验。喜欢探索新技术，持续学习成长。'
  @State avatar: Resource = $r('app.media.startIcon')

  // ── 编辑模式状态 ──────────────────────────────────
  @State isEditing: boolean = false
  @State editName: string = ''
  @State editTitle: string = ''
  @State editCompany: string = ''
  @State editBio: string = ''

  // ── 联系方式状态 ──────────────────────────────────
  @State contacts: ContactItem[] = [
    { icon: '📱', label: '电话', value: '138-0000-1234' },
    { icon: '✉️', label: '邮箱', value: 'zhangsan@example.com' },
    { icon: '📍', label: '地址', value: '深圳市龙岗区坂田华为基地' },
    { icon: '🔗', label: '主页', value: 'https://zhangsan.dev' }
  ]

  // ── 技能标签状态 ──────────────────────────────────
  @State skills: SkillTag[] = [
    { name: 'ArkTS', level: 5 },
    { name: 'ArkUI', level: 5 },
    { name: 'TypeScript', level: 4 },
    { name: 'HarmonyOS', level: 4 },
    { name: 'Git', level: 4 },
    { name: 'CI/CD', level: 3 }
  ]

  // ── 设置开关状态 ──────────────────────────────────
  @State darkMode: boolean = false
  @State notification: boolean = true
  @State isPublic: boolean = true

  // ── 展开/折叠状态 ─────────────────────────────────
  @State bioExpanded: boolean = false

  // ── 提示消息 ──────────────────────────────────────
  @State toastMessage: string = ''
  @State showToast: boolean = false

  /**
   * 显示提示消息
   */
  private showMessage(msg: string): void {
    this.toastMessage = msg
    this.showToast = true
    setTimeout(() => {
      this.showToast = false
    }, 2000)
  }

  /**
   * 进入编辑模式
   */
  private enterEditMode(): void {
    this.editName = this.name
    this.editTitle = this.title
    this.editCompany = this.company
    this.editBio = this.bio
    this.isEditing = true
  }

  /**
   * 保存编辑内容
   */
  private saveEdit(): void {
    if (this.editName.trim().length === 0) {
      this.showMessage('姓名不能为空')
      return
    }
    this.name = this.editName
    this.title = this.editTitle
    this.company = this.editCompany
    this.bio = this.editBio
    this.isEditing = false
    this.showMessage('保存成功 ✓')
  }

  /**
   * 取消编辑
   */
  private cancelEdit(): void {
    this.isEditing = false
    this.showMessage('已取消编辑')
  }

  /**
   * 构建星级评分显示
   */
  @Builder
  StarRating(level: number) {
    Row({ space: 2 }) {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Text(i <= level ? '★' : '☆')
          .fontSize(14)
          .fontColor(i <= level ? '#FF9800' : '#CCCCCC')
      }, (i: number) => i.toString())
    }
  }

  /**
   * 构建个人头像区域
   */
  @Builder
  AvatarSection() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(this.avatar)
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: '#4CAF50' })
          .shadow({ radius: 8, color: '#33000000', offsetY: 4 })

        // 在线状态指示器
        Text('')
          .width(18)
          .height(18)
          .borderRadius(9)
          .backgroundColor('#4CAF50')
          .border({ width: 2, color: '#FFFFFF' })
          .position({ x: -4, y: -4 })
      }

      Text(this.name)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Text(this.title)
        .fontSize(14)
        .fontColor('#666666')

      Text(this.company)
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ top: 24, bottom: 20 })
  }

  /**
   * 构建个人简介卡片
   */
  @Builder
  BioCard() {
    Column({ space: 8 }) {
      Row() {
        Text('个人简介')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Blank()
        Text(this.bioExpanded ? '收起' : '展开')
          .fontSize(12)
          .fontColor('#2196F3')
          .onClick(() => {
            this.bioExpanded = !this.bioExpanded
          })
      }
      .width('100%')

      Text(this.bio)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(22)
        .maxLines(this.bioExpanded ? 999 : 3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 构建联系方式列表
   */
  @Builder
  ContactSection() {
    Column({ space: 0 }) {
      Text('联系方式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      Column({ space: 0 }) {
        ForEach(this.contacts, (item: ContactItem, index: number) => {
          Row({ space: 12 }) {
            Text(item.icon)
              .fontSize(20)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)

            Column({ space: 2 }) {
              Text(item.label)
                .fontSize(12)
                .fontColor('#999999')
              Text(item.value)
                .fontSize(14)
                .fontColor('#333333')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('›')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            this.showMessage(`已复制: ${item.value}`)
          })

          if (index < this.contacts.length - 1) {
            Divider()
              .color('#F0F0F0')
              .margin({ left: 48 })
          }
        }, (item: ContactItem, index: number) => index.toString())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 构建技能标签区域
   */
  @Builder
  SkillSection() {
    Column({ space: 12 }) {
      Text('专业技能')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.skills, (skill: SkillTag) => {
          Row({ space: 6 }) {
            Text(skill.name)
              .fontSize(13)
              .fontColor('#2196F3')
            this.StarRating(skill.level)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#E3F2FD')
          .borderRadius(16)
          .onClick(() => {
            this.showMessage(`${skill.name}: 熟练度 ${skill.level}/5`)
          })
        }, (skill: SkillTag, index: number) => index.toString())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 构建设置选项区域
   */
  @Builder
  SettingsSection() {
    Column({ space: 0 }) {
      Text('个人设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      // 公开主页
      Row() {
        Column({ space: 2 }) {
          Text('公开主页')
            .fontSize(14)
            .fontColor('#333333')
          Text('允许其他用户查看你的主页')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.isPublic })
          .selectedColor('#4CAF50')
          .onChange((isOn: boolean) => {
            this.isPublic = isOn
            this.showMessage(isOn ? '主页已公开' : '主页已隐藏')
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      Divider().color('#F0F0F0')

      // 消息通知
      Row() {
        Column({ space: 2 }) {
          Text('消息通知')
            .fontSize(14)
            .fontColor('#333333')
          Text('接收系统推送通知')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.notification })
          .selectedColor('#4CAF50')
          .onChange((isOn: boolean) => {
            this.notification = isOn
            this.showMessage(isOn ? '已开启通知' : '已关闭通知')
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      Divider().color('#F0F0F0')

      // 深色模式
      Row() {
        Column({ space: 2 }) {
          Text('深色模式')
            .fontSize(14)
            .fontColor('#333333')
          Text('切换界面显示风格')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
          .selectedColor('#4CAF50')
          .onChange((isOn: boolean) => {
            this.darkMode = isOn
            this.showMessage(isOn ? '深色模式已开启' : '深色模式已关闭')
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 构建编辑弹窗
   */
  @Builder
  EditDialog() {
    Column({ space: 16 }) {
      Text('编辑个人信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Column({ space: 4 }) {
        Text('姓名')
          .fontSize(12)
          .fontColor('#999999')
        TextInput({ text: this.editName, placeholder: '请输入姓名' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .onChange((value: string) => {
            this.editName = value
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('职位')
          .fontSize(12)
          .fontColor('#999999')
        TextInput({ text: this.editTitle, placeholder: '请输入职位' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .onChange((value: string) => {
            this.editTitle = value
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('公司')
          .fontSize(12)
          .fontColor('#999999')
        TextInput({ text: this.editCompany, placeholder: '请输入公司' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .onChange((value: string) => {
            this.editCompany = value
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('简介')
          .fontSize(12)
          .fontColor('#999999')
        TextInput({ text: this.editBio, placeholder: '请输入个人简介' })
          .width('100%')
          .height(80)
          .fontSize(14)
          .onChange((value: string) => {
            this.editBio = value
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row({ space: 12 }) {
        Button('取消')
          .width('45%')
          .height(40)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.cancelEdit()
          })
        Button('保存')
          .width('45%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .borderRadius(8)
          .onClick(() => {
            this.saveEdit()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('90%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  /**
   * 构建统计信息卡片
   */
  @Builder
  StatsCard() {
    Row({ space: 0 }) {
      Column({ space: 4 }) {
        Text('128')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2196F3')
        Text('项目')
          .fontSize(12)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Divider()
        .vertical(true)
        .height(36)
        .color('#F0F0F0')

      Column({ space: 4 }) {
        Text('5.2k')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        Text('贡献')
          .fontSize(12)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Divider()
        .vertical(true)
        .height(36)
        .color('#F0F0F0')

      Column({ space: 4 }) {
        Text('36')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
        Text('技术文章')
          .fontSize(12)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 主内容区
      Scroll() {
        Column({ space: 16 }) {
          // 头像区域
          this.AvatarSection()

          // 统计卡片
          this.StatsCard()

          // 个人简介
          this.BioCard()

          // 联系方式
          this.ContactSection()

          // 技能标签
          this.SkillSection()

          // 设置选项
          this.SettingsSection()

          // 编辑按钮
          Button('编辑个人信息')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#2196F3')
            .borderRadius(12)
            .onClick(() => {
              this.enterEditMode()
            })

          // 底部留白
          Blank()
            .height(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 编辑弹窗遮罩
      if (this.isEditing) {
        // 背景遮罩 - 点击外部取消编辑
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick(() => {
            this.cancelEdit()
          })

        // 弹窗内容 - 浮在遮罩上方，不触发遮罩事件
        Column() {
          this.EditDialog()
        }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
      }
      // 提示消息
      if (this.showToast) {
        Text(this.toastMessage)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#333333')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .position({ x: '50%', y: '85%' })
          .translate({ x: '-50%' })
          .opacity(this.showToast ? 1 : 0)
          .animation({ duration: 300 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}


