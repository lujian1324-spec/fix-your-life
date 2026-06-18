# Sierro PWA 部署指南

## 📱 iOS设备安装PWA步骤

### 方法1：通过Safari直接安装（推荐）

1. **部署Web应用**
   - 将 `build/web` 目录上传到Web服务器
   - 确保使用HTTPS协议（iOS要求）

2. **在iOS设备上访问**
   - 打开Safari浏览器
   - 访问您的Web应用URL（例如：https://your-app.com）

3. **添加到主屏幕**
   - 点击底部的"分享"按钮（方框向上箭头）
   - 滚动找到"添加到主屏幕"
   - 点击添加

4. **使用PWA**
   - 返回主屏幕，您会看到Sierro应用图标
   - 点击图标即可像原生应用一样使用

### 方法2：通过企业证书分发

1. **准备企业证书**
   - 注册Apple Developer Enterprise Program
   - 获取企业分发证书

2. **配置应用**
   - 在Xcode中配置企业签名
   - 生成IPA文件

3. **分发应用**
   - 通过OTA方式分发
   - 用户通过Safari访问下载链接安装

## 🌐 Web服务器部署选项

### 选项1：静态网站托管（免费）

#### Vercel部署
```bash
# 安装Vercel CLI
npm i -g vercel

# 部署
cd build/web
vercel --prod
```

#### Netlify部署
```bash
# 安装Netlify CLI
npm i -g netlify-cli

# 部署
cd build/web
netlify deploy --prod
```

#### GitHub Pages
```bash
# 创建gh-pages分支
git checkout --orphan gh-pages
git add build/web/
git commit -m "Deploy PWA"
git push origin gh-pages
```

### 选项2：云服务器部署

#### Nginx配置示例
```nginx
server {
    listen 443 ssl;
    server_name your-app.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    root /path/to/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # PWA headers
    add_header Service-Worker-Allowed /;
    add_header Cache-Control "public, max-age=31536000, immutable";
}
```

#### Apache配置示例
```apache
<VirtualHost *:443>
    ServerName your-app.com
    DocumentRoot /path/to/build/web

    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem

    <Directory /path/to/build/web>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^ /index.html [L]

        Header set Service-Worker-Allowed "/"
        Header set Cache-Control "public, max-age=31536000, immutable"
    </Directory>
</VirtualHost>
```

## 🔧 PWA功能配置

### Service Worker注册
已包含增强的Service Worker，支持：
- ✅ 离线缓存
- ✅ 后台同步
- ✅ 推送通知
- ✅ 自动更新

### Manifest配置
已优化的PWA清单：
- ✅ 应用图标（192x192, 512x512）
- ✅ 启动屏幕
- ✅ 主题颜色
- ✅ 应用快捷方式

### iOS特定优化
- ✅ 支持添加到主屏幕
- ✅ 全屏显示模式
- ✅ 状态栏样式
- ✅ 安全区域适配

## 📊 性能优化

### 缓存策略
- 静态资源：1年缓存
- HTML文件：即时更新
- API响应：5分钟缓存

### 加载优化
- 代码分割
- 懒加载
- 预加载关键资源
- 压缩优化

## 🔐 安全配置

### HTTPS要求
iOS要求PWA必须使用HTTPS：
- 使用Let's Encrypt免费证书
- 配置HSTS头
- 启用安全传输

### 内容安全策略
```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;
```

## 📱 测试PWA

### iOS测试清单
- [ ] 通过Safari访问应用
- [ ] 添加到主屏幕成功
- [ ] 离线功能正常
- [ ] 推送通知工作
- [ ] 应用更新机制
- [ ] 性能测试

### 测试工具
- Chrome DevTools
- Safari Web Inspector
- Lighthouse PWA审计

## 🚀 部署检查清单

### 部署前
- [ ] HTTPS证书配置
- [ ] 域名DNS解析
- [ ] 服务器资源充足
- [ ] 备份现有部署

### 部署后
- [ ] 访问测试
- [ ] PWA功能验证
- [ ] 性能监控
- [ ] 错误日志检查

## 📞 技术支持

### 常见问题

**Q: PWA无法添加到主屏幕？**
A: 确保使用HTTPS，检查manifest.json配置。

**Q: 离线功能不工作？**
A: 验证Service Worker注册，检查缓存策略。

**Q: 应用更新不及时？**
A: 检查Service Worker更新机制，清除缓存重试。

### 调试方法
```javascript
// 在Safari中调试
// 设置 > Safari > 高级 > Web检查器

// 在Chrome中调试
chrome://inspect/#service-workers
```

## 📈 监控和分析

### 推荐工具
- Google Analytics
- Firebase Analytics
- Sentry错误监控
- Lighthouse CI

### 关键指标
- 首次内容绘制（FCP）
- 最大内容绘制（LCP）
- 累积布局偏移（CLS）
- 首次输入延迟（FID）

---

**部署完成后，您的Sierro储能监控应用将可以在iOS设备上像原生应用一样使用！**