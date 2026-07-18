/**
 * Canvas 动画界面
 * 基于 Canvas 组件 + CanvasRenderingContext2D 命令式绘图
 * 包含：粒子系统、波浪动画、弹球物理、星空背景、烟花特效
 */

import { LengthMetrics } from '@kit.ArkUI';

interface AnimParticle {
  x: number
  y: number
  vx: number
  vy: number
  radius: number
  color: string
  life: number
  maxLife: number
}

interface Ball {
  x: number
  y: number
  vx: number
  vy: number
  radius: number
  color: string
}

interface WaveConfig {
  amp: number
  freq: number
  speed: number
  color: string
  y: number
}

interface Star {
  x: number
  y: number
  radius: number
  alpha: number
  deltaAlpha: number
}

type AnimMode = 'particles' | 'wave' | 'bouncing' | 'starfield' | 'fireworks'

@Entry
@Component
struct CanvasAnimation {
  // ── 画布上下文 ──
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  // ── 动画状态 ──
  @State currentMode: AnimMode = 'particles'
  @State isRunning: boolean = true
  @State fps: number = 0
  @State particleCount: number = 0
  @State animSpeed: number = 1.0
  @State canvasWidth: number = 360
  @State canvasHeight: number = 480
  @State showSettings: boolean = false
  @State frameCount: number = 0

  // ── 内部数据 ──
  private particles: AnimParticle[] = []
  private balls: Ball[] = []
  private stars: Star[] = []
  private waveOffset: number = 0
  private timer: number = -1
  private fpsFrames: number = 0
  private fpsLastTime: number = 0
  private lastTouchX: number = 0
  private lastTouchY: number = 0
  private hasTouch: boolean = false

