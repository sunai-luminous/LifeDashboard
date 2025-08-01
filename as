<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Life Dashboard - Mobile</title>
    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            touch-action: manipulation;
            -webkit-overflow-scrolling: touch;
        }
        .tab-button {
            -webkit-tap-highlight-color: transparent;
        }
        .input-focus {
            -webkit-appearance: none;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div id="root"></div>

    <script type="text/babel">
        const { useState, useEffect } = React;

        // アイコンコンポーネント
        const FileText = () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>;
        const BookOpen = () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></svg>;
        const Briefcase = () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2-2v2m8 0H8m8 0v6a2 2 0 01-2 2H10a2 2 0 01-2-2V6" /></svg>;
        const Plus = () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" /></svg>;
        const Check = () => <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" /></svg>;
        const X = () => <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M6 18L18 6M6 6l12 12" /></svg>;
        const Edit3 = () => <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>;
        const Download = () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>;

        const MobileLifeDashboard = () => {
            const [activeTab, setActiveTab] = useState('diary');
            const [diaryEntries, setDiaryEntries] = useState([]);
            const [studyTasks, setStudyTasks] = useState([]);
            const [workSchedule, setWorkSchedule] = useState([]);
            const [newEntry, setNewEntry] = useState('');
            const [editingId, setEditingId] = useState(null);
            const [editText, setEditText] = useState('');
            const [showAddForm, setShowAddForm] = useState(false);
            const [saveStatus, setSaveStatus] = useState('');

            // ローカルストレージ管理
            const STORAGE_KEYS = {
                diary: 'mobileDashboard_diary',
                study: 'mobileDashboard_study',
                work: 'mobileDashboard_work'
            };

            const saveToStorage = (key, data) => {
                try {
                    localStorage.setItem(key, JSON.stringify(data));
                } catch (error) {
                    console.error('保存に失敗しました:', error);
                }
            };

            const loadFromStorage = (key) => {
                try {
                    const stored = localStorage.getItem(key);
                    return stored ? JSON.parse(stored) : [];
                } catch (error) {
                    console.error('読み込みに失敗しました:', error);
                    return [];
                }
            };

            useEffect(() => {
                setDiaryEntries(loadFromStorage(STORAGE_KEYS.diary));
                setStudyTasks(loadFromStorage(STORAGE_KEYS.study));
                setWorkSchedule(loadFromStorage(STORAGE_KEYS.work));
            }, []);

            useEffect(() => {
                if (diaryEntries.length >= 0) saveToStorage(STORAGE_KEYS.diary, diaryEntries);
            }, [diaryEntries]);

            useEffect(() => {
                if (studyTasks.length >= 0) saveToStorage(STORAGE_KEYS.study, studyTasks);
            }, [studyTasks]);

            useEffect(() => {
                if (workSchedule.length >= 0) saveToStorage(STORAGE_KEYS.work, workSchedule);
            }, [workSchedule]);

            const today = new Date().toISOString().split('T')[0];

            // シフトパターン
            const shiftPatterns = {
                a: { name: '日勤', color: 'bg-yellow-100 text-yellow-800 border-yellow-200' },
                b: { name: '夜勤', color: 'bg-blue-100 text-blue-800 border-blue-200' },
                c: { name: '深夜勤', color: 'bg-purple-100 text-purple-800 border-purple-200' },
                z: { name: '休み', color: 'bg-green-100 text-green-800 border-green-200' }
            };

            // PDF出力機能
            const generatePDF = () => {
                try {
                    const { jsPDF } = window.jspdf;
                    const doc = new jsPDF();
                    
                    let yPosition = 20;
                    
                    // タイトル
                    doc.setFontSize(20);
                    doc.text('Life Dashboard Report', 20, yPosition);
                    yPosition += 15;
                    
                    doc.setFontSize(12);
                    doc.text(`Generated: ${new Date().toLocaleDateString('ja-JP')}`, 20, yPosition);
                    yPosition += 20;

                    // 日記セクション
                    if (diaryEntries.length > 0) {
                        doc.setFontSize(16);
                        doc.text('=== DIARY ===', 20, yPosition);
                        yPosition += 10;
                        doc.setFontSize(10);
                        
                        diaryEntries.forEach((entry) => {
                            if (yPosition > 270) {
                                doc.addPage();
                                yPosition = 20;
                            }
                            
                            doc.text(`[${entry.timestamp}]`, 20, yPosition);
                            yPosition += 5;
                            
                            const lines = doc.splitTextToSize(entry.content, 170);
                            doc.text(lines, 20, yPosition);
                            yPosition += lines.length * 5 + 10;
                        });
                        yPosition += 10;
                    }

                    // 勉強セクション
                    if (studyTasks.length > 0) {
                        if (yPosition > 250) {
                            doc.addPage();
                            yPosition = 20;
                        }
                        
                        doc.setFontSize(16);
                        doc.text('=== STUDY TASKS ===', 20, yPosition);
                        yPosition += 10;
                        doc.setFontSize(10);
                        
                        const completedTasks = studyTasks.filter(t => t.completed).length;
                        doc.text(`Progress: ${completedTasks}/${studyTasks.length} completed`, 20, yPosition);
                        yPosition += 10;
                        
                        studyTasks.forEach((task) => {
                            if (yPosition > 270) {
                                doc.addPage();
                                yPosition = 20;
                            }
                            
                            const status = task.completed ? '[✓]' : '[ ]';
                            doc.text(`${status} ${task.subject}`, 20, yPosition);
                            yPosition += 7;
                        });
                        yPosition += 10;
                    }

                    // 仕事セクション
                    if (workSchedule.length > 0) {
                        if (yPosition > 250) {
                            doc.addPage();
                            yPosition = 20;
                        }
                        
                        doc.setFontSize(16);
                        doc.text('=== WORK SCHEDULE ===', 20, yPosition);
                        yPosition += 10;
                        doc.setFontSize(10);
                        
                        workSchedule.forEach((schedule) => {
                            if (yPosition > 270) {
                                doc.addPage();
                                yPosition = 20;
                            }
                            
                            const shiftType = schedule.shift.toLowerCase().charAt(0);
                            const pattern = shiftPatterns[shiftType] || { name: '不明' };
                            
                            doc.text(`${schedule.date}: ${schedule.shift} (${pattern.name})`, 20, yPosition);
                            yPosition += 7;
                        });
                    }

                    // PDF保存
                    const fileName = `life-dashboard-${new Date().toISOString().split('T')[0]}.pdf`;
                    doc.save(fileName);
                    
                    setSaveStatus('PDF出力完了 ✓');
                    setTimeout(() => setSaveStatus(''), 2000);
                    
                } catch (error) {
                    console.error('PDF生成エラー:', error);
                    setSaveStatus('PDF出力に失敗');
                    setTimeout(() => setSaveStatus(''), 2000);
                }
            };

            // 追加関数
            const addDiaryEntry = () => {
                if (newEntry.trim()) {
                    const entry = {
                        id: Date.now(),
                        date: today,
                        content: newEntry,
                        timestamp: new Date().toLocaleString('ja-JP')
                    };
                    setDiaryEntries([entry, ...diaryEntries]);
                    setNewEntry('');
                    setShowAddForm(false);
                }
            };

            const addStudyTask = () => {
                if (newEntry.trim()) {
                    const task = {
                        id: Date.now(),
                        subject: newEntry,
                        completed: false,
                        date: today
                    };
                    setStudyTasks([...studyTasks, task]);
                    setNewEntry('');
                    setShowAddForm(false);
                }
            };

            const addWorkSchedule = () => {
                if (newEntry.trim()) {
                    const schedule = {
                        id: Date.now(),
                        date: today,
                        shift: newEntry,
                        notes: ''
                    };
                    setWorkSchedule([...workSchedule, schedule]);
                    setNewEntry('');
                    setShowAddForm(false);
                }
            };

            const toggleStudyTask = (id) => {
                setStudyTasks(studyTasks.map(task =>
                    task.id === id ? { ...task, completed: !task.completed } : task
                ));
            };

            const deleteEntry = (id, type) => {
                if (type === 'diary') {
                    setDiaryEntries(diaryEntries.filter(entry => entry.id !== id));
                } else if (type === 'study') {
                    setStudyTasks(studyTasks.filter(task => task.id !== id));
                } else if (type === 'work') {
                    setWorkSchedule(workSchedule.filter(schedule => schedule.id !== id));
                }
            };

            const tabs = [
                { id: 'diary', name: '日記', icon: FileText },
                { id: 'study', name: '勉強', icon: BookOpen },
                { id: 'work', name: '仕事', icon: Briefcase }
            ];

            return (
                <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
                    {/* ヘッダー */}
                    <div className="bg-white shadow-sm px-4 py-3 sticky top-0 z-10">
                        <div className="flex justify-between items-center">
                            <div>
                                <h1 className="text-xl font-bold text-gray-800">Life Dashboard</h1>
                                <p className="text-xs text-gray-500">
                                    {new Date().toLocaleDateString('ja-JP', { month: 'short', day: 'numeric', weekday: 'short' })}
                                </p>
                            </div>
                            
                            {/* PDF出力ボタン */}
                            <div className="flex items-center space-x-3">
                                {saveStatus && (
                                    <span className="text-xs text-green-600 font-medium">{saveStatus}</span>
                                )}
                                <button
                                    onClick={generatePDF}
                                    className="bg-red-500 text-white p-2 rounded-full shadow-lg hover:bg-red-600 transition-colors"
                                    title="PDF出力"
                                >
                                    <Download />
                                </button>
                            </div>
                        </div>
                    </div>

                    {/* タブナビゲーション */}
                    <div className="bg-white border-b sticky top-16 z-10">
                        <div className="flex">
                            {tabs.map(tab => {
                                const Icon = tab.icon;
                                return (
                                    <button
                                        key={tab.id}
                                        onClick={() => {
                                            setActiveTab(tab.id);
                                            setShowAddForm(false);
                                            setEditingId(null);
                                        }}
                                        className={`flex-1 flex flex-col items-center py-3 px-2 tab-button transition-colors ${
                                            activeTab === tab.id
                                                ? 'bg-blue-500 text-white'
                                                : 'text-gray-600 hover:bg-gray-50'
                                        }`}
                                    >
                                        <Icon />
                                        <span className="text-xs mt-1">{tab.name}</span>
                                    </button>
                                );
                            })}
                        </div>
                    </div>

                    {/* コンテンツエリア */}
                    <div className="px-4 py-4">
                        {/* 日記タブ */}
                        {activeTab === 'diary' && (
                            <div>
                                <div className="flex justify-between items-center mb-4">
                                    <h2 className="text-lg font-bold text-gray-800">日記 ({diaryEntries.length}件)</h2>
                                    <button
                                        onClick={() => setShowAddForm(!showAddForm)}
                                        className="bg-blue-500 text-white p-2 rounded-full shadow-lg hover:bg-blue-600 transition-colors"
                                    >
                                        <Plus />
                                    </button>
                                </div>

                                {showAddForm && (
                                    <div className="bg-white rounded-xl shadow-md p-4 mb-4">
                                        <textarea
                                            value={newEntry}
                                            onChange={(e) => setNewEntry(e.target.value)}
                                            placeholder="今日の出来事や感想を書いてください..."
                                            className="w-full p-3 border border-gray-300 rounded-lg resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent input-focus"
                                            rows="4"
                                        />
                                        <div className="flex justify-end space-x-2 mt-3">
                                            <button
                                                onClick={() => setShowAddForm(false)}
                                                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
                                            >
                                                キャンセル
                                            </button>
                                            <button
                                                onClick={addDiaryEntry}
                                                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                                            >
                                                追加
                                            </button>
                                        </div>
                                    </div>
                                )}

                                <div className="space-y-3">
                                    {diaryEntries.map(entry => (
                                        <div key={entry.id} className="bg-white rounded-xl shadow-md p-4">
                                            <div className="flex justify-between items-start mb-2">
                                                <span className="text-xs text-gray-500">{entry.timestamp}</span>
                                                <div className="flex space-x-2">
                                                    <button
                                                        onClick={() => {
                                                            setEditingId(entry.id);
                                                            setEditText(entry.content);
                                                        }}
                                                        className="text-gray-400 hover:text-blue-500 p-1"
                                                    >
                                                        <Edit3 />
                                                    </button>
                                                    <button
                                                        onClick={() => deleteEntry(entry.id, 'diary')}
                                                        className="text-gray-400 hover:text-red-500 p-1"
                                                    >
                                                        <X />
                                                    </button>
                                                </div>
                                            </div>
                                            {editingId === entry.id ? (
                                                <div>
                                                    <textarea
                                                        value={editText}
                                                        onChange={(e) => setEditText(e.target.value)}
                                                        className="w-full p-2 border border-gray-300 rounded-lg input-focus"
                                                        rows="3"
                                                    />
                                                    <div className="flex justify-end space-x-2 mt-2">
                                                        <button
                                                            onClick={() => setEditingId(null)}
                                                            className="px-3 py-1 text-gray-600 hover:bg-gray-100 rounded-md text-sm"
                                                        >
                                                            キャンセル
                                                        </button>
                                                        <button
                                                            onClick={() => {
                                                                setDiaryEntries(diaryEntries.map(e =>
                                                                    e.id === entry.id ? { ...e, content: editText } : e
                                                                ));
                                                                setEditingId(null);
                                                            }}
                                                            className="px-3 py-1 bg-green-500 text-white rounded-md text-sm hover:bg-green-600"
                                                        >
                                                            保存
                                                        </button>
                                                    </div>
                                                </div>
                                            ) : (
                                                <p className="text-gray-700 whitespace-pre-wrap">{entry.content}</p>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* 勉強タブ */}
                        {activeTab === 'study' && (
                            <div>
                                <div className="flex justify-between items-center mb-4">
                                    <h2 className="text-lg font-bold text-gray-800">
                                        勉強 ({studyTasks.filter(t => t.completed).length}/{studyTasks.length})
                                    </h2>
                                    <button
                                        onClick={() => setShowAddForm(!showAddForm)}
                                        className="bg-green-500 text-white p-2 rounded-full shadow-lg hover:bg-green-600 transition-colors"
                                    >
                                        <Plus />
                                    </button>
                                </div>

                                {showAddForm && (
                                    <div className="bg-white rounded-xl shadow-md p-4 mb-4">
                                        <input
                                            type="text"
                                            value={newEntry}
                                            onChange={(e) => setNewEntry(e.target.value)}
                                            placeholder="勉強する科目やタスクを入力..."
                                            className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent input-focus"
                                        />
                                        <div className="flex justify-end space-x-2 mt-3">
                                            <button
                                                onClick={() => setShowAddForm(false)}
                                                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
                                            >
                                                キャンセル
                                            </button>
                                            <button
                                                onClick={addStudyTask}
                                                className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                                            >
                                                追加
                                            </button>
                                        </div>
                                    </div>
                                )}

                                <div className="space-y-3">
                                    {studyTasks.map(task => (
                                        <div key={task.id} className={`bg-white rounded-xl shadow-md p-4 border-l-4 ${
                                            task.completed ? 'border-green-400' : 'border-gray-200'
                                        }`}>
                                            <div className="flex items-center justify-between">
                                                <div className="flex items-center flex-1">
                                                    <button
                                                        onClick={() => toggleStudyTask(task.id)}
                                                        className={`mr-3 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-colors ${
                                                            task.completed 
                                                                ? 'bg-green-500 border-green-500 text-white' 
                                                                : 'border-gray-300 text-transparent hover:border-green-400'
                                                        }`}
                                                    >
                                                        <Check />
                                                    </button>
                                                    <span className={`flex-1 ${task.completed ? 'line-through text-gray-500' : 'text-gray-700'}`}>
                                                        {task.subject}
                                                    </span>
                                                </div>
                                                <button
                                                    onClick={() => deleteEntry(task.id, 'study')}
                                                    className="text-gray-400 hover:text-red-500 p-1 ml-2"
                                                >
                                                    <X />
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* 仕事タブ */}
                        {activeTab === 'work' && (
                            <div>
                                <div className="flex justify-between items-center mb-4">
                                    <h2 className="text-lg font-bold text-gray-800">仕事 ({workSchedule.length}件)</h2>
                                    <button
                                        onClick={() => setShowAddForm(!showAddForm)}
                                        className="bg-purple-500 text-white p-2 rounded-full shadow-lg hover:bg-purple-600 transition-colors"
                                    >
                                        <Plus />
                                    </button>
                                </div>

                                {/* シフトパターン説明 */}
                                <div className="bg-white rounded-xl shadow-md p-4 mb-4">
                                    <h3 className="font-medium text-sm mb-3 text-gray-800">シフトパターン</h3>
                                    <div className="grid grid-cols-2 gap-2">
                                        {Object.entries(shiftPatterns).map(([key, pattern]) => (
                                            <div key={key} className={`px-3 py-2 rounded-lg border text-sm ${pattern.color}`}>
                                                <span className="font-medium">{key.toUpperCase()}:</span> {pattern.name}
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                {showAddForm && (
                                    <div className="bg-white rounded-xl shadow-md p-4 mb-4">
                                        <input
                                            type="text"
                                            value={newEntry}
                                            onChange={(e) => setNewEntry(e.target.value)}
                                            placeholder="シフト情報を入力 (例: a1, b2, c3, z1)"
                                            className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent input-focus"
                                        />
                                        <div className="flex justify-end space-x-2 mt-3">
                                            <button
                                                onClick={() => setShowAddForm(false)}
                                                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
                                            >
                                                キャンセル
                                            </button>
                                            <button
                                                onClick={addWorkSchedule}
                                                className="px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
                                            >
                                                追加
                                            </button>
                                        </div>
                                    </div>
                                )}

                                <div className="space-y-3">
                                    {workSchedule.map(schedule => {
                                        const shiftType = schedule.shift.toLowerCase().charAt(0);
                                        const pattern = shiftPatterns[shiftType] || { name: '不明', color: 'bg-gray-100 text-gray-800 border-gray-200' };
                                        
                                        return (
                                            <div key={schedule.id} className="bg-white rounded-xl shadow-md p-4">
                                                <div className="flex items-center justify-between">
                                                    <div className="flex items-center">
                                                        <div className={`px-3 py-1 rounded-lg mr-3 border text-sm font-medium ${pattern.color}`}>
                                                            {schedule.shift}
                                                        </div>
                                                        <div>
                                                            <p className="text-gray-600 text-sm">{schedule.date}</p>
                                                            <p className="text-xs text-gray-500">({pattern.name})</p>
                                                        </div>
                                                    </div>
                                                    <button
                                                        onClick={() => deleteEntry(schedule.id, 'work')}
                                                        className="text-gray-400 hover:text-red-500 p-1"
                                                    >
                                                        <X />
                                                    </button>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}
                    </div>

                    {/* 下部スペース */}
                    <div className="h-20"></div>
                </div>
            );
        };

        ReactDOM.render(<MobileLifeDashboard />, document.getElementById('root'));
    </script>
</body>
</html>
