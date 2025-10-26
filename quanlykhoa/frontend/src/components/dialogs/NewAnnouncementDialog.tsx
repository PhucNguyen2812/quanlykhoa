
import { useState } from "react";
import { apiCreateAnnouncement } from "../../services/api";

export default function NewAnnouncementDialog({ nhomId, onClose, onCreated }:{ nhomId:string; onClose:()=>void; onCreated:()=>void; }){
  const [tieuDe, setTieuDe] = useState("");
  const [noiDung, setNoiDung] = useState("");
  const [hanNop, setHanNop] = useState<string>("");
  const [files, setFiles] = useState<File[]>([]);
  const [error, setError] = useState<string|null>(null);
  const [loading, setLoading] = useState(false);

  function onPick(e: React.ChangeEvent<HTMLInputElement>) {
    const f = Array.from(e.target.files || []);
    const next = [...files, ...f].slice(0,4);
    setFiles(next);
  }

  async function submit(e: React.FormEvent){
    e.preventDefault();
    setError(null);
    if(!tieuDe.trim()){ setError("Vui lòng nhập tiêu đề"); return; }
    if(files.some(f=>f.size>50*1024*1024)){ setError("Mỗi tệp tối đa 50MB"); return; }
    try{
      setLoading(true);
      await apiCreateAnnouncement(nhomId, { tieuDe, noiDung, hanNop: hanNop || undefined, files });
      onCreated();
      onClose();
    }catch(err:any){
      setError(err?.message || "Không thể đăng thông báo");
    }finally{
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-3xl">
        <div className="px-5 py-4 border-b flex items-center justify-between">
          <div className="text-lg font-semibold">Thông báo mới</div>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">✕</button>
        </div>
        <form onSubmit={submit} className="p-5 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2 space-y-3">
            {error && <div className="text-sm text-red-600">{error}</div>}
            <div>
              <input className="w-full border rounded-lg px-3 py-2" placeholder="Tiêu đề *" value={tieuDe} onChange={e=>setTieuDe(e.target.value)} />
            </div>
            <div>
              <textarea className="w-full border rounded-lg px-3 py-2 min-h-[140px]" placeholder="Hướng dẫn (không bắt buộc)" value={noiDung} onChange={e=>setNoiDung(e.target.value)} />
            </div>
            <div>
              <div className="text-sm font-medium mb-1">Đính kèm (tối đa 4 tệp, ≤50MB/tệp)</div>
              <input type="file" multiple onChange={onPick} />
              {files.length>0 && (
                <ul className="text-sm mt-2 list-disc pl-5">
                  {files.map((f,i)=>(<li key={i}>{f.name} — {(f.size/1024/1024).toFixed(1)} MB</li>))}
                </ul>
              )}
            </div>
          </div>
          <div className="space-y-3">
            <div>
              <div className="text-sm font-medium mb-1">Hạn nộp</div>
              <input type="datetime-local" className="w-full border rounded-lg px-3 py-2" value={hanNop} onChange={e=>setHanNop(e.target.value)} />
            </div>
            <div className="pt-6 flex justify-end">
              <button type="button" onClick={onClose} className="px-4 py-2 rounded-lg border mr-2">Huỷ</button>
              <button disabled={loading} className="px-4 py-2 rounded-lg bg-blue-600 text-white">{loading?"Đang đăng…":"Đăng thông báo"}</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  )
}