  // ── 颜色池 ──
  private readonly COLORS: string[] = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
    '#FFEAA7', '#DDA0DD', '#98D8C8', '#F7DC6F',
    '#BB8FCE', '#85C1E9', '#F8C471', '#82E0AA'
  ]

  aboutToAppear(): void {
    this.fpsLastTime = Date.now()
    this.initMode(this.currentMode)
    this.startLoop()
  }

  aboutToDisappear(): void {
    this.stopLoop()
  }

  // ═══════════════════════════════════════
  //  动画循环控制
  // ═══════════════════════════════════════

  private startLoop(): void {
    if (this.timer !== -1) return
    this.isRunning = true
    const tick = () => {
      if (!this.isRunning) return
      this.update()
      this.draw()
      this.updateFPS()
      this.timer = setTimeout(tick, 16) as number
    }
    tick()
  }

  private stopLoop(): void {
    if (this.timer !== -1) {
      clearTimeout(this.timer as number)
      this.timer = -1
    }
    this.isRunning = false
  }

  private togglePlay(): void {
    if (this.isRunning) {
      this.stopLoop()
    } else {
      this.startLoop()
    }
  }

  private updateFPS(): void {
    this.fpsFrames++
    const now = Date.now()
    if (now - this.fpsLastTime >= 1000) {
      this.fps = this.fpsFrames
      this.fpsFrames = 0
      this.fpsLastTime = now
    }
  }

  // ═══════════════════════════════════════
  //  模式初始化
  // ═══════════════════════════════════════

  private initMode(mode: AnimMode): void {
    this.particles = []
    this.balls = []
    this.stars = []
    this.waveOffset = 0
    this.frameCount = 0

    switch (mode) {
      case 'particles': this.initParticles(); break
      case 'wave': break
      case 'bouncing': this.initBalls(); break
      case 'starfield': this.initStars(); break
      case 'fireworks': break
    }
  }

  private switchMode(mode: AnimMode): void {
    this.currentMode = mode
    this.initMode(mode)
  }

  // ═══════════════════════════════════════
  //  粒子系统
  // ═══════════════════════════════════════

  private initParticles(): void {
    for (let i = 0; i < 80; i++) {
      this.spawnParticle()
    }
  }

  private spawnParticle(): void {
    const color = this.COLORS[Math.floor(Math.random() * this.COLORS.length)]
    const maxLife = 120 + Math.random() * 180
    this.particles.push({
      x: Math.random() * this.canvasWidth,
      y: Math.random() * this.canvasHeight,
      vx: (Math.random() - 0.5) * 2 * this.animSpeed,
      vy: (Math.random() - 0.5) * 2 * this.animSpeed,
      radius: 2 + Math.random() * 4,
      color: color,
      life: maxLife,
      maxLife: maxLife
    })
  }

  private updateParticles(): void {
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i]
      p.x += p.vx * this.animSpeed
      p.y += p.vy * this.animSpeed
      p.life -= this.animSpeed
      if (p.x < 0 || p.x > this.canvasWidth) p.vx *= -1
      if (p.y < 0 || p.y > this.canvasHeight) p.vy *= -1
      if (p.life <= 0) {
        this.particles.splice(i, 1)
        this.spawnParticle()
      }
    }

    if (this.hasTouch) {
      for (let i = 0; i < 3; i++) {
        const color = this.COLORS[Math.floor(Math.random() * this.COLORS.length)]
        this.particles.push({
          x: this.lastTouchX + (Math.random() - 0.5) * 40,
          y: this.lastTouchY + (Math.random() - 0.5) * 40,
          vx: (Math.random() - 0.5) * 4,
          vy: (Math.random() - 0.5) * 4,
          radius: 2 + Math.random() * 5,
          color: color,
          life: 60 + Math.random() * 100,
          maxLife: 160
        })
      }
      this.hasTouch = false
    }
    this.particleCount = this.particles.length
  }

  private drawParticles(): void {
    const ctx = this.ctx
    for (let i = 0; i < this.particles.length; i++) {
      for (let j = i + 1; j < this.particles.length; j++) {
        const a = this.particles[i]
        const b = this.particles[j]
        const dx = a.x - b.x
        const dy = a.y - b.y
        const dist = Math.sqrt(dx * dx + dy * dy)
        if (dist < 100) {
          const alpha = (1 - dist / 100) * 0.3
          ctx.strokeStyle = `rgba(255,255,255,${alpha})`
          ctx.lineWidth = 0.5
          ctx.beginPath()
          ctx.moveTo(a.x, a.y)
          ctx.lineTo(b.x, b.y)
          ctx.stroke()
        }
      }
    }

    for (const p of this.particles) {
      const alpha = Math.min(1, p.life / (p.maxLife * 0.3))
      ctx.globalAlpha = alpha
      ctx.fillStyle = p.color
      ctx.beginPath()
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2)
      ctx.fill()
      ctx.globalAlpha = alpha * 0.3
      ctx.beginPath()
      ctx.arc(p.x, p.y, p.radius * 2.5, 0, Math.PI * 2)
      ctx.fill()
    }
    ctx.globalAlpha = 1
  }

  // ═══════════════════════════════════════
  //  波浪动画
  // ═══════════════════════════════════════

  private drawWave(): void {
    const ctx = this.ctx
    const w = this.canvasWidth
    const h = this.canvasHeight
    this.waveOffset += 0.03 * this.animSpeed

    const waves: WaveConfig[] = [
      { amp: 30, freq: 0.02, speed: 1, color: '#4ECDC4', y: h * 0.55 },
      { amp: 25, freq: 0.025, speed: 1.3, color: '#45B7D1', y: h * 0.60 },
      { amp: 20, freq: 0.03, speed: 0.8, color: '#96CEB4', y: h * 0.65 },
      { amp: 35, freq: 0.015, speed: 1.5, color: '#85C1E9', y: h * 0.70 },
      { amp: 22, freq: 0.035, speed: 1.1, color: '#DDA0DD', y: h * 0.75 }
    ]

    for (const wave of waves) {
      ctx.fillStyle = wave.color
      ctx.globalAlpha = 0.6
      ctx.beginPath()
      ctx.moveTo(0, h)
      for (let x = 0; x <= w; x += 2) {
        const y = wave.y +
          Math.sin(x * wave.freq + this.waveOffset * wave.speed) * wave.amp +
          Math.sin(x * wave.freq * 0.5 + this.waveOffset * wave.speed * 0.7) * wave.amp * 0.5
        ctx.lineTo(x, y)
      }
      ctx.lineTo(w, h)
      ctx.closePath()
      ctx.fill()
    }

    ctx.globalAlpha = 1
    const moonX = w * 0.75
    const moonY = h * 0.2
    const moonR = 35

    const moonGlow = ctx.createRadialGradient(moonX, moonY, moonR * 0.5, moonX, moonY, moonR * 4)
    moonGlow.addColorStop(0, 'rgba(255,255,200,0.3)')
    moonGlow.addColorStop(1, 'rgba(255,255,200,0)')
    ctx.fillStyle = moonGlow
    ctx.beginPath()
    ctx.arc(moonX, moonY, moonR * 4, 0, Math.PI * 2)
    ctx.fill()

    ctx.fillStyle = '#FFFDE7'
    ctx.beginPath()
    ctx.arc(moonX, moonY, moonR, 0, Math.PI * 2)
    ctx.fill()

    ctx.fillStyle = '#1a1a2e'
    ctx.beginPath()
    ctx.arc(moonX + 12, moonY - 5, moonR * 0.85, 0, Math.PI * 2)
    ctx.fill()
  }

  // ═══════════════════════════════════════
  //  弹球物理
  // ═══════════════════════════════════════

  private initBalls(): void {
    for (let i = 0; i < 8; i++) {
      const r = 12 + Math.random() * 20
      this.balls.push({
        x: r + Math.random() * (this.canvasWidth - 2 * r),
        y: r + Math.random() * (this.canvasHeight * 0.5),
        vx: (Math.random() - 0.5) * 4 * this.animSpeed,
        vy: Math.random() * 2 * this.animSpeed,
        radius: r,
        color: this.COLORS[i % this.COLORS.length]
      })
    }
  }

  private updateBalls(): void {
    const gravity = 0.15 * this.animSpeed
    const friction = 0.998
    const bounce = 0.85

    for (const ball of this.balls) {
      ball.vy += gravity
      ball.x += ball.vx * this.animSpeed
      ball.y += ball.vy * this.animSpeed

      if (ball.y + ball.radius > this.canvasHeight) {
        ball.y = this.canvasHeight - ball.radius
        ball.vy *= -bounce
        ball.vx *= friction
      }
      if (ball.x - ball.radius < 0) {
        ball.x = ball.radius
        ball.vx *= -bounce
      }
      if (ball.x + ball.radius > this.canvasWidth) {
        ball.x = this.canvasWidth - ball.radius
        ball.vx *= -bounce
      }
      if (ball.y - ball.radius < 0) {
        ball.y = ball.radius
        ball.vy *= -bounce
      }
    }

    for (let i = 0; i < this.balls.length; i++) {
      for (let j = i + 1; j < this.balls.length; j++) {
        const a = this.balls[i]
        const b = this.balls[j]
        const dx = b.x - a.x
        const dy = b.y - a.y
        const dist = Math.sqrt(dx * dx + dy * dy)
        const minDist = a.radius + b.radius

        if (dist < minDist && dist > 0) {
          const nx = dx / dist
          const ny = dy / dist
          const overlap = (minDist - dist) / 2
          a.x -= nx * overlap
          a.y -= ny * overlap
          b.x += nx * overlap
          b.y += ny * overlap

          const dvx = a.vx - b.vx
          const dvy = a.vy - b.vy
          const dotProduct = dvx * nx + dvy * ny
          a.vx -= dotProduct * nx
          a.vy -= dotProduct * ny
          b.vx += dotProduct * nx
          b.vy += dotProduct * ny
        }
      }
    }

    if (this.hasTouch) {
      for (const ball of this.balls) {
        const dx = ball.x - this.lastTouchX
        const dy = ball.y - this.lastTouchY
        const dist = Math.max(30, Math.sqrt(dx * dx + dy * dy))
        const force = 800 / (dist * dist) * this.animSpeed
        ball.vx += (dx / dist) * force
        ball.vy += (dy / dist) * force
      }
      this.hasTouch = false
    }
  }

  private drawBalls(): void {
    const ctx = this.ctx

    const groundGrad = ctx.createLinearGradient(0, this.canvasHeight - 30, 0, this.canvasHeight)
    groundGrad.addColorStop(0, 'rgba(100,100,100,0.3)')
    groundGrad.addColorStop(1, 'rgba(60,60,60,0.5)')
    ctx.fillStyle = groundGrad
    ctx.fillRect(0, this.canvasHeight - 4, this.canvasWidth, 4)

    for (const ball of this.balls) {
      ctx.fillStyle = 'rgba(0,0,0,0.15)'
      ctx.beginPath()
      ctx.ellipse(ball.x + 3, this.canvasHeight - 2, ball.radius * 0.8, 4, 0, 0, Math.PI * 2)
      ctx.fill()

      const grad = ctx.createRadialGradient(
        ball.x - ball.radius * 0.3, ball.y - ball.radius * 0.3, ball.radius * 0.1,
        ball.x, ball.y, ball.radius
      )
      grad.addColorStop(0, '#FFFFFF')
      grad.addColorStop(0.3, ball.color)
      grad.addColorStop(1, this.darkenColor(ball.color, 0.6))
      ctx.fillStyle = grad
      ctx.beginPath()
      ctx.arc(ball.x, ball.y, ball.radius, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(255,255,255,0.4)'
      ctx.beginPath()
      ctx.arc(ball.x - ball.radius * 0.25, ball.y - ball.radius * 0.25, ball.radius * 0.25, 0, Math.PI * 2)
      ctx.fill()
    }
  }

  // ═══════════════════════════════════════
  //  星空背景
  // ═══════════════════════════════════════

  private initStars(): void {
    for (let i = 0; i < 150; i++) {
      this.stars.push({
        x: Math.random() * this.canvasWidth,
        y: Math.random() * this.canvasHeight,
        radius: 0.5 + Math.random() * 2,
        alpha: Math.random(),
        deltaAlpha: (Math.random() - 0.5) * 0.02
      })
    }
  }

  private updateStars(): void {
    for (const star of this.stars) {
      star.alpha += star.deltaAlpha * this.animSpeed
      if (star.alpha > 1 || star.alpha < 0.1) {
        star.deltaAlpha *= -1
      }
    }
  }

  private drawStarfield(): void {
    const ctx = this.ctx
    const w = this.canvasWidth
    const h = this.canvasHeight

    const skyGrad = ctx.createLinearGradient(0, 0, 0, h)
    skyGrad.addColorStop(0, '#0a0a2e')
    skyGrad.addColorStop(0.5, '#1a1a4e')
    skyGrad.addColorStop(1, '#2a1a3e')
    ctx.fillStyle = skyGrad
    ctx.fillRect(0, 0, w, h)

    for (const star of this.stars) {
      ctx.globalAlpha = star.alpha
      ctx.fillStyle = '#FFFFFF'
      ctx.beginPath()
      ctx.arc(star.x, star.y, star.radius, 0, Math.PI * 2)
      ctx.fill()

      if (star.radius > 1.2) {
        ctx.globalAlpha = star.alpha * 0.3
        ctx.strokeStyle = '#FFFFFF'
        ctx.lineWidth = 0.5
        ctx.beginPath()
        ctx.moveTo(star.x - star.radius * 3, star.y)
        ctx.lineTo(star.x + star.radius * 3, star.y)
        ctx.moveTo(star.x, star.y - star.radius * 3)
        ctx.lineTo(star.x, star.y + star.radius * 3)
        ctx.stroke()
      }
    }

    ctx.globalAlpha = 1
    if (Math.random() < 0.02 * this.animSpeed) {
      const sx = Math.random() * w
      const sy = Math.random() * h * 0.5
      const len = 40 + Math.random() * 80
      const angle = Math.PI / 4 + (Math.random() - 0.5) * 0.3
      const grad = ctx.createLinearGradient(sx, sy, sx + Math.cos(angle) * len, sy + Math.sin(angle) * len)
      grad.addColorStop(0, 'rgba(255,255,255,0.8)')
      grad.addColorStop(1, 'rgba(255,255,255,0)')
      ctx.strokeStyle = grad
      ctx.lineWidth = 1.5
      ctx.beginPath()
      ctx.moveTo(sx, sy)
      ctx.lineTo(sx + Math.cos(angle) * len, sy + Math.sin(angle) * len)
      ctx.stroke()
    }

    ctx.globalAlpha = 0.05
    const bandGrad = ctx.createLinearGradient(0, h * 0.3, w, h * 0.7)
    bandGrad.addColorStop(0, 'rgba(200,200,255,0)')
    bandGrad.addColorStop(0.5, 'rgba(200,200,255,0.12)')
    bandGrad.addColorStop(1, 'rgba(200,200,255,0)')
    ctx.fillStyle = bandGrad
    ctx.fillRect(0, h * 0.25, w, h * 0.5)
    ctx.globalAlpha = 1
  }

  // ═══════════════════════════════════════
  //  烟花系统
  // ═══════════════════════════════════════

  private updateFireworks(): void {
    this.frameCount++

    if (this.frameCount % Math.floor(40 / this.animSpeed) === 0) {
      const x = 50 + Math.random() * (this.canvasWidth - 100)
      const targetY = 50 + Math.random() * (this.canvasHeight * 0.4)
      const color = this.COLORS[Math.floor(Math.random() * this.COLORS.length)]
      this.particles.push({
        x: x, y: this.canvasHeight,
        vx: (Math.random() - 0.5) * 0.5,
        vy: -(4 + Math.random() * 3),
        radius: 3,
        color: color,
        life: (this.canvasHeight - targetY) / 5,
        maxLife: 100
      })
    }

    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i]
      p.x += p.vx * this.animSpeed
      p.y += p.vy * this.animSpeed
      p.life -= this.animSpeed

      if (p.vy < 0 && p.life <= 0 && p.radius >= 2) {
        const count = 30 + Math.floor(Math.random() * 30)
        for (let j = 0; j < count; j++) {
          const angle = (j / count) * Math.PI * 2
          const speed = 1.5 + Math.random() * 3
          this.particles.push({
            x: p.x, y: p.y,
            vx: Math.cos(angle) * speed,
            vy: Math.sin(angle) * speed,
            radius: 1 + Math.random() * 1.5,
            color: p.color,
            life: 40 + Math.random() * 40,
            maxLife: 80
          })
        }
        this.particles.splice(i, 1)
        continue
      }

      if (p.radius < 2) {
        p.vy += 0.03 * this.animSpeed
      }

      if (p.life <= 0) {
        this.particles.splice(i, 1)
      }
    }
    this.particleCount = this.particles.length
  }

  private drawFireworks(): void {
    const ctx = this.ctx
    for (const p of this.particles) {
      const alpha = Math.max(0, p.life / p.maxLife)
      ctx.globalAlpha = alpha
      ctx.fillStyle = p.color
      ctx.beginPath()
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2)
      ctx.fill()

      if (p.radius < 2) {
        ctx.globalAlpha = alpha * 0.3
        ctx.beginPath()
        ctx.arc(p.x - p.vx * 2, p.y - p.vy * 2, p.radius * 0.6, 0, Math.PI * 2)
        ctx.fill()
      }
    }
    ctx.globalAlpha = 1
  }

  // ═══════════════════════════════════════
  //  核心更新与绘制
  // ═══════════════════════════════════════

  private update(): void {
    switch (this.currentMode) {
      case 'particles': this.updateParticles(); break
      case 'wave': break
      case 'bouncing': this.updateBalls(); break
      case 'starfield': this.updateStars(); break
      case 'fireworks': this.updateFireworks(); break
    }
  }

  private draw(): void {
    const ctx = this.ctx
    const w = this.canvasWidth
    const h = this.canvasHeight

    if (this.currentMode === 'starfield') {
      // starfield draws its own background
    } else {
      ctx.clearRect(0, 0, w, h)
      this.drawBackground()
    }

    switch (this.currentMode) {
      case 'particles': this.drawParticles(); break
      case 'wave': this.drawWave(); break
      case 'bouncing': this.drawBalls(); break
      case 'starfield': this.drawStarfield(); break
      case 'fireworks': this.drawFireworks(); break
    }
    this.drawHUD()
  }

  private drawBackground(): void {
    const ctx = this.ctx
    const grad = ctx.createLinearGradient(0, 0, 0, this.canvasHeight)
    grad.addColorStop(0, '#1a1a2e')
    grad.addColorStop(1, '#16213e')
    ctx.fillStyle = grad
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight)
  }

  private drawHUD(): void {
    const ctx = this.ctx
    const showParticle = this.currentMode === 'particles' || this.currentMode === 'fireworks'
    ctx.globalAlpha = 0.7
    ctx.fillStyle = 'rgba(0,0,0,0.5)'
    ctx.fillRect(8, 8, 110, showParticle ? 52 : 32)
    ctx.globalAlpha = 1
    ctx.fillStyle = '#4ECDC4'
    ctx.font = '12px sans-serif'
    ctx.fillText(`FPS: ${this.fps}`, 16, 24)
    if (showParticle) {
      ctx.fillText(`粒子: ${this.particleCount}`, 16, 42)
    }
  }

  // ═══════════════════════════════════════
  //  工具函数
  // ═══════════════════════════════════════

  private darkenColor(hex: string, factor: number): string {
    let r = parseInt(hex.slice(1, 3), 16)
    let g = parseInt(hex.slice(3, 5), 16)
    let b = parseInt(hex.slice(5, 7), 16)
    r = Math.floor(r * factor)
    g = Math.floor(g * factor)
    b = Math.floor(b * factor)
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`
  }

  private getModeLabel(mode: AnimMode): string {
    if (mode === 'particles') return '✨ 粒子连线'
    if (mode === 'wave') return '🌊 海浪月色'
    if (mode === 'bouncing') return '⚽ 弹球物理'
    if (mode === 'starfield') return '🌟 星空闪烁'
    if (mode === 'fireworks') return '🎆 绚丽烟花'
    return '✨ 粒子连线'
  }

  // ═══════════════════════════════════════
  //  UI 构建
  // ═══════════════════════════════════════

  @Builder
  ModeSelector() {
    Column({ space: 8 }) {
      Text('动画模式')
        .fontSize(13).fontColor('#AAAAAA')
        .width('100%').textAlign(TextAlign.Start)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        ForEach(['particles', 'wave', 'bouncing', 'starfield', 'fireworks'], (mode: string) => {
          Button(this.getModeLabel(mode as AnimMode))
            .fontSize(13)
            .fontColor(this.currentMode === mode ? '#FFFFFF' : '#CCCCCC')
            .backgroundColor(this.currentMode === mode ? '#4ECDC4' : '#2a2a4e')
            .borderRadius(20)
            .height(36)
            .padding({ left: 14, right: 14 })
            .onClick(() => {
              this.switchMode(mode as AnimMode)
            })
            .margin(4)
        }, (mode: string) => mode)
      }.width('100%')
    }
    .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
  }

  @Builder
  ControlBar() {
    Row({ space: 12 }) {
      Button(this.isRunning ? '⏸ 暂停' : '▶ 播放')
        .fontSize(14).fontColor('#FFFFFF')
        .backgroundColor(this.isRunning ? '#FF6B6B' : '#4ECDC4')
        .borderRadius(20).height(40)
        .layoutWeight(1)
        .onClick(() => { this.togglePlay() })

      Button('🔄 重置')
        .fontSize(14).fontColor('#FFFFFF')
        .backgroundColor('#45B7D1')
        .borderRadius(20).height(40)
        .layoutWeight(1)
        .onClick(() => { this.initMode(this.currentMode) })

      Button(this.showSettings ? '✕ 关闭' : '⚙ 设置')
        .fontSize(14).fontColor('#FFFFFF')
        .backgroundColor(this.showSettings ? '#FF6B6B' : '#BB8FCE')
        .borderRadius(20).height(40)
        .layoutWeight(1)
        .onClick(() => { this.showSettings = !this.showSettings })
    }
    .width('100%').padding({ left: 16, right: 16 })
  }

  @Builder
  SpeedControl() {
    Column({ space: 8 }) {
      Row() {
        Text('动画速度').fontSize(13).fontColor('#AAAAAA')
        Blank()
        Text(`${this.animSpeed.toFixed(1)}x`).fontSize(13).fontColor('#4ECDC4')
      }.width('100%')

      Row({ space: 8 }) {
        ForEach([0.3, 0.5, 1.0, 1.5, 2.0], (speed: number) => {
          Button(`${speed}x`)
            .fontSize(12).fontColor(this.animSpeed === speed ? '#FFFFFF' : '#AAAAAA')
            .backgroundColor(this.animSpeed === speed ? '#4ECDC4' : '#2a2a4e')
            .borderRadius(14).height(30)
            .padding({ left: 12, right: 12 })
            .onClick(() => { this.animSpeed = speed })
        }, (speed: number) => speed.toString())
      }.width('100%')
    }
    .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('rgba(30,30,60,0.8)')
    .borderRadius(12).margin({ left: 16, right: 16 })
  }

  @Builder
  InfoPanel() {
    Column({ space: 4 }) {
      Text(this.getModeLabel(this.currentMode))
        .fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
      Text(this.currentMode === 'particles' ? '点击画布产生粒子' :
        this.currentMode === 'bouncing' ? '点击画布施加力' :
          this.currentMode === 'fireworks' ? '自动发射烟花' :
            this.currentMode === 'wave' ? '多层海浪 + 月色' :
              '150颗闪烁星星 + 流星')
        .fontSize(12).fontColor('#888888')
    }
    .width('100%').padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Row() {
        Text('🎨 Canvas 动画工坊')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Blank()
        Text(`FPS ${this.fps}`)
          .fontSize(12).fontColor('#4ECDC4')
          .backgroundColor('rgba(78,205,196,0.15)')
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })

      this.ModeSelector()

      Canvas(this.ctx)
        .width('100%')
        .aspectRatio(0.75)
        .backgroundColor('#1a1a2e')
        .borderRadius(16)
        .margin({ left: 16, right: 16 })
        .onReady(() => {
          this.canvasWidth = this.ctx.width
          this.canvasHeight = this.ctx.height
          this.initMode(this.currentMode)
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down || event.type === TouchType.Move) {
            const touch = event.touches[0]
            this.lastTouchX = touch.x
            this.lastTouchY = touch.y
            this.hasTouch = true
          }
        })

      this.InfoPanel()
      this.ControlBar()

      if (this.showSettings) {
        this.SpeedControl()
      }

      Blank()
    }
    .width('100%').height('100%')
    .backgroundColor('#0f0f23')
  }
}
