@Component
export struct ActionBanner {
  @Prop title: string = ''
  @Prop description: string = ''
  @Prop buttonText: string = ''

  build() {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(this.description)
          .fontSize(12)
          .lineHeight(18)
          .fontColor('#DDE7FF')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.buttonText)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3158D4')
        .padding({ left: 12, right: 12, top: 7, bottom: 7 })
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
    }
    .width('100%')
    .padding(16)
    .linearGradient({
      angle: 135,
      colors: [['#3158D4', 0], ['#23A6A6', 1]]
    })
    .borderRadius(18)
    .shadow({ radius: 12, color: '#223158D4', offsetY: 5 })
  }
}
