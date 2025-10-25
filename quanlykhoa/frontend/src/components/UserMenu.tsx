import { useEffect, useRef, useState } from "react";
import { useAuth } from "../context/AuthContext";

export default function UserMenu() {
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  const initial = (user?.hoTen || user?.email || "?").trim().charAt(0).toUpperCase();

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (!ref.current) return;
      if (!ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener("mousedown", onClickOutside);
    return () => document.removeEventListener("mousedown", onClickOutside);
  }, []);

  return (
    <div className="relative" ref={ref}>
      <button
        type="button"
        onClick={() => setOpen(v => !v)}
        className="w-10 h-10 rounded-full bg-emerald-500 text-white grid place-items-center font-semibold shadow hover:brightness-95 transition"
        title={user?.email}
      >
        {initial}
      </button>

      {open && (
        <div className="absolute right-0 mt-2 w-56 rounded-xl bg-white shadow-lg ring-1 ring-black/5 overflow-hidden z-50">
          <div className="px-4 py-3">
            <div className="text-sm font-medium">{user?.hoTen || "Tài khoản"}</div>
            <div className="text-xs text-gray-500 truncate">{user?.email}</div>
          </div>
          <div className="h-px bg-gray-100" />
          <button
            onClick={() => { setOpen(false); logout(); }}
            className="w-full text-left px-4 py-3 text-sm hover:bg-gray-50"
          >
            Đăng xuất
          </button>
        </div>
      )}
    </div>
  );
}
