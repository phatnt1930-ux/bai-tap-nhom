# Thiết kế cơ sở dữ liệu cho nền tảng quản lý cuộc thi nhiếp ảnh phim tích hợp AI

Báo cáo bài tập lớn môn Thiết kế cơ sở dữ liệu, Trường Đại học Giao thông vận tải Thành phố Hồ Chí Minh.

## Thành viên

| STT | Họ và tên |
| --- | --- |
| 1 | Nguyễn Chí Hiếu |
| 2 | Nguyễn Tấn Phát |
| 3 | Trần Ngọc Bảo |
| 4 | Lê Phúc Thọ |

## Tóm tắt thiết kế

- Hệ quản trị: SQL Server 2022.
- 14 bảng chia thành 4 phân hệ: Người dùng và Cuộc thi, Hồ sơ phim, Bài dự thi, Chấm thi và Phân tích AI.
- Lược đồ đạt BCNF, có 19 khóa ngoại và 14 chỉ mục bổ sung.
- Script khởi tạo: `sql/schema_sqlserver.sql`.

## Biên dịch báo cáo

```bash
latexmk -pdf main.tex        # pdfLaTeX, cần gói vntex
latexmk -xelatex main.tex    # hoặc XeLaTeX, dùng font DejaVu
```

## Cấu trúc thư mục

| Tệp / thư mục | Nội dung |
| --- | --- |
| `main.tex` | Cấu hình, trang bìa, mục lục, gọi bốn chương |
| `chuong1.tex`, `chuong1/` | Khảo sát yêu cầu và nghiệp vụ |
| `chuong2.tex`, `chuong2/` | Mô hình dữ liệu quan niệm |
| `chuong3.tex`, `chuong3/` | Mô hình logic, chuẩn hóa, từ điển dữ liệu |
| `chuong4.tex`, `chuong4/` | Thiết kế vật lý và triển khai |
| `images/` | Sơ đồ logic và sơ đồ thiết kế vật lý |
| `sql/` | Script khởi tạo cơ sở dữ liệu |
| `main.pdf` | Báo cáo đã biên dịch |
| `Tên đề tài` | Đề xuất đề tài ban đầu của nhóm |
