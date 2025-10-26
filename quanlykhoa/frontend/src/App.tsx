import React, { useState } from 'react';
import { Home, Calendar, Archive, Settings, HelpCircle, Menu, MoreVertical, ChevronDown, Bell, Folder } from 'lucide-react';

// Mock data
const classData = {
  id: 1,
  name: 'Flutter_11_CNPM1',
  year: '2025-2026',
  teacher: 'Truyền Nguyễn Thanh',
  color: 'bg-blue-600',
  posts: [
    {
      id: 1,
      title: 'Lí thuyết _ Buổi 9. 24.10.2025',
      date: '09:15',
      deadline: 'Đến hạn 23:59 26 thg 10',
      points: '100 điểm',
      type: 'assignment'
    },
    {
      id: 2,
      title: 'Lí thuyết _ Buổi 8. 17.10.2025',
      date: '17 thg 10 (Đã chỉnh sửa 17 thg 10)',
      type: 'assignment'
    },
    {
      id: 3,
      title: 'Lí thuyết _ Buổi 7_ 10.10.2025',
      date: '10 thg 10 (Đã chỉnh sửa 10 thg 10)',
      type: 'assignment'
    }
  ]
};

const classList = [
  {
    id: 1,
    name: 'Flutter_11_CNPM1',
    year: '2025-2026',
    teacher: 'Truyền Nguyễn Thanh',
    deadline: 'Đến hạn Chủ Nhật',
    deadlineDetail: '23:59 - Lí thuyết _ Buổi 9. 24.10.2025',
    color: 'bg-blue-600'
  }
];

const postDetail = {
  title: 'Lí thuyết _ Buổi 9. 24.10.2025',
  teacher: 'Truyền Nguyễn Thanh',
  date: '09:15',
  points: '100 điểm',
  deadline: 'Đến hạn 23:59 26 thg 10',
};

