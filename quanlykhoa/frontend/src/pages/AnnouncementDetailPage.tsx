
import { Link } from "react-router-dom";

export default function AnnouncementDetailPage(){
  return (
    <div className="min-h-screen grid place-items-center bg-[#f7f9fc]">
      <div className="max-w-xl w-full p-8 bg-white rounded-2xl shadow">
        <div className="text-xl font-semibold mb-2">Chi tiết thông báo</div>
        <p className="text-gray-600 mb-4">Trang này sẽ hiển thị chi tiết một thông báo cụ thể.</p>
        <Link to="/" className="text-blue-600">← Trở về</Link>
      </div>
    </div>
  );
}
