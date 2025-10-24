import { Link } from "react-router-dom";
import {
  Home as HomeIcon, Calendar, GraduationCap, Inbox, Archive,
  FileUp, FilePlus2, Image as ImageIcon, Folder, MoreVertical
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

export default function HomePage() {
  return (
    <div className="min-h-screen bg-[#f7f9fc] text-[#1f1f1f]">
      {/* App bar */}
      <header className="sticky top-0 z-10 bg-white/80 backdrop-blur border-b">
        <div className="max-w-7xl mx-auto h-14 px-6 flex items-center gap-3">
          <div className="w-7 h-7 rounded-md bg-green-600 text-white grid place-items-center">🏫</div>
          <div className="text-lg font-semibold">Lớp học</div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto flex">
        {/* Sidebar */}
        <aside className="w-72 border-r bg-white pt-4">
          <nav className="px-3 pb-6 space-y-2">
            <SideItem icon={<HomeIcon size={18}/>} active> Màn hình chính</SideItem>
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

            {/* bổ sung theo đề tài */}
            <SideItem icon={<FileUp size={18}/>}> Nộp hồ sơ xét duyệt</SideItem>
            <SideItem icon={<FilePlus2 size={18}/>}> Gửi đề nghị</SideItem>
          </nav>
        </aside>

        {/* Nội dung */}
        <main className="flex-1 p-8">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-7">
            {/* Card lớp */}
            <div className="group rounded-2xl overflow-hidden bg-white shadow-sm ring-1 ring-gray-200 hover:shadow-md transition">
              <div className="p-6 text-white bg-gradient-to-tr from-blue-700 to-blue-500 relative">
                <Link
                  to="/classes/Flutter_11_CNPM1"
                  className="text-2xl font-bold underline decoration-white/60 underline-offset-2"
                >
                  Flutter_11_CNPM1
                </Link>
                <div className="opacity-90">2025-2026</div>
                <div className="absolute right-4 top-4 w-12 h-12 rounded-full bg-white/20 grid place-items-center text-white font-semibold">
                  T
                </div>
              </div>

              <div className="p-5">
                <div className="text-sm text-gray-700 leading-5">
                  Đến hạn Chủ Nhật<br />
                  23:59 – Lí thuyết _ Buổi 9.<br />
                  24.10.2025
                </div>
                <div className="flex items-center gap-4 mt-4 text-gray-600">
                  <button className="p-2 rounded-lg hover:bg-gray-100 transition"><ImageIcon size={18}/></button>
                  <button className="p-2 rounded-lg hover:bg-gray-100 transition"><Folder size={18}/></button>
                  <button className="p-2 rounded-lg hover:bg-gray-100 transition ml-auto"><MoreVertical size={18}/></button>
                </div>
              </div>
            </div>

          </div>
        </main>
      </div>
    </div>
  );
}
