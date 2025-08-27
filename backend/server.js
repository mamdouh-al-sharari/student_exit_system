const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// تأخير استيراد الـ Routes حتى بعد اتصال MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/student_exit_system', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('Connected to MongoDB');
  
  // استيراد الـ Routes بعد الاتصال بقاعدة البيانات
  const apiRoutes = require('./routes/api');
  app.use('/api', apiRoutes);
  
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
})
.catch(err => console.error('MongoDB connection error:', err));