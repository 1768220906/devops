# --- 构建阶段 ---
FROM node:22-alpine AS build-stage

# 1. 安装 pnpm (利用 Corepack，这是 Node 官方推荐的方式)
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 2. 先拷贝依赖描述文件
COPY pnpm-lock.yaml package.json ./

# 3. 安装依赖 
# --frozen-lockfile 相当于 npm ci，确保版本严格一致
RUN pnpm install --frozen-lockfile

# 4. 拷贝源码并打包
COPY . .
RUN pnpm run build

# --- 运行阶段 ---
FROM nginx:stable-alpine
# 这里的 /app/dist 取决于你前端框架的输出目录（Vite 默认 dist，Webpack 可能是 build）
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]