
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import NewAnnouncementDialog from "../components/dialogs/NewAnnouncementDialog";
import { apiListAnnouncements } from "../services/api";
import type { ThongBao } from "../services/api";

export default function ClassDetailPage(){
  const nhomId = "00000000-0000-0000-0000-000000000000"; // TODO: lấy từ route
  const [show, setShow] = useState(false);
  const [items, setItems] = useState<ThongBao[]>([]);

  useEffect(()=>{ apiListAnnouncements(nhomId).then(setItems).catch(()=>{}); },[]);

  return (
    <div className="min-h-screen bg-[#f7f9fc] p-6">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center gap-2 mb-4">
          <Link to="/" className="text-blue-600">Nhóm</Link>
          <span>/</span>
          <span className="font-semibold">Flutter_11_CNPM1</span>
        </div>
        <div className="flex items-center justify-between mb-4">
          <div className="text-2xl font-bold">Bảng tin</div>
          <button onClick={()=>setShow(true)} className="px-3 py-2 rounded-lg bg-blue-600 text-white">Thông báo mới</button>
        </div>
        <div className="space-y-3">
          {items.map(x => (
            <div key={x.id} className="rounded-xl border bg-white p-4">
              <div className="font-medium">{x.tieuDe}</div>
              {x.noiDung && <div className="text-gray-600">{x.noiDung}</div>}
              <div className="text-xs text-gray-500 mt-1">Hạn nộp: {x.hanNop ? new Date(x.hanNop).toLocaleString() : "—"} • {x.soTep} tệp</div>
            </div>
          ))}
          {items.length===0 && <div className="text-gray-500">Chưa có thông báo.</div>}
        </div>
      </div>
      {show && <NewAnnouncementDialog nhomId={nhomId} onClose={()=>setShow(false)} onCreated={()=>{ setShow(false); apiListAnnouncements(nhomId).then(setItems); }} />}
    </div>
  );
}
