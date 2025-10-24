import { Link } from "react-router-dom";
import { useState } from "react";
import {
  Home as HomeIcon, Calendar, GraduationCap, Inbox, Archive,
  FileUp, FilePlus2
} from "lucide-react";

type FileItem = { file: File, id: string };

const SideItem = ({icon, children}:{icon:React.ReactNode;children:React.ReactNode}) => (
  <a href="#" className="flex items-center gap-3 px-4 py-2 rounded-xl text-gray-700 hover:bg-gray-100 transition">
    <span className="w-5 h-5">{icon}</span>{children}
  </a>
);

export default function AnnouncementDetailPage() {
  const [submitted, setSubmitted] = useState(false);
  const [files, setFiles] = useState<FileItem[]>([]);

  const onAddFiles = (e: React.ChangeEvent<HTMLInputElement>) => {
    const picked = Array.from(e.target.files || []);
    const current = [...files];
    for (const f of picked) {
      if (current.length >= 4) break;
      if (f.size > 50 * 1024 * 1024) { alert(`"${f.name}" > 50MB`); continue; }
      current.push({ file: f, id: crypto.randomUUID() });
    }
    setFiles(current);
    e.currentTarget.value = "";
  };
  const removeFile = (id: string) => setFiles(files.filter(x => x.id !== id));

  return (
    <div className="min-h-screen bg-[#f7f9fc] text-[#1f1f1f]">
      {/* App bar */}
      <header className="sticky top-0 z-10 bg-white/80 backdrop-blur border-b">
        <div className="max-w-7xl mx-auto h-14 px-6 flex items-center gap-3">
          <div className="w-7 h-7 rounded-md bg-green-600 text-white grid place-items-center">🏫</div>
          <Link to="/" className="text-sm text-gray-600 hover:underline">Lớp học</Link>
          <span className="text-gray-400">›</span>
          <Link to="/classes/Flutter_11_CNPM1" className="text-sm hover:underline">Flutter_11_CNPM1</Link>
          <span className="text-gray-400">›</span>
          <div className="font-semibold">Lí thuyết _ Buổi 9. 24.10.2025</div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto flex">
        {/* Sidebar */}
        <aside className="w-72 border-r bg-white pt-4">
          <nav className="px-3 pb-6 space-y-2">
            <Link to="/"><SideItem icon={<HomeIcon size={18}/>}>Màn hình chính</SideItem></Link>
            <SideItem icon={<Calendar size={18}/>}>Lịch</SideItem>
            <SideItem icon={<GraduationCap size={18}/>}>Đã đăng ký</SideItem>
            <SideItem icon={<Inbox size={18}/>}>Việc cần làm</SideItem>
            <div className="px-4 pt-4 pb-1 text-xs uppercase tracking-wide text-gray-500">Lớp hiện tại</div>
            <Link to="/classes/Flutter_11_CNPM1">
              <div className="mx-3 flex items-center gap-3 px-4 py-2 rounded-xl bg-blue-50 text-blue-700 font-medium">
                <div className="w-5 h-5 grid place-items-center rounded-full bg-blue-600 text-white text-xs">F</div>
                Flutter_11_CNPM1
              </div>
            </Link>
            <SideItem icon={<Archive size={18}/>}>Lớp học đã lưu trữ</SideItem>
            <SideItem icon={<FileUp size={18}/>}>Nộp hồ sơ xét duyệt</SideItem>
            <SideItem icon={<FilePlus2 size={18}/>}>Gửi đề nghị</SideItem>
          </nav>
        </aside>

        {/* Nội dung + panel phải */}
        <main className="flex-1">
          <div className="px-6 py-8 grid grid-cols-1 lg:grid-cols-[1fr_380px] gap-8">
            {/* Bài */}
            <article className="rounded-2xl bg-white p-6 border shadow-sm">
              <div className="flex items-center gap-3">
                <div className="text-3xl">📘</div>
                <h1 className="text-3xl font-semibold">Lí thuyết _ Buổi 9. 24.10.2025</h1>
              </div>
              <div className="text-gray-600 mt-2">Truyền Nguyễn Thanh • 09:15</div>
              <div className="text-gray-600 mt-1">100 điểm</div>
              <div className="border-t my-5"></div>

              <div className="prose max-w-none">
                <p><b>Điểm danh:</b> <a className="text-blue-600 underline" href="#">https://forms.gle/…</a></p>
                <p><b>Xem lại điểm danh:</b> <a className="text-blue-600 underline" href="#">https://docs.google.com/…</a></p>

                <h3>Chương 21: Native Features và Platform Channels</h3>
                <ul>
                  <li>Platform Channels (MethodChannel, EventChannel).</li>
                  <li>Trao đổi Dart ↔ Kotlin/Java, Swift/Obj-C.</li>
                  <li>Camera nâng cao, Bluetooth, GPS…</li>
                </ul>

                <h3>Chương 22: CI/CD</h3>
                <ul>
                  <li>Fastlane; GitHub Actions/Bitrise/Codemagic.</li>
                </ul>

                <h3>Chương 23: Deployment</h3>
                <ul>
                  <li>Build Android/iOS; icon/splash; publish store.</li>
                </ul>
              </div>
            </article>

            {/* Panel phải */}
            <aside className="rounded-2xl bg-white p-6 border shadow-sm h-fit sticky top-20">
              <div className="text-xl font-semibold">Bài tập của bạn</div>
              <div className="text-sm text-gray-500 mt-1">Đến hạn 23:59 26 thg 10</div>

              <div className="mt-4">
                <label
                  className={`inline-flex items-center gap-2 rounded-full px-4 py-2 border transition
                  ${submitted ? "opacity-50 cursor-not-allowed" : "bg-blue-50 text-blue-700 border-blue-200 hover:bg-blue-100 active:scale-[.98]"}`}>
                  + Thêm hoặc tạo
                  <input type="file" className="hidden" multiple disabled={submitted} onChange={onAddFiles}/>
                </label>

                <ul className="mt-3 space-y-2">
                  {files.map(f => (
                    <li key={f.id} className="flex items-center justify-between rounded-xl border px-3 py-2">
                      <span className="truncate">{f.file.name} ({Math.round(f.file.size/1024/1024)} MB)</span>
                      {!submitted && (
                        <button className="text-red-600 text-sm hover:underline" onClick={() => removeFile(f.id)}>Xoá</button>
                      )}
                    </li>
                  ))}
                </ul>

                <p className="text-xs text-gray-500 mt-2">Tối đa 4 tệp, 50MB/tệp. Muốn sửa hãy “Hủy nộp”.</p>
              </div>

              <div className="mt-4">
                {!submitted ? (
                  <button
                    onClick={() => setSubmitted(true)}
                    disabled={files.length === 0}
                    className={`w-full rounded-full px-4 py-2 text-white transition
                    ${files.length===0 ? "bg-gray-300" : "bg-blue-600 hover:bg-blue-700 active:scale-[.99]"}`}
                  >
                    Đánh dấu là đã hoàn thành
                  </button>
                ) : (
                  <>
                    <div className="text-gray-500 text-sm mt-2">Không thể nộp bài tập sau ngày đến hạn</div>
                    <button
                      onClick={() => setSubmitted(false)}
                      className="mt-3 w-full rounded-full px-4 py-2 border hover:bg-gray-50 active:scale-[.99]"
                    >
                      Hủy nộp
                    </button>
                  </>
                )}
              </div>

              <div className="rounded-2xl border mt-6 p-4">
                <div className="font-medium">Nhận xét riêng tư</div>
                <Link className="text-blue-600 text-sm hover:underline" to="#">Thêm nhận xét cho Truyền Nguyễn Thanh</Link>
              </div>
            </aside>
          </div>
        </main>
      </div>
    </div>
  );
}
