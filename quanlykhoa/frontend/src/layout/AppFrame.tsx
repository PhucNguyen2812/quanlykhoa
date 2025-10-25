import { Outlet, Link } from "react-router-dom";
import UserMenu from "../components/UserMenu";

export default function AppFrame() {
  return (
    <div className="min-h-screen bg-[#f7f9fc]">
      {/* Top bar */}
      <header className="sticky top-0 z-40 bg-white/90 backdrop-blur border-b border-gray-100">
        <div className="mx-auto max-w-7xl px-4 h-14 flex items-center justify-between">
          <Link to="/" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-md bg-emerald-500 grid place-items-center text-white font-bold">L</div>
            <span className="text-lg font-semibold">Lớp học</span>
          </Link>
          <UserMenu />
        </div>
      </header>

      {/* Nội dung trang */}
      <main className="mx-auto max-w-7xl px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
