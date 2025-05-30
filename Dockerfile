# =========================================
# Giai đoạn 1: Build ứng dụng Angular
# =========================================
# =========================================
# Giai đoạn 1: Build ứng dụng Angular
# =========================================
ARG NODE_VERSION=22.14.0-alpine
ARG NGINX_VERSION=alpine3.21

# Sử dụng image Node.js nhẹ để build (có thể tùy chỉnh qua ARG)
FROM node:${NODE_VERSION} AS builder

# Đặt thư mục làm việc trong container
WORKDIR /app

# Chỉ copy các file liên quan đến package trước để tận dụng cache của Docker
COPY package.json package-lock.json ./

# Cài đặt các dependency của dự án bằng npm ci (đảm bảo cài đặt sạch và tái tạo được)
RUN --mount=type=cache,target=/root/.npm npm ci

# Copy toàn bộ mã nguồn còn lại vào container
COPY . .

# Build ứng dụng Angular
RUN npm run build 

# =========================================
# Giai đoạn 2: Chuẩn bị Nginx để phục vụ file tĩnh
# =========================================

FROM nginxinc/nginx-unprivileged:${NGINX_VERSION} AS runner

# Sử dụng user không phải root để tăng bảo mật
USER nginx

# Copy file cấu hình Nginx tùy chỉnh
COPY nginx.conf /etc/nginx/nginx.conf

# Copy các file build tĩnh từ stage build sang thư mục phục vụ mặc định của Nginx
COPY --chown=nginx:nginx --from=builder /app/dist/*/browser /usr/share/nginx/html

# Mở port 8080 để nhận traffic HTTP
# Lưu ý: Container NGINX mặc định hiện tại lắng nghe ở port 8080 thay vì 80 
EXPOSE 8080

# Khởi động Nginx trực tiếp với file cấu hình tùy chỉnh
ENTRYPOINT ["nginx", "-c", "/etc/nginx/nginx.conf"]
CMD ["-g", "daemon off;"]