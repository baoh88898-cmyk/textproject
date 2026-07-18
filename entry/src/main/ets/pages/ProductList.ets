/**
 * ProductList - 高性能商品列表页（完整CRUD系统）
 * 增删改查 + 搜索筛选 + 排序 + 懒加载
 */

interface ProductItem {
  id: number
  name: string
  price: number
  rating: number
  image: Resource
  sales: number
  category: string
  tags: string[]
}

class ProductDataSource implements IDataSource {
  private items: ProductItem[] = []
  private listeners: DataChangeListener[] = []
  private nextId: number = 1

  constructor(items: ProductItem[]) {
    this.items = items
    if (items.length > 0) this.nextId = items[items.length - 1].id + 1
  }
  totalCount(): number { return this.items.length }
  getData(index: number): ProductItem { return this.items[index] }
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) this.listeners.push(listener)
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener)
    if (idx >= 0) this.listeners.splice(idx, 1)
  }
  appendData(newItems: ProductItem[]): void {
    const count = this.items.length
    this.items = this.items.concat(newItems)
    this.listeners.forEach((l) => { l.onDataAdd(count) })
  }
  addItem(item: ProductItem): void {
    item.id = this.nextId++
    this.items.unshift(item)
    this.listeners.forEach((l) => { l.onDataAdd(0) })
  }
  updateItem(index: number, item: ProductItem): void {
    if (index >= 0 && index < this.items.length) {
      this.items[index] = item
      this.listeners.forEach((l) => { l.onDataChange(index) })
    }
  }
  deleteData(index: number): void {
    if (index >= 0 && index < this.items.length) {
      this.items.splice(index, 1)
      this.listeners.forEach((l) => { l.onDataDelete(index) })
    }
  }
  findIndex(id: number): number {
    return this.items.findIndex((item) => item.id === id)
  }
  replaceAll(newItems: ProductItem[]): void {
    this.items = newItems
    this.listeners.forEach((l) => { l.onDataReloaded() })
  }
}

@Entry
@Component
struct ProductList {
  @State private dataSource: ProductDataSource = new ProductDataSource([])
  @State private fullData: ProductItem[] = []
  @State private showBackTop: boolean = false
  @State private isLoading: boolean = false
  @State private page: number = 0
  @State private searchText: string = ""
  @State private selectedCategory: string = "全部"
  @State private sortOrder: number = 0
  @State private showAddForm: boolean = false
  @State private newName: string = ""
  @State private newPrice: string = ""
  @State private newRating: string = "4.5"
  @State private newCategory: string = "数码"
  @State private showDeleteConfirm: boolean = false
  @State private deleteTargetId: number = -1
  @State private deleteTargetName: string = ""
  @State private showEditForm: boolean = false
  @State private editId: number = -1
  @State private editName: string = ""
  @State private editPrice: string = ""
  @State private editRating: string = ""
  @State private editCategory: string = ""
  @State private showDetail: boolean = false
  @State private detailItem: ProductItem | null = null

  private imagePool: Resource[] = [$r("app.media.avatar"), $r("app.media.login_logo")]
  private categories: string[] = ["全部", "数码", "穿戴", "音频", "配件"]
  private categoryOptions: string[] = ["数码", "穿戴", "音频", "配件"]
  private namePool: string[] = [
    "华为 FreeBuds Pro 3 无线耳机", "MatePad Pro 13.2 平板电脑",
    "WATCH GT 5 Pro 智能手表", "MateBook X Pro 笔记本",
    "Sound X 智能音箱", "华为路由 BE7 WiFi7路由器",
    "Mate 70 Pro 手机壳套装", "FreeClip 开放式耳机",
    "MateView SE 显示器", "智能体脂秤 Pro"
  ]
  private catPool: string[] = ["音频", "数码", "穿戴", "数码", "音频", "数码", "配件", "音频", "数码", "配件"]

  aboutToAppear(): void { this.loadMore() }

