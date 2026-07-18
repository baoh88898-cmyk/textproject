/**
 * 个人信息展示页面
 * 综合运用组件定义、状态管理与UI布局
 */

import { ActionBanner } from '../components/ActionBanner';
import { MetricCard } from '../components/MetricCard';
import { UserBadge } from '../components/UserBadge';

interface ContactItem {
  icon: string
  label: string
  value: string
}

interface SkillTag {
  name: string
  level: number
}

@Entry
@Component
struct Index {
  @State name: string = '张三'
  @State title: string = '高级软件工程师'
  @State company: string = '华为技术有限公司'
  @State bio: string = '热爱编程，专注于鸿蒙应用开发与前端技术，拥有5年以上移动端开发经验。'
  @State avatar: Resource = $r('app.media.avatar')
  @State isEditing: boolean = false
  @State editName: string = ''
  @State editTitle: string = ''
  @State editCompany: string = ''
  @State editBio: string = ''
  @State contacts: ContactItem[] = [
    { icon: '📱', label: '电话', value: '138-0000-1234' },
    { icon: '✉️', label: '邮箱', value: 'zhangsan@example.com' },
    { icon: '📍', label: '地址', value: '深圳市龙岗区坂田华为基地' },
    { icon: '🔗', label: '主页', value: 'https://zhangsan.dev' }
  ]
  @State skills: SkillTag[] = [
    { name: 'ArkTS', level: 5 },
    { name: 'ArkUI', level: 5 },
    { name: 'TypeScript', level: 4 },
    { name: 'HarmonyOS', level: 4 },
    { name: 'Git', level: 4 },
    { name: 'CI/CD', level: 3 }
  ]
  @State darkMode: boolean = false
  @State notification: boolean = true
  @State isPublic: boolean = true
  @State bioExpanded: boolean = false
  @State toastMessage: string = ''
  @State showToast: boolean = false

  private showMessage(msg: string): void {
    this.toastMessage = msg
    this.showToast = true
    setTimeout(() => { this.showToast = false }, 2000)
  }

  private enterEditMode(): void {
    this.editName = this.name
    this.editTitle = this.title
    this.editCompany = this.company
    this.editBio = this.bio
    this.isEditing = true
  }

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

  private cancelEdit(): void {
    this.isEditing = false
    this.showMessage('已取消编辑')
  }

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

