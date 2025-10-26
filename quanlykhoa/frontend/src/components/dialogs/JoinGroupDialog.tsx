
import { useState } from "react";
import { apiJoinByCode } from "../../services/api";

type Props = { onClose: () => void; onJoined?: () => void; };

export default function JoinGroupDialog({ onClose, onJoined }: Props) {
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!code.trim()) { setError("Nhập mã nhóm."); return; }
    try {
      setLoading(true);
      await apiJoinByCode(code.trim());
      onJoined?.();
      onClose();
    } catch (err: any) {
      setError(err?.message || "Không thể tham gia nhóm");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md">
        <div className="px-5 py-4 border-b">
          <div className="text-lg font-semibold">Tham gia nhóm</div>
        </div>
        <form onSubmit={submit} className="p-5 space-y-3">
          {error && <div className="text-sm text-red-600">{error}</div>}
          <div>
            <label className="block text-sm font-medium mb-1">Mã nhóm</label>
            <input value={code} onChange={e=>setCode(e.target.value)} className="w-full border rounded-lg px-3 py-2" placeholder="nhập mã mời..." />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={onClose} className="px-4 py-2 rounded-lg border">Hủy</button>
            <button disabled={loading} className="px-4 py-2 rounded-lg bg-blue-600 text-white">{loading?"Đang tham gia...":"Tham gia"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}
