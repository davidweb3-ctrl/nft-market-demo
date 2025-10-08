# 如何在 README.md 中添加图片并上传到 GitHub

## 方法 1: 将图片存储在项目仓库中（推荐）✅

### 步骤 1: 准备截图

1. **运行你的应用**
   ```bash
   cd frontend
   pnpm dev
   ```

2. **截取以下场景的图片**：
   - 钱包连接页面
   - NFT 市场主页
   - NFT 上架过程
   - NFT 购买过程
   - 事件通知展示

3. **建议的截图命名**：
   - `wallet-connection.png` - 钱包连接界面
   - `marketplace-overview.png` - 市场总览
   - `nft-listing.png` - NFT 上架
   - `nft-purchase.png` - NFT 购买
   - `event-notifications.png` - 事件通知

### 步骤 2: 保存截图到项目

```bash
# 将你的截图文件复制到这个目录
cp ~/Downloads/your-screenshot.png docs/images/wallet-connection.png
```

或者直接将截图文件拖拽到 `docs/images/` 目录。

### 步骤 3: 在 README.md 中引用图片

图片已经在 README.md 中预先配置好了：

```markdown
![Wallet Connection](docs/images/wallet-connection.png)
![NFT Marketplace](docs/images/marketplace-overview.png)
![NFT Listing](docs/images/nft-listing.png)
![NFT Purchase](docs/images/nft-purchase.png)
```

### 步骤 4: 提交到 GitHub

```bash
# 添加图片文件
git add docs/images/*.png

# 提交
git commit -m "docs: Add screenshots to README"

# 推送到 GitHub
git push origin main
```

完成！你的图片现在会显示在 GitHub 的 README.md 中。

---

## 方法 2: 使用 GitHub Issues（快速但不推荐）

### 步骤：

1. 在你的 GitHub 仓库中创建一个新的 Issue
2. 将截图拖拽到 Issue 评论框中
3. GitHub 会自动上传图片并生成 URL
4. 复制这个 URL（格式：`https://user-images.githubusercontent.com/...`）
5. 在 README.md 中使用：
   ```markdown
   ![Description](https://user-images.githubusercontent.com/...)
   ```

**缺点**：如果删除 Issue，图片链接会失效。

---

## 方法 3: 使用图床服务

可以使用以下免费图床服务：
- [Imgur](https://imgur.com/)
- [imgbb](https://imgbb.com/)
- [Cloudinary](https://cloudinary.com/)

**缺点**：依赖第三方服务。

---

## 推荐的图片规格

- **格式**: PNG 或 JPG
- **宽度**: 建议 1200-1600px（GitHub 会自动缩放）
- **文件大小**: 尽量小于 1MB
- **清晰度**: 确保文字和界面元素清晰可读

---

## Markdown 图片语法

### 基本语法
```markdown
![Alt Text](path/to/image.png)
```

### 带链接的图片
```markdown
[![Alt Text](path/to/image.png)](https://your-demo-link.com)
```

### 调整大小（HTML 方式）
```markdown
<img src="path/to/image.png" width="600" alt="Description">
```

### 并排显示多张图片
```markdown
<p float="left">
  <img src="docs/images/image1.png" width="400" />
  <img src="docs/images/image2.png" width="400" />
</p>
```

---

## 完整示例

```markdown
## 📸 Screenshots

### Wallet Connection
![Wallet Connection](docs/images/wallet-connection.png)

### NFT Marketplace
<img src="docs/images/marketplace-overview.png" width="800" alt="NFT Marketplace">

### Features Overview
<p float="left">
  <img src="docs/images/nft-listing.png" width="400" />
  <img src="docs/images/nft-purchase.png" width="400" />
</p>
```

---

## 快速命令参考

```bash
# 1. 将截图复制到项目
cp ~/Downloads/*.png docs/images/

# 2. 添加到 Git
git add docs/images/*.png

# 3. 提交
git commit -m "docs: Add application screenshots"

# 4. 推送
git push origin main
```

---

## 注意事项

1. ✅ **不要上传过大的图片**（建议 < 1MB）
2. ✅ **使用描述性的文件名**（如 `wallet-connection.png` 而不是 `screenshot1.png`）
3. ✅ **提供 Alt 文本**用于可访问性
4. ✅ **确保图片版权**属于你或可自由使用
5. ✅ **考虑使用 WebP 格式**以获得更好的压缩比

---

## 优化图片大小

如果图片太大，可以使用以下工具压缩：

### 在线工具
- [TinyPNG](https://tinypng.com/) - PNG/JPG 压缩
- [Squoosh](https://squoosh.app/) - Google 的图片优化工具

### 命令行工具
```bash
# 使用 ImageMagick
convert input.png -quality 85 -resize 1200x output.png

# 使用 pngquant
pngquant --quality=65-80 input.png --output output.png
```

---

现在你可以开始添加截图了！🎉

