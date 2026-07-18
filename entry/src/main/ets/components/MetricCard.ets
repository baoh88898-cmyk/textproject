@Component
export struct MetricCard {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop accentColor: string = '#2563EB'

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(12)
        .fontColor('#6B7280')
      Text(this.value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
      Row()
        .width(30)
        .height(4)
        .borderRadius(2)
        .backgroundColor(this.accentColor)
    }
    .layoutWeight(1)
    .height(96)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 10, color: '#0D000000', offsetY: 4 })
  }
}
