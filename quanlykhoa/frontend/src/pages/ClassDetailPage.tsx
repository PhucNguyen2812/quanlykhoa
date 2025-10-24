import { Link } from "react-router-dom";
import {
  Home as HomeIcon, Calendar, GraduationCap, Inbox, Archive,
  FileUp, FilePlus2, MoreVertical
} from "lucide-react";

const SideItem = ({icon, children, active=false}:{icon:React.ReactNode;children:React.ReactNode;active?:boolean}) => (
  <a
    href="#"
    className={
      "flex items-center gap-3 px-4 py-2 rounded-xl transition " +
      (active
        ? "bg-blue-50 text-blue-700 font-medium"
        : "text-gray-700 hover:bg-gray-100")
    }>
    <span className="w-5 h-5">{icon}</span>{children}
  </a>
);

export default function ClassDetailPage() {
  return (
    <div className="min-h-screen bg-[#f7f9fc] text-[#1f1f1f]">
      {/* App bar */}
      <header className="sticky top-0 z-10 bg-white/80 backdrop-blur border-b">
        <div className="max-w-7xl mx-auto h-14 px-6 flex items-center gap-3">
          <div className="w-7 h-7 rounded-md bg-green-600 text-white grid place-items-center">🏫</div>
          <Link to="/" className="text-sm text-gray-600 hover:underline">Lớp học</Link>
          <span className="text-gray-400">›</span>
          <div className="font-semibold">Flutter_11_CNPM1</div>
          <span className="text-gray-500 text-sm">• 2025-2026</span>
        </div>
      </header>

      <div className="max-w-7xl mx-auto flex">
        {/* Sidebar */}
        <aside className="w-72 border-r bg-white pt-4">
          <nav className="px-3 pb-6 space-y-2">
            <Link to="/"><SideItem icon={<HomeIcon size={18}/>}> Màn hình chính</SideItem></Link>
            <SideItem icon={<Calendar size={18}/>}> Lịch</SideItem>
            <SideItem icon={<GraduationCap size={18}/>}> Đã đăng ký</SideItem>
            <SideItem icon={<Inbox size={18}/>}> Việc cần làm</SideItem>

            <div className="px-4 pt-4 pb-1 text-xs uppercase tracking-wide text-gray-500">Lớp hiện tại</div>
            <div className="px-3">
              <div className="flex items-center gap-3 px-4 py-2 rounded-xl bg-blue-50 text-blue-700 font-medium">
                <div className="w-5 h-5 grid place-items-center rounded-full bg-blue-600 text-white text-xs">F</div>
                Flutter_11_CNPM1
              </div>
            </div>

            <SideItem icon={<Archive size={18}/>}> Lớp học đã lưu trữ</SideItem>
            <SideItem icon={<FileUp size={18}/>}> Nộp hồ sơ xét duyệt</SideItem>
            <SideItem icon={<FilePlus2 size={18}/>}> Gửi đề nghị</SideItem>
          </nav>
        </aside>

        {/* Nội dung */}
        <main className="flex-1">
          {/* tabs */}
          <div className="border-b bg-white">
            <div className="max-w-5xl mx-auto flex gap-8 px-6">
              <button className="relative py-3 text-blue-600 font-medium">
                Bảng tin
                <span className="absolute left-0 right-0 -bottom-[1px] h-0.5 bg-blue-600 rounded-full"></span>
              </button>
              <button className="py-3 text-gray-600 hover:text-black transition">Bài tập trên lớp</button>
              <button className="py-3 text-gray-600 hover:text-black transition">Mọi người</button>
            </div>
          </div>

          <div className="max-w-5xl mx-auto px-6 py-6">
            {/* Cover */}
            <div className="rounded-2xl p-8 text-white bg-gradient-to-tr from-blue-700 to-blue-500 shadow-sm">
              <div className="text-4xl font-bold">Flutter_11_CNPM1</div>
              <div className="opacity-90 mt-2">2025-2026</div>
            </div>

            {/* Sắp đến hạn + Stream */}
            <div className="mt-6 grid grid-cols-1 lg:grid-cols-[320px_1fr] gap-6">
              {/* Sắp đến hạn */}
              <div className="rounded-2xl border bg-white p-5 shadow-sm">
                <div className="font-semibold">Sắp đến hạn</div>
                <div className="text-sm text-gray-700 mt-2 leading-6">
                  Đến hạn Chủ Nhật<br />23:59 – Lí thuyết _ Buổi 9. 24.10.2025
                </div>
                <a className="text-blue-600 text-sm mt-3 inline-block hover:underline" href="#">Xem tất cả</a>
              </div>

              {/* Stream */}
              <div>
                <button
                  className="rounded-full px-4 py-2 bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 transition active:scale-[.98]"
                >
                  ✏️ Thông báo mới
                </button>

                <Link
                  to="/classes/Flutter_11_CNPM1/announcements/0905"
                  className="mt-4 block rounded-2xl border bg-white p-4 hover:shadow-md transition"
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-blue-600 text-white grid place-items-center text-sm">📄</div>
                    <div className="min-w-0">
                      <div className="font-medium truncate">
                        Truyền Nguyễn Thanh đã đăng một bài tập mới: Lí thuyết _ Buổi 9. 24.10.2025
                      </div>
                      <div className="text-sm text-gray-500">09:15</div>
                    </div>
                    <div className="ml-auto text-gray-400"><MoreVertical size={18}/></div>
                  </div>
                </Link>

                <div className="mt-3 rounded-2xl border bg-white p-4">
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-blue-600 text-white grid place-items-center text-sm">📄</div>
                    <div>
                      <div className="font-medium">… Buổi 8. 17.10.2025</div>
                      <div className="text-sm text-gray-500">Đã chỉnh sửa 17 thg 10</div>
                    </div>
                    <div className="ml-auto text-gray-400"><MoreVertical size={18}/></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
