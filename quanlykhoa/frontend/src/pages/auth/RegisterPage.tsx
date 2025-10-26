import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { apiRegister } from "../../services/api";

const EDU_DOMAIN = "@gv.edu.vn";
const reEdu = /^[^\s@]+@gv\.edu\.vn$/i;

export default function RegisterPage() {
  const nav = useNavigate();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [err, setErr] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr("");
    if (!fullName.trim()) { setErr("Vui lòng nhập họ tên."); return; }
    if (!reEdu.test(email)) { setErr(`Email phải có đuôi ${EDU_DOMAIN}`); return; }
    if (password.length < 6) { setErr("Mật khẩu tối thiểu 6 ký tự."); return; }
    if (password !== confirm) { setErr("Mật khẩu xác nhận không khớp."); return; }
    try {
      const res = await apiRegister(fullName.trim(), email.trim(), password);
      localStorage.setItem("token", res.token);
      localStorage.setItem("user", JSON.stringify(res.user));
      nav("/", { replace: true });
    } catch (e:any) {
      setErr(e?.message || "Đăng ký thất bại");
    }
  }

  return (
    <div className="min-h-screen grid place-items-center bg-[#f7f9fc]">
      <form onSubmit={onSubmit} className="w-full max-w-md bg-white p-8 rounded-2xl shadow ring-1 ring-gray-200 space-y-4">
        <div className="text-2xl font-bold">Đăng ký</div>
        {err && <div className="text-red-600 bg-red-50 px-3 py-2 rounded">{err}</div>}
        <label className="block">
          <div className="text-sm mb-1">Họ tên</div>
          <input className="w-full rounded-xl border px-3 py-2"
                 value={fullName} onChange={(e)=>setFullName(e.target.value)} />
        </label>
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
        <label className="block">
          <div className="text-sm mb-1">Xác nhận mật khẩu</div>
          <input type="password" className="w-full rounded-xl border px-3 py-2"
                 value={confirm} onChange={(e)=>setConfirm(e.target.value)} />
        </label>
        <button className="w-full rounded-full bg-blue-600 text-white py-2.5 hover:bg-blue-700 transition">Tạo tài khoản</button>
        <div className="text-sm text-gray-500">
          Đã có tài khoản? <Link to="/login" className="text-blue-600">Đăng nhập</Link>
        </div>
      </form>
    </div>
  );
}