function App() {
  const [currentPage, setCurrentPage] = useState('home');
  const [selectedClass, setSelectedClass] = useState(classData);
  const [selectedPost, setSelectedPost] = useState(null);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  // Sidebar Component
  const Sidebar = () => (
    <div className="w-72 bg-white border-r border-gray-200 h-screen overflow-y-auto">
      <div className="p-4">
        <button
          onClick={() => { setCurrentPage('home'); setSelectedClass(null); setSelectedPost(null); }}
          className={`flex items-center w-full p-3 rounded-lg mb-2 ${currentPage === 'home' && !selectedClass ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'}`}
        >
          <Home className="w-5 h-5 mr-3" />
          <span>Màn hình chính</span>
        </button>
        
        <button className="flex items-center w-full p-3 rounded-lg mb-2 hover:bg-gray-100">
          <Calendar className="w-5 h-5 mr-3" />
          <span>Lịch</span>
        </button>

        <div className="mt-4">
          <button className="flex items-center justify-between w-full p-3 rounded-lg mb-2">
            <div className="flex items-center">
              <Archive className="w-5 h-5 mr-3" />
              <span>Đã đăng ký</span>
            </div>
            <ChevronDown className="w-4 h-4" />
          </button>

          <div className="ml-4">
            <button className="flex items-center w-full p-2 rounded-lg mb-1 hover:bg-gray-100">
              <span className="text-sm">Việc cần làm</span>
            </button>
            
            <button
              onClick={() => { setCurrentPage('class'); setSelectedClass(classData); setSelectedPost(null); }}
              className={`flex items-center w-full p-2 rounded-lg mb-1 ${selectedClass ? 'bg-blue-100 text-blue-700' : 'hover:bg-gray-100'}`}
            >
              <div className="flex items-center justify-center w-8 h-8 rounded-full bg-blue-600 text-white text-sm font-bold mr-2">
                F
              </div>
              <div className="text-left">
                <div className="text-sm font-medium">Flutter_11_CNPM1</div>
                <div className="text-xs text-gray-500">2025-2026</div>
              </div>
            </button>
          </div>
        </div>

        <button className="flex items-center w-full p-3 rounded-lg mb-2 hover:bg-gray-100 mt-4">
          <Archive className="w-5 h-5 mr-3" />
          <span>Nhóm đã lưu trữ</span>
        </button>

        <button className="flex items-center w-full p-3 rounded-lg mb-2 hover:bg-gray-100">
          <Settings className="w-5 h-5 mr-3" />
          <span>Cài đặt</span>
        </button>
      </div>
    </div>
  );

  // Header Component
  const Header = () => (
    <div className="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
      <div className="flex items-center">
        <button onClick={() => setSidebarOpen(!sidebarOpen)} className="p-2 hover:bg-gray-100 rounded-lg mr-2">
          <Menu className="w-6 h-6" />
        </button>
        <div className="flex items-center">
          <div className="w-10 h-10 bg-green-600 rounded flex items-center justify-center mr-3">
            <span className="text-white font-bold">📚</span>
          </div>
          <div className="flex items-center">
            <span className="text-xl font-normal text-gray-700">Nhóm</span>
            {selectedClass && (
              <>
                <span className="mx-2 text-gray-400">›</span>
                <span className="text-xl font-normal text-gray-700">{selectedClass.name}</span>
                <div className="ml-2 text-sm text-gray-500">{selectedClass.year}</div>
              </>
            )}
          </div>
        </div>
      </div>
      <div className="flex items-center gap-2">
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold">
            P
          </div>
        </button>
      </div>
    </div>
  );

  // Home Page
  const HomePage = () => (
    <div className="flex-1 bg-gray-50 overflow-y-auto p-8">
      <div className="max-w-6xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {classList.map((classItem) => (
            <div
              key={classItem.id}
              onClick={() => { setCurrentPage('class'); setSelectedClass(classItem); }}
              className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow cursor-pointer overflow-hidden"
            >
              <div className={`${classItem.color} h-32 p-4 text-white relative`}>
                <div className="absolute top-4 right-4">
                  <div className="w-16 h-16 bg-blue-800 rounded-full flex items-center justify-center text-2xl font-bold">
                    T
                  </div>
                </div>
                <h3 className="text-xl font-normal">{classItem.name}</h3>
                <p className="text-sm mt-1">{classItem.year}</p>
                <p className="text-sm mt-1">{classItem.teacher}</p>
              </div>
              <div className="p-4">
                <div className="text-sm text-gray-600">
                  <div className="font-medium">{classItem.deadline}</div>
                  <div className="text-gray-500">{classItem.deadlineDetail}</div>
                </div>
              </div>
              <div className="px-4 pb-4 flex items-center justify-between">
                <button className="p-2 hover:bg-gray-100 rounded">
                  <Archive className="w-5 h-5 text-gray-600" />
                </button>
                <button className="p-2 hover:bg-gray-100 rounded">
                  <Folder className="w-5 h-5 text-gray-600" />
                </button>
                <button className="p-2 hover:bg-gray-100 rounded">
                  <MoreVertical className="w-5 h-5 text-gray-600" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  // Class Detail Page
  const ClassDetailPage = () => {
    if (!selectedClass) return null;
    
    return (
    <div className="flex-1 bg-gray-50 overflow-y-auto">
      <div className={`${selectedClass.color} h-64 relative`}>
        <div className="absolute inset-0 opacity-20">
          <svg className="w-full h-full" viewBox="0 0 1200 300">
            <path d="M800,150 L900,100 L1000,180 L1100,120 L1200,200" fill="none" stroke="orange" strokeWidth="8"/>
            <polygon points="850,80 900,120 950,90" fill="#1e40af" opacity="0.8"/>
            <polygon points="1000,150 1080,100 1120,180" fill="#1e3a8a" opacity="0.9"/>
          </svg>
        </div>
        <div className="relative p-8 text-white">
          <h1 className="text-4xl font-normal mb-2">{selectedClass.name}</h1>
          <p className="text-xl">{selectedClass.year}</p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-8 -mt-16">
        <div className="flex gap-6">
          <div className="flex-1">
            <div className="bg-white rounded-lg shadow mb-4 p-6">
              <button className="w-full flex items-center justify-between text-left">
                <span className="font-medium text-gray-700">Sắp đến hạn</span>
              </button>
              <div className="mt-4 text-sm text-gray-600">
                <div className="font-medium">{selectedClass.deadline}</div>
                <div className="text-gray-500">23:59 - Lí thuyết _ Buổi 9. 24.10.2025</div>
              </div>
              <button className="text-blue-600 text-sm mt-4 hover:underline">Xem tất cả</button>
            </div>

            <div className="mb-4">
              <button className="bg-blue-100 text-blue-700 px-4 py-2 rounded-full text-sm font-medium flex items-center">
                <Bell className="w-4 h-4 mr-2" />
                Thông báo mới
              </button>
            </div>

            {selectedClass.posts.map((post) => (
              <div
                key={post.id}
                onClick={() => { setCurrentPage('post'); setSelectedPost(post); }}
                className="bg-white rounded-lg shadow mb-4 p-6 hover:shadow-lg transition-shadow cursor-pointer"
              >
                <div className="flex items-start">
                  <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white mr-4">
                    📄
                  </div>
                  <div className="flex-1">
                    <h3 className="font-medium text-gray-900">{selectedClass.teacher} đã đăng một bài tập mới: {post.title}</h3>
                    <p className="text-sm text-gray-500 mt-1">{post.date}</p>
                  </div>
                  <button className="p-2 hover:bg-gray-100 rounded">
                    <MoreVertical className="w-5 h-5 text-gray-600" />
                  </button>
                </div>
              </div>
            ))}
          </div>

          <div className="w-80">
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="font-medium text-gray-900 mb-4">Bài tập của bạn</h3>
              <button className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 mb-4">
                + Thêm hoặc tạo
              </button>
              <div className="text-center py-8">
                <button className="bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700">
                  Đánh dấu là đã hoàn thành
                </button>
                <p className="text-sm text-gray-500 mt-4">Không thể nộp bài tập sau ngày đến hạn</p>
              </div>
              <div className="mt-6 border-t pt-4">
                <h4 className="font-medium text-gray-900 mb-2 flex items-center">
                  <span className="mr-2">👤</span>
                  Nhận xét riêng tư
                </h4>
                <button className="text-blue-600 text-sm hover:underline">
                  Thêm nhận xét cho {selectedClass.teacher}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    );
  };

  // Post Detail Page
  const PostDetailPage = () => (
    <div className="flex-1 bg-gray-50 overflow-y-auto p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex gap-6">
          <div className="flex-1">
            <div className="bg-white rounded-lg shadow p-8">
              <div className="flex items-start justify-between mb-6">
                <div className="flex items-start">
                  <div className="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center text-white text-xl mr-4">
                    📄
                  </div>
                  <div>
                    <h1 className="text-3xl font-normal text-gray-900 mb-2">{postDetail.title}</h1>
                    <p className="text-sm text-gray-600">{postDetail.teacher} • {postDetail.date}</p>
                    <p className="text-sm font-medium text-gray-900 mt-1">{postDetail.points}</p>
                  </div>
                </div>
                <button className="p-2 hover:bg-gray-100 rounded">
                  <MoreVertical className="w-5 h-5 text-gray-600" />
                </button>
              </div>

              <div className="mb-6 pb-6 border-b">
                <p className="text-sm text-gray-700">{postDetail.deadline}</p>
              </div>

              <div className="prose max-w-none">
                <p className="text-gray-700 mb-4">
                  <strong>Điểm danh:</strong>{' '}
                  <a href="#" className="text-blue-600 hover:underline">
                    https://forms.gle/iPXSCPq7p8uoe1JT7
                  </a>
                </p>
                <p className="text-gray-700 mb-6">
                  <strong>Xem lại điểm danh:</strong>{' '}
                  <a href="#" className="text-blue-600 hover:underline break-all">
                    https://docs.google.com/spreadsheets/d/1HLuzphU8Iu1KbITzCfWuBTpR6Wc63WUwKwGY1MqaoNU/edit?usp=sharing
                  </a>
                </p>

                <div className="space-y-6">
                  <div>
                    <h3 className="font-bold text-gray-900 mb-3">
                      Chương 21: Native Features và Platform Channels
                    </h3>
                    <ul className="list-disc ml-6 space-y-2 text-gray-700">
                      <li>Giới thiệu về Platform Channels (MethodChannel, EventChannel).</li>
                      <li>
                        Truyền dữ liệu giữa Dart và Native Code (Kotlin/Java cho Android, Swift/Objective-C cho iOS).
                      </li>
                      <li>
                        Truy cập các tính năng Native (ví dụ: truy cập Camera chuyên sâu, Bluetooth, GPS).
                      </li>
                    </ul>
                  </div>

                  <div>
                    <h3 className="font-bold text-gray-900 mb-3">
                      Chương 22: CI/CD (Continuous Integration/Continuous Deployment)
                    </h3>
                    <ul className="list-disc ml-6 space-y-2 text-gray-700">
                      <li>Giới thiệu về CI/CD.</li>
                      <li>Sử dụng Fastlane (tự động hóa build và upload).</li>
                      <li>Giới thiệu về GitHub Actions, Bitrise hoặc Codemagic cho CI/CD.</li>
                    </ul>
                  </div>

                  <div>
                    <h3 className="font-bold text-gray-900 mb-3">
                      Chương 23: Deployment (Triển khai ứng dụng)
                    </h3>
                    <ul className="list-disc ml-6 space-y-2 text-gray-700">
                      <li>Build ứng dụng cho Android (APK, App Bundle).</li>
                      <li>Build ứng dụng cho iOS (IPA).</li>
                      <li>Cấu hình thông tin ứng dụng (icons, splash screen).</li>
                      <li>Đăng ứng dụng lên Google Play Store và Apple App Store.</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="w-80">
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="font-medium text-gray-900 mb-4">Bài tập của bạn</h3>
              <button className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 mb-4">
                + Thêm hoặc tạo
              </button>
              <div className="text-center py-8">
                <button className="bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700">
                  Đánh dấu là đã hoàn thành
                </button>
                <p className="text-sm text-gray-500 mt-4">Không thể nộp bài tập sau ngày đến hạn</p>
              </div>
              <div className="mt-6 border-t pt-4">
                <h4 className="font-medium text-gray-900 mb-2 flex items-center">
                  <span className="mr-2">👤</span>
                  Nhận xét riêng tư
                </h4>
                <button className="text-blue-600 text-sm hover:underline">
                  Thêm nhận xét cho {classData.teacher}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <button className="fixed bottom-8 right-8 w-12 h-12 bg-white rounded-full shadow-lg flex items-center justify-center hover:shadow-xl">
        <HelpCircle className="w-6 h-6 text-gray-600" />
      </button>
    </div>
  );

  return (
    <div className="h-screen flex flex-col">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        {sidebarOpen && <Sidebar />}
        {currentPage === 'home' && <HomePage />}
        {currentPage === 'class' && selectedClass && <ClassDetailPage />}
        {currentPage === 'post' && selectedPost && <PostDetailPage />}
      </div>
    </div>
  );
}

export default App;