  private loadMore(): void {
    if (this.isLoading) return
    this.isLoading = true
    this.page++
    setTimeout(() => {
      const batch: ProductItem[] = []
      const start = this.fullData.length
      for (let i = 0; i < 20; i++) {
        const idx = start + i + 1
        batch.push({
          id: idx,
          name: this.namePool[idx % this.namePool.length],
          price: Number(((idx * 37.3) % 5000 + 99).toFixed(2)),
          rating: Number(((((idx * 7) % 20) + 30) / 10).toFixed(1)),
          image: this.imagePool[idx % this.imagePool.length],
          sales: Math.floor((idx * 137) % 9999 + 100),
          category: this.catPool[idx % this.catPool.length],
          tags: idx % 4 === 0 ? ["新品"] : idx % 7 === 0 ? ["热销"] : idx % 5 === 0 ? ["限时"] : []
        })
      }
      this.fullData = this.fullData.concat(batch)
      this.applyFilter()
      this.isLoading = false
    }, 300)
  }

  private applyFilter(): void {
    let result = this.fullData.slice()
    if (this.selectedCategory !== "全部") {
      result = result.filter((item) => item.category === this.selectedCategory)
    }
    if (this.searchText.trim().length > 0) {
      const kw = this.searchText.trim().toLowerCase()
      result = result.filter((item) => item.name.toLowerCase().indexOf(kw) >= 0)
    }
    if (this.sortOrder === 1) {
      result.sort((a, b) => a.price - b.price)
    } else if (this.sortOrder === 2) {
      result.sort((a, b) => b.price - a.price)
    } else if (this.sortOrder === 3) {
      result.sort((a, b) => b.rating - a.rating)
    } else if (this.sortOrder === 4) {
      result.sort((a, b) => b.sales - a.sales)
    }
    this.dataSource.replaceAll(result)
  }

  private addProduct(): void {
    if (this.newName.trim().length === 0 || this.newPrice.trim().length === 0) return
    const price = Number(this.newPrice)
    if (isNaN(price) || price <= 0) return
    const rating = Number(this.newRating)
    if (isNaN(rating) || rating < 0 || rating > 5) return
    const newItem: ProductItem = {
      id: 0, name: this.newName.trim(), price: price,
      rating: Number(rating.toFixed(1)),
      image: this.imagePool[this.fullData.length % this.imagePool.length],
      sales: 0, category: this.newCategory, tags: ["新品"]
    }
    this.fullData.unshift(newItem)
    const nextId = (this.fullData.length > 0) ? this.fullData[0].id : 1
    this.applyFilter()
    this.newName = ""; this.newPrice = ""; this.newRating = "4.5"; this.newCategory = "数码"
    this.showAddForm = false
  }

  private openEdit(item: ProductItem): void {
    this.editId = item.id
    this.editName = item.name
    this.editPrice = item.price.toString()
    this.editRating = item.rating.toString()
    this.editCategory = item.category
    this.showEditForm = true
  }

  private saveEdit(): void {
    if (this.editName.trim().length === 0 || this.editPrice.trim().length === 0) return
    const price = Number(this.editPrice)
    if (isNaN(price) || price <= 0) return
    const rating = Number(this.editRating)
    if (isNaN(rating) || rating < 0 || rating > 5) return
    const fIdx = this.fullData.findIndex((it) => it.id === this.editId)
    if (fIdx >= 0) {
      this.fullData[fIdx].name = this.editName.trim()
      this.fullData[fIdx].price = price
      this.fullData[fIdx].rating = Number(rating.toFixed(1))
      this.fullData[fIdx].category = this.editCategory
    }
    this.applyFilter()
    this.showEditForm = false
    this.editId = -1
  }

  private cancelEdit(): void {
    this.showEditForm = false
    this.editId = -1
  }

  private confirmDelete(id: number, name: string): void {
    this.deleteTargetId = id
    this.deleteTargetName = name
    this.showDeleteConfirm = true
  }

