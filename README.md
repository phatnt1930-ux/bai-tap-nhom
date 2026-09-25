# Báo cáo Thiết kế Cơ sở dữ liệu

Đề tài: Nền tảng Quản lý Cuộc thi Nhiếp ảnh Phim tích hợp AI

## Biên dịch

```bash
latexmk -pdf main.tex      # hoặc: pdflatex main.tex (chạy 2 lần để sinh mục lục)
```

## Cấu trúc

| Tệp / thư mục | Nội dung |
| --- | --- |
| `main.tex` | Cấu hình gói, trang bìa, mục lục, gọi bốn chương |
| `chuong1.tex` + `chuong1/` | Khảo sát yêu cầu và nghiệp vụ |
| `chuong2.tex` + `chuong2/` | Mô hình dữ liệu quan niệm |
| `chuong3.tex` + `chuong3/` | Mô hình logic và chuẩn hóa |
| `chuong4.tex` + `chuong4/` | Thiết kế vật lý và triển khai |
| `sql/` | Script khởi tạo cơ sở dữ liệu |
| `images/` | Ảnh sơ đồ, đặt file `hinh3.1.png` và `hinh4.1.png` vào đây |

## Còn phải bổ sung

- Điền thông tin nhóm ở trang bìa trong `main.tex`
- Xuất PNG hai sơ đồ draw.io vào `images/`, rồi thay khối `\fbox` bằng `\includegraphics`
- Sinh dữ liệu mẫu và chụp kết quả chạy các truy vấn ở mục 4.4