  @Builder
  AvatarSection() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(this.avatar)
          .width(100).height(100).borderRadius(50)
          .border({ width: 3, color: '#4CAF50' })
          .shadow({ radius: 8, color: '#33000000', offsetY: 4 })
        Text('')
          .width(18).height(18).borderRadius(9)
          .backgroundColor('#4CAF50')
          .border({ width: 2, color: '#FFFFFF' })
          .position({ x: -4, y: -4 })
      }
      Text(this.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333')
      Text(this.title).fontSize(14).fontColor('#666666')
      Text(this.company).fontSize(13).fontColor('#999999')
    }
    .width('100%').alignItems(HorizontalAlign.Center)
    .padding({ top: 24, bottom: 20 })
    .backgroundColor('#FFFFFF').borderRadius(16)
    .shadow({ radius: 6, color: '#1A000000', offsetY: 2 })
  }

  @Builder
  StatsCard() {
    Row() {
      Column({ space: 4 }) {
        Text('128').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FF9800')
        Text('文章').fontSize(12).fontColor('#999999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Center)
      Column({ space: 4 }) {
        Text('2.5k').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#4CAF50')
        Text('粉丝').fontSize(12).fontColor('#999999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Center)
      Column({ space: 4 }) {
        Text('36').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#2196F3')
        Text('关注').fontSize(12).fontColor('#999999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Center)
      Column({ space: 4 }) {
        Text('6.8k').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FF9800')
        Text('获赞').fontSize(12).fontColor('#999999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Center)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  @Builder
  BioCard() {
    Column({ space: 8 }) {
      Text('📝 个人简介').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#999999').width('100%').textAlign(TextAlign.Start)
      Text(this.bio).fontSize(14).fontColor('#666666').lineHeight(22)
        .maxLines(this.bioExpanded ? 999 : 3).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      Text(this.bioExpanded ? '收起' : '展开全部').fontSize(13).fontColor('#2196F3')
        .width('100%').textAlign(TextAlign.End).onClick(() => { this.bioExpanded = !this.bioExpanded })
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  ContactSection() {
    Column({ space: 12 }) {
      Text('📞 联系方式').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#999999').width('100%').textAlign(TextAlign.Start)
      ForEach(this.contacts, (item: ContactItem) => {
        Row({ space: 12 }) {
          Text(item.icon).fontSize(20)
          Text(item.label).fontSize(14).fontColor('#666666').width(40)
          Text(item.value).fontSize(14).fontColor('#333333').layoutWeight(1)
        }.width('100%').padding({ top: 8, bottom: 8 })
      }, (item: ContactItem) => item.label)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  SkillSection() {
    Column({ space: 12 }) {
      Text('💻 技能标签').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#999999').width('100%').textAlign(TextAlign.Start)
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        ForEach(this.skills, (skill: SkillTag) => {
          Column({ space: 4 }) {
            Text(skill.name).fontSize(13).fontColor('#333333').fontWeight(FontWeight.Medium)
            this.StarRating(skill.level)
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#F5F5F5').borderRadius(8).margin({ right: 8, bottom: 8 })
        }, (skill: SkillTag) => skill.name)
      }.width('100%')
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  SettingsSection() {
    Column({ space: 0 }) {
      Text('⚙️ 设置').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#999999').width('100%').textAlign(TextAlign.Start).margin({ bottom: 12 })
      Row() {
        Text('深色模式').fontSize(15).fontColor('#333333')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.darkMode }).onChange((isOn: boolean) => { this.darkMode = isOn; this.showMessage(isOn ? '已开启深色模式' : '已关闭深色模式') })
      }.width('100%').height(48)
      Divider().color('#F0F0F0')
      Row() {
        Text('消息通知').fontSize(15).fontColor('#333333')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.notification }).onChange((isOn: boolean) => { this.notification = isOn; this.showMessage(isOn ? '已开启通知' : '已关闭通知') })
      }.width('100%').height(48)
      Divider().color('#F0F0F0')
      Row() {
        Text('公开主页').fontSize(15).fontColor('#333333')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.isPublic }).onChange((isOn: boolean) => { this.isPublic = isOn; this.showMessage(isOn ? '主页已公开' : '主页已隐藏') })
      }.width('100%').height(48)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  EditDialog() {
    Column({ space: 16 }) {
      Text('编辑个人信息').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
      Column({ space: 8 }) {
        Text('姓名').fontSize(14).fontColor('#666666')
        TextInput({ placeholder: '请输入姓名', text: this.editName }).width('100%').height(44).fontSize(15).backgroundColor('#F5F5F5').borderRadius(8).onChange((value: string) => { this.editName = value })
      }.width('100%')
      Column({ space: 8 }) {
        Text('职位').fontSize(14).fontColor('#666666')
        TextInput({ placeholder: '请输入职位', text: this.editTitle }).width('100%').height(44).fontSize(15).backgroundColor('#F5F5F5').borderRadius(8).onChange((value: string) => { this.editTitle = value })
      }.width('100%')
      Column({ space: 8 }) {
        Text('公司').fontSize(14).fontColor('#666666')
        TextInput({ placeholder: '请输入公司', text: this.editCompany }).width('100%').height(44).fontSize(15).backgroundColor('#F5F5F5').borderRadius(8).onChange((value: string) => { this.editCompany = value })
      }.width('100%')
      Column({ space: 8 }) {
        Text('简介').fontSize(14).fontColor('#666666')
        TextInput({ placeholder: '请输入个人简介', text: this.editBio }).width('100%').height(80).fontSize(15).backgroundColor('#F5F5F5').borderRadius(8).onChange((value: string) => { this.editBio = value })
      }.width('100%')
      Row({ space: 16 }) {
        Button('取消').width('45%').height(44).fontSize(16).fontColor('#666666').backgroundColor('#F0F0F0').borderRadius(8).onClick(() => { this.cancelEdit() })
        Button('保存').width('45%').height(44).fontSize(16).fontColor('#FFFFFF').backgroundColor('#2196F3').borderRadius(8).onClick(() => { this.saveEdit() })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
    .width('85%').padding(24).backgroundColor('#FFFFFF').borderRadius(16)
    .shadow({ radius: 20, color: '#33000000', offsetY: 10 })
  }

  @Builder
  NavCard(icon: string, iconBg: string, title: string, subtitle: string, url: string) {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text(icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(iconBg)
      .borderRadius(14)

      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(subtitle)
          .fontSize(11)
          .fontColor('#8A94A6')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .height(78)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 10, color: '#12000000', offsetY: 4 })
    .onClick(() => { this.getUIContext().getRouter().pushUrl({ url: url }) })
  }

  @Builder
  NavigationSection() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('页面导航')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('常用示例入口')
            .fontSize(12)
            .fontColor('#8A94A6')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('6 个页面')
          .fontSize(12)
          .fontColor('#2563EB')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EAF1FF')
          .borderRadius(12)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 10 }) {
        this.NavCard('✨', '#F1ECFF', '个人名片', '卡片式设计', 'pages/BusinessCard')
        this.NavCard('🔐', '#FFF3E4', '登录', '账号密码登录', 'pages/Login')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.NavCard('🛒', '#E8F7ED', '商品列表', '高性能长列表', 'pages/ProductList')
        this.NavCard('🎬', '#E8F2FF', '视频播放', '媒体播放器', 'pages/VideoPlayer')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.NavCard('🎨', '#FCEAF3', 'Canvas动画', '2D 绘图动画', 'pages/CanvasAnimation')
        this.NavCard('⚙️', '#ECEFFF', '系统设置', 'Tabs 交互演示', 'pages/Settings')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8FAFF')
    .borderRadius(20)
    .border({ width: 1, color: '#EDF1F7' })
  }

  @Builder
  ComponentPracticeSection() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('组件互用练习')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('通过 import 导入 3 个自定义组件')
            .fontSize(12)
            .fontColor('#8A94A6')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('import')
          .fontSize(12)
          .fontColor('#7C3AED')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F3E8FF')
          .borderRadius(12)
      }
      .width('100%')

      UserBadge({
        avatar: this.avatar,
        name: this.name,
        role: 'ArkTS 自定义组件示例'
      })

      Row({ space: 10 }) {
        MetricCard({ title: '组件文件', value: '3', accentColor: '#2563EB' })
        MetricCard({ title: '导入方式', value: 'import', accentColor: '#16A34A' })
        MetricCard({ title: '主页面展示', value: 'OK', accentColor: '#F97316' })
      }
      .width('100%')

      ActionBanner({
        title: '组件已成功组合',
        description: 'UserBadge、MetricCard、ActionBanner 分别来自独立文件，并在 Index 页面中复用。',
        buttonText: '查看'
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8FAFF')
    .borderRadius(20)
    .border({ width: 1, color: '#EDF1F7' })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: 16 }) {
          this.AvatarSection()

          this.NavigationSection()

          this.ComponentPracticeSection()

          this.StatsCard()
          this.BioCard()
          this.ContactSection()
          this.SkillSection()
          this.SettingsSection()

          Button('编辑个人信息')
            .width('100%').height(48).fontSize(16)
            .fontColor('#FFFFFF').backgroundColor('#2196F3').borderRadius(12)
            .onClick(() => { this.enterEditMode() })

          Blank().height(24)
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 24 })
      }
      .width('100%').height('100%').scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      if (this.isEditing) {
        Column()
          .width('100%').height('100%').backgroundColor('#66000000')
          .onClick(() => { this.cancelEdit() })
        Column() { this.EditDialog() }
          .width('100%').height('100%').justifyContent(FlexAlign.Center)
      }

      if (this.showToast) {
        Text(this.toastMessage)
          .fontSize(14).fontColor('#FFFFFF').backgroundColor('#333333').borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .position({ x: '50%', y: '85%' }).translate({ x: '-50%' })
          .opacity(this.showToast ? 1 : 0).animation({ duration: 300 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