  private doDelete(): void {
    const fIdx = this.fullData.findIndex((it) => it.id === this.deleteTargetId)
    if (fIdx >= 0) this.fullData.splice(fIdx, 1)
    this.applyFilter()
    this.showDeleteConfirm = false
    this.deleteTargetId = -1
    this.deleteTargetName = ""
  }

  private cancelDelete(): void {
    this.showDeleteConfirm = false
    this.deleteTargetId = -1
    this.deleteTargetName = ""
  }

  private openDetail(item: ProductItem): void {
    this.detailItem = item
    this.showDetail = true
  }

  private closeDetail(): void {
    this.showDetail = false
    this.detailItem = null
  }

  @Builder
  StarRating(rating: number) {
    Row({ space: 2 }) {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Text(i <= Math.round(rating) ? "★" : "☆")
          .fontSize(12).fontColor(i <= Math.round(rating) ? "#FF9800" : "#DDDDDD")
      }, (i: number) => i.toString())
    }
  }

  @Builder
  CategoryTabs() {
    Row({ space: 8 }) {
      ForEach(this.categories, (cat: string) => {
        Text(cat)
          .fontSize(13)
          .fontColor(this.selectedCategory === cat ? "#FFFFFF" : "#666666")
          .backgroundColor(this.selectedCategory === cat ? "#667eea" : "#F0F0F0")
          .borderRadius(14)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .onClick(() => { this.selectedCategory = cat; this.applyFilter() })
      }, (cat: string) => cat)
    }
    .width("100%").padding({ left: 16, right: 16 })
  }

  @Builder
  SortBar() {
    Row({ space: 0 }) {
      Text("综合").fontSize(13).fontColor(this.sortOrder === 0 ? "#667eea" : "#999999")
        .fontWeight(this.sortOrder === 0 ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1).textAlign(TextAlign.Center).padding(8)
        .onClick(() => { this.sortOrder = 0; this.applyFilter() })
      Text("价格↑").fontSize(13).fontColor(this.sortOrder === 1 ? "#667eea" : "#999999")
        .fontWeight(this.sortOrder === 1 ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1).textAlign(TextAlign.Center).padding(8)
        .onClick(() => { this.sortOrder = 1; this.applyFilter() })
      Text("价格↓").fontSize(13).fontColor(this.sortOrder === 2 ? "#667eea" : "#999999")
        .fontWeight(this.sortOrder === FontWeight.Bold ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1).textAlign(TextAlign.Center).padding(8)
        .onClick(() => { this.sortOrder = 2; this.applyFilter() })
      Text("评分").fontSize(13).fontColor(this.sortOrder === 3 ? "#667eea" : "#999999")
        .fontWeight(this.sortOrder === 3 ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1).textAlign(TextAlign.Center).padding(8)
        .onClick(() => { this.sortOrder = 3; this.applyFilter() })
      Text("销量").fontSize(13).fontColor(this.sortOrder === 4 ? "#667eea" : "#999999")
        .fontWeight(this.sortOrder === 4 ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1).textAlign(TextAlign.Center).padding(8)
        .onClick(() => { this.sortOrder = 4; this.applyFilter() })
    }
    .width("100%").backgroundColor("#FFFFFF")
    .border({ width: { bottom: 1 }, color: "#F0F0F0" })
  }

  @Builder
  ProductItemCard(item: ProductItem) {
    Row({ space: 12 }) {
      Image(item.image).width(100).height(100).borderRadius(10)
        .objectFit(ImageFit.Cover).backgroundColor("#F5F5F5")
        .onClick(() => { this.openDetail(item) })
      Column({ space: 6 }) {
        Row() {
          Text(item.name).fontSize(15).fontWeight(FontWeight.Medium).fontColor("#1A1A1A")
            .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(20).layoutWeight(1)
            .onClick(() => { this.openDetail(item) })
          Row({ space: 8 }) {
            Text("编辑").fontSize(12).fontColor("#667eea")
              .onClick(() => { this.openEdit(item) })
            Text("删除").fontSize(12).fontColor("#E53935")
              .onClick(() => { this.confirmDelete(item.id, item.name) })
          }
        }.width("100%").alignItems(VerticalAlign.Top)
        Row({ space: 6 }) {
          Text(item.category).fontSize(10).fontColor("#667eea").backgroundColor("#EEF0FF")
            .borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 })
          if (item.tags.length > 0) {
            ForEach(item.tags, (tag: string) => {
              Text(tag).fontSize(10).fontColor("#FFFFFF").backgroundColor("#FF7043")
                .borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 })
            }, (tag: string) => tag)
          }
        }
        Row({ space: 4 }) {
          Text("¥").fontSize(13).fontColor("#E53935").fontWeight(FontWeight.Bold)
          Text(item.price.toFixed(2)).fontSize(18).fontColor("#E53935").fontWeight(FontWeight.Bold)
        }.alignItems(VerticalAlign.Bottom)
        Row({ space: 8 }) {
          this.StarRating(item.rating)
          Text(item.rating + "分").fontSize(11).fontColor("#999999")
          Text(item.sales + "+人付款").fontSize(11).fontColor("#999999")
        }
        Text("免运费 · 7天无理由").fontSize(11).fontColor("#BBBBBB")
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween)
    }
    .width("100%").padding(12).backgroundColor("#FFFFFF").borderRadius(12)
    .shadow({ radius: 8, color: "#0D000000", offsetY: 2 })
  }

  @Builder
  LoadingFooter() {
    Row({ space: 8 }) {
      LoadingProgress().width(16).height(16).color("#667eea")
      Text(this.page >= 5 ? "没有更多了" : "加载中...").fontSize(13).fontColor("#999999")
    }.width("100%").height(48).justifyContent(FlexAlign.Center)
  }

  @Builder
  AddEditForm(isEdit: boolean) {
    Column({ space: 12 }) {
      Row() {
        Text(isEdit ? "编辑商品" : "添加商品").fontSize(16).fontWeight(FontWeight.Bold).fontColor("#333333")
        Blank()
        Text("✕").fontSize(18).fontColor("#999999")
          .onClick(() => { isEdit ? this.cancelEdit() : this.showAddForm = false })
      }.width("100%")
      TextInput({ placeholder: "请输入商品名称", text: isEdit ? this.editName : this.newName })
        .width("100%").height(44).fontSize(14).backgroundColor("#F5F5F5").borderRadius(8)
        .onChange((value: string) => { if (isEdit) this.editName = value; else this.newName = value })
      Row({ space: 12 }) {
        TextInput({ placeholder: "价格（元）", text: isEdit ? this.editPrice : this.newPrice })
          .type(InputType.Number).layoutWeight(1).height(44).fontSize(14)
          .backgroundColor("#F5F5F5").borderRadius(8)
          .onChange((value: string) => { if (isEdit) this.editPrice = value; else this.newPrice = value })
        TextInput({ placeholder: "评分(0-5)", text: isEdit ? this.editRating : this.newRating })
          .type(InputType.Number).width(100).height(44).fontSize(14)
          .backgroundColor("#F5F5F5").borderRadius(8)
          .onChange((value: string) => { if (isEdit) this.editRating = value; else this.newRating = value })
      }.width("100%")
      Row({ space: 8 }) {
        Text("分类:").fontSize(14).fontColor("#666666")
        ForEach(this.categoryOptions, (cat: string) => {
          Text(cat).fontSize(12)
            .fontColor((isEdit ? this.editCategory : this.newCategory) === cat ? "#FFFFFF" : "#666666")
            .backgroundColor((isEdit ? this.editCategory : this.newCategory) === cat ? "#667eea" : "#F0F0F0")
            .borderRadius(10).padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .onClick(() => { if (isEdit) this.editCategory = cat; else this.newCategory = cat })
        }, (cat: string) => cat)
      }.width("100%")
      Button(isEdit ? "保存修改" : "添加商品")
        .width("100%").height(44).fontSize(15).fontColor("#FFFFFF")
        .backgroundColor(isEdit ? "#2196F3" : "#4CAF50").borderRadius(10)
        .onClick(() => { if (isEdit) this.saveEdit(); else this.addProduct() })
    }.width("100%").padding(16).backgroundColor("#FFFFFF").borderRadius(14)
    .shadow({ radius: 10, color: "#1A000000", offsetY: 4 })
  }

  @Builder
  DeleteConfirmDialog() {
    Column({ space: 20 }) {
      Text("确认删除").fontSize(18).fontWeight(FontWeight.Bold).fontColor("#333333")
      Text("确定要删除「" + this.deleteTargetName + "」吗？")
        .fontSize(14).fontColor("#666666").textAlign(TextAlign.Center)
      Row({ space: 16 }) {
        Button("取消").width("45%").height(44).fontSize(15).fontColor("#666666")
          .backgroundColor("#F0F0F0").borderRadius(10).onClick(() => { this.cancelDelete() })
        Button("删除").width("45%").height(44).fontSize(15).fontColor("#FFFFFF")
          .backgroundColor("#E53935").borderRadius(10).onClick(() => { this.doDelete() })
      }.width("100%").justifyContent(FlexAlign.SpaceBetween)
    }.width("80%").padding(24).backgroundColor("#FFFFFF").borderRadius(16)
    .shadow({ radius: 20, color: "#33000000", offsetY: 10 })
  }

  @Builder
  DetailDialog(item: ProductItem) {
    Column({ space: 16 }) {
      Row() {
        Text("商品详情").fontSize(18).fontWeight(FontWeight.Bold).fontColor("#333333")
        Blank()
        Text("✕").fontSize(20).fontColor("#999999").onClick(() => { this.closeDetail() })
      }.width("100%")
      Image(item.image).width("100%").height(200).borderRadius(12)
        .objectFit(ImageFit.Cover).backgroundColor("#F5F5F5")
      Column({ space: 8 }) {
        Text(item.name).fontSize(18).fontWeight(FontWeight.Bold).fontColor("#1A1A1A")
        Row({ space: 8 }) {
          Text(item.category).fontSize(12).fontColor("#667eea").backgroundColor("#EEF0FF")
            .borderRadius(4).padding({ left: 8, right: 8, top: 3, bottom: 3 })
          ForEach(item.tags, (tag: string) => {
            Text(tag).fontSize(12).fontColor("#FFFFFF").backgroundColor("#FF7043")
              .borderRadius(4).padding({ left: 8, right: 8, top: 3, bottom: 3 })
          }, (tag: string) => tag)
        }
        Row({ space: 4 }) {
          Text("¥").fontSize(16).fontColor("#E53935").fontWeight(FontWeight.Bold)
          Text(item.price.toFixed(2)).fontSize(28).fontColor("#E53935").fontWeight(FontWeight.Bold)
        }.alignItems(VerticalAlign.Bottom)
        Row({ space: 12 }) {
          this.StarRating(item.rating)
          Text(item.rating + "分").fontSize(14).fontColor("#666666")
          Text(item.sales + "+人付款").fontSize(14).fontColor("#999999")
        }
        Divider()
        Row() { Text("商品编号: ").fontSize(13).fontColor("#999999"); Text("" + item.id).fontSize(13).fontColor("#333333") }.width("100%")
        Row() { Text("服务: ").fontSize(13).fontColor("#999999"); Text("免运费 · 7天无理由退货 · 正品保障").fontSize(13).fontColor("#333333") }.width("100%")
      }.width("100%").alignItems(HorizontalAlign.Start)
      Row({ space: 12 }) {
        Button("编辑").layoutWeight(1).height(44).fontSize(15).fontColor("#FFFFFF")
          .backgroundColor("#2196F3").borderRadius(10)
          .onClick(() => { this.closeDetail(); this.openEdit(item) })
        Button("删除").layoutWeight(1).height(44).fontSize(15).fontColor("#FFFFFF")
          .backgroundColor("#E53935").borderRadius(10)
          .onClick(() => { this.closeDetail(); this.confirmDelete(item.id, item.name) })
      }.width("100%")
    }.width("90%").height("80%").padding(20).backgroundColor("#FFFFFF").borderRadius(16)
    .shadow({ radius: 20, color: "#33000000", offsetY: 10 })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        // 顶部栏
        Row() {
          Text("商品列表").fontSize(20).fontWeight(FontWeight.Bold).fontColor("#1A1A1A")
          Blank()
          Button() {
            Row({ space: 4 }) {
              Text("+").fontSize(18).fontColor("#FFFFFF").fontWeight(FontWeight.Bold)
              Text("添加").fontSize(14).fontColor("#FFFFFF")
            }
          }.height(32).padding({ left: 12, right: 12 }).backgroundColor("#4CAF50").borderRadius(16)
          .onClick(() => { this.showAddForm = !this.showAddForm })
        }.width("100%").padding({ left: 16, right: 16, top: 12, bottom: 8 })

        // 搜索框
        Row({ space: 8 }) {
          TextInput({ placeholder: "搜索商品名称...", text: this.searchText })
            .layoutWeight(1).height(36).fontSize(14).backgroundColor("#F0F0F0").borderRadius(18)
            .padding({ left: 16 }).onChange((value: string) => { this.searchText = value; this.applyFilter() })
          Text("搜索").fontSize(14).fontColor("#667eea").fontWeight(FontWeight.Medium)
            .onClick(() => { this.applyFilter() })
        }.width("100%").padding({ left: 16, right: 16, bottom: 4 })

        // 分类标签
        this.CategoryTabs()

        // 排序栏
        this.SortBar()

        // 添加表单
        if (this.showAddForm) {
          Column() { this.AddEditForm(false) }
            .width("100%").padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        // 商品列表
        List({ space: 10 }) {
          LazyForEach(this.dataSource, (item: ProductItem) => {
            ListItem() { this.ProductItemCard(item) }
          }, (item: ProductItem) => item.id.toString())
          ListItem() { this.LoadingFooter() }
        }
        .width("100%").layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 })
        .edgeEffect(EdgeEffect.Spring).scrollBar(BarState.Off)
        .onReachEnd(() => { if (this.page < 5) this.loadMore() })
        .onScrollIndex((first: number, last: number) => { this.showBackTop = first > 6 })
      }
      .width("100%").height("100%").backgroundColor("#F5F5F5")
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 回到顶部
      if (this.showBackTop) {
        Button() { Text("↑").fontSize(18).fontColor("#FFFFFF").fontWeight(FontWeight.Bold) }
          .width(44).height(44).borderRadius(22).backgroundColor("#667eea")
          .shadow({ radius: 8, color: "#44667eea", offsetY: 4 }).position({ x: "80%", y: "85%" })
      }

      // 编辑弹窗
      if (this.showEditForm) {
        Column().width("100%").height("100%").backgroundColor("#66000000")
          .onClick(() => { this.cancelEdit() })
        Column() { this.AddEditForm(true) }
          .width("100%").height("100%").justifyContent(FlexAlign.Center)
      }

      // 删除确认弹窗
      if (this.showDeleteConfirm) {
        Column().width("100%").height("100%").backgroundColor("#66000000")
          .onClick(() => { this.cancelDelete() })
        Column() { this.DeleteConfirmDialog() }
          .width("100%").height("100%").justifyContent(FlexAlign.Center)
      }

      // 商品详情弹窗
      if (this.showDetail && this.detailItem !== null) {
        Column().width("100%").height("100%").backgroundColor("#66000000")
          .onClick(() => { this.closeDetail() })
        Column() { this.DetailDialog(this.detailItem) }
          .width("100%").height("100%").justifyContent(FlexAlign.Center)
      }
    }
    .width("100%").height("100%")
  }
}