@Component
export struct UserBadge {
  @Prop avatar: Resource = $r('app.media.avatar')
  @Prop name: string = ''
  @Prop role: string = ''

  build() {
    Row({ space: 12 }) {
      Image(this.avatar)
        .width(52)
        .height(52)
        .borderRadius(26)
        .border({ width: 2, color: '#FFFFFF' })
        .shadow({ radius: 8, color: '#22000000', offsetY: 3 })

      Column({ space: 4 }) {
        Text(this.name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Text(this.role)
          .fontSize(12)
          .fontColor('#6B7280')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('已认证')
        .fontSize(11)
        .fontColor('#0F766E')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#CCFBF1')
        .borderRadius(12)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 10, color: '#10000000', offsetY: 4 })
  }
}
