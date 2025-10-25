// frontend/src/pages/auth/LoginPage.tsx
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";

const EDU_DOMAIN = "@gv.edu.vn";
const reEdu = /^[^\s@]+@gv\.edu\.vn$/i;

export default function LoginPage() {
  const nav = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr("");
    if (!reEdu.test(email)) { setErr(`Email phải có đuôi ${EDU_DOMAIN}`); return; }
    try {
      await login(email.trim(), password);
      nav("/", { replace: true });
    } catch (e: any) {
      setErr(e.message || "Đăng nhập thất bại");
    }
  }

  return (
    <div className="min-h-screen grid place-items-center bg-[#f7f9fc]">
      <form onSubmit={onSubmit} className="w-full max-w-md bg-white p-8 rounded-2xl shadow ring-1 ring-gray-200 space-y-4">
        <div className="text-2xl font-bold">Đăng nhập</div>
        {err && <div className="text-red-600 bg-red-50 px-3 py-2 rounded">{err}</div>}
        <label className="block">
          <div className="text-sm mb-1">Email</div>
          <input className="w-full rounded-xl border px-3 py-2" placeholder="ten@gv.edu.vn"
                 value={email} onChange={(e)=>setEmail(e.target.value)} />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Mật khẩu</div>
          <input type="password" className="w-full rounded-xl border px-3 py-2"
                 value={password} onChange={(e)=>setPassword(e.target.value)} />
        </label>
        <button className="w-full rounded-full bg-blue-600 text-white py-2.5 hover:bg-blue-700 transition">Đăng nhập</button>
        <div className="text-sm text-gray-500">
          Chưa có tài khoản? <Link to="/register" className="text-blue-600">Đăng ký</Link>
        </div>
      </form>
    </div>
  );
}
