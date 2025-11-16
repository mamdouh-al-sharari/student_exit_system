# 🎓 Student Exit Management System

A comprehensive digital solution for managing student exit requests from schools, replacing traditional paper-based systems with a secure and efficient electronic platform.

## ⚠️ Project Status: READ-ONLY
**This project is provided for educational and demonstration purposes only.**
- 🔒 **No modifications allowed** without explicit permission
- 📚 **Educational use** encouraged
- 🔬 **Testing and experimentation** permitted
- 🚫 **Commercial use prohibited**

## ✨ Key Features

### For Parents
- ✅ Electronic exit request submission
- ✅ One-click student receipt confirmation
- ✅ Cooldown system to prevent spam requests
- ✅ Simple and intuitive user interface

### For Schools
- ✅ Real-time request dashboard
- ✅ Automatic request updates
- ✅ Complete student management (add/remove)
- ✅ Live exit monitoring

## 🛠️ Technology Stack

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **Socket.io** - Real-time communication
- **bcryptjs** - Password encryption

### Frontend
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Provider** - State management
- **HTTP** - API communication

## 📁 Project Structure
student_exit_system/
├── backend/ # Server application
│ ├── models/ # Data models
│ ├── routes/ # API routes
│ └── server.js # Server entry point
└── student_exit_system/ # Flutter application
├── lib/ # Dart source code
├── screens/ # UI screens
└── main.dart # App entry point

text

## 🚀 Quick Start

### Prerequisites
- Node.js 14+
- Flutter SDK
- MongoDB
- Web browser

### 1. Start Backend Server
```bash
cd backend
npm install
npm start
Server runs on: http://localhost:5000

2. Run Flutter App
bash
cd student_exit_system
flutter pub get
flutter run -d chrome
🔧 API Endpoints
Authentication
POST /api/register - Parent registration

POST /api/login - Parent login

POST /api/school-login - School login

Requests
POST /api/requests - Create exit request

PUT /api/requests/:id/parent-complete - Confirm receipt

Students
POST /api/students - Add new student

GET /api/schools/:id/students - Get school students

🔒 Security Features
Password encryption with bcrypt

Input validation and sanitization

Request duplication prevention

User authentication

📞 Support
For questions about this demonstration project:

Review the code documentation

Check existing issues

Contact the project maintainer

Note: This project is for demonstration purposes. Unauthorized modification or commercial use is prohibited.