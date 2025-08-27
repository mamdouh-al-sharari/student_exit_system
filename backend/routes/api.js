const express = require('express');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Student = require('../models/Student');
const School = require('../models/School');
const Request = require('../models/Request');

const router = express.Router();

router.get('/test', (req, res) => {
  res.json({ 
    message: '✅ الخادم يعمل بشكل صحيح!',
    timestamp: new Date().toISOString(),
    database: 'MongoDB Connected'
  });
});


// تسجيل ولي أمر جديد
router.post('/register', async (req, res) => {
  try {
    const { phoneNumber, name, password } = req.body;
    
    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(400).json({ message: 'رقم الجوال مسجل مسبقاً' });
    }
    
    const user = new User({ phoneNumber, name, password });
    await user.save();
    
    res.status(201).json({ message: 'تم التسجيل بنجاح', userId: user._id });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// تسجيل الدخول
router.post('/login', async (req, res) => {
  try {
    const { phoneNumber, password } = req.body;
    
    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(404).json({ message: 'رقم الجوال غير مسجل' });
    }
    
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'كلمة المرور غير صحيحة' });
    }
    
    // البحث التلقائي عن أبناء ولي الأمر
    const children = await Student.find({ parentPhone: phoneNumber }).populate('school');
    
    res.json({ 
      message: 'تم تسجيل الدخول بنجاح', 
      user: {
        id: user._id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        children: children // إرجاع الأبناء الموجودة
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// إنشاء طلب خروج
router.post('/requests', async (req, res) => {
  try {
    const { studentId, parentId, notes } = req.body;
    
    const student = await Student.findById(studentId).populate('school');
    if (!student) {
      return res.status(404).json({ message: 'الطالب غير موجود' });
    }
    
    const request = new Request({
      student: studentId,
      parent: parentId,
      school: student.school._id,
      notes: notes
    });
    
    await request.save();
    await request.populate('student school');
    
    res.status(201).json({ message: 'تم إنشاء طلب الخروج', request });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// استرجاع طلبات الخروج للمدرسة
router.get('/schools/:schoolId/requests', async (req, res) => {
  try {
    const requests = await Request.find({ 
      school: req.params.schoolId,
      status: 'pending'
    }).populate('student parent');
    
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// تحديث حالة الطلب (تم الاستلام)
router.put('/requests/:requestId/complete', async (req, res) => {
  try {
    const request = await Request.findByIdAndUpdate(
      req.params.requestId,
      { 
        status: 'completed',
        completedAt: new Date()
      },
      { new: true }
    ).populate('student parent');
    
    if (!request) {
      return res.status(404).json({ message: 'طلب الخروج غير موجود' });
    }
    
    res.json({ message: 'تم تحديث حالة الطلب', request });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// تسجيل مدرسة جديدة
router.post('/register-school', async (req, res) => {
  try {
    const { name, code, address, phone, password } = req.body;
    
    // التحقق من وجود المدرسة مسبقاً
    const existingSchool = await School.findOne({ code });
    if (existingSchool) {
      return res.status(400).json({ message: 'كود المدرسة مسجل مسبقاً' });
    }
    
    // إنشاء مدرسة جديدة
    const school = new School({
      name,
      code,
      address, 
      phone,
      password
    });
    
    await school.save();
    
    res.status(201).json({ 
      message: 'تم تسجيل المدرسة بنجاح',
      school: {
        id: school._id,
        name: school.name,
        code: school.code,
        address: school.address,
        phone: school.phone,
        password: school.password
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في تسجيل المدرسة', error: error.message });
  }
});

// دخول المدرسة
router.post('/school-login', async (req, res) => {
  try {
    const { code, password } = req.body;
    
    const school = await School.findOne({ code });
    if (!school) {
      return res.status(404).json({ message: 'كود المدرسة غير صحيح' });
    }
    
    const isPasswordValid = await bcrypt.compare(password, school.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'كلمة المرور غير صحيحة' });
    }
    
    res.json({ 
      message: 'تم دخول المدرسة بنجاح',
      school: {
        id: school._id,
        name: school.name,
        code: school.code
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في الدخول', error: error.message });
  }
});

// إضافة طالب جديد
router.post('/students', async (req, res) => {
  try {
    const { name, studentId, grade, className, parentPhone, schoolId } = req.body;

    // لا تبحث عن ولي الأمر - فقط خزن رقم الجوال
    const student = new Student({
      name,
      studentId,
      grade,
      class: className,
      school: schoolId,
      parentPhone: parentPhone // خزن رقم الجوال فقط
    });

    await student.save();

    res.status(201).json({ 
      message: 'تم إضافة الطالب بنجاح',
      student: await student.populate('school')
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في إضافة الطالب', error: error.message });
  }
});

// جلب طلاب المدرسة
router.get('/schools/:schoolId/students', async (req, res) => {
  try {
    const students = await Student.find({ school: req.params.schoolId });
    res.json(students);
  } catch (error) {
    res.status(500).json({ message: 'خطأ في جلب الطلاب', error: error.message });
  }
});

// استرجاع الأبناء المرتبطين بولي الأمر (باستخدام رقم الجوال)
router.get('/parents/phone/:parentPhone/children', async (req, res) => {
  try {
    const parentPhone = req.params.parentPhone;
    console.log('🔍 البحث عن أبناء للرقم:', parentPhone);
    
    const children = await Student.find({ parentPhone: parentPhone })
      .populate('school');
    
    console.log('✅ عدد الأبناء found:', children.length);
    res.json(children);
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});

// أضف أيضا هذا الـ Route للاختبار
router.get('/test-parents', async (req, res) => {
  try {
    const students = await Student.find().populate('school');
    res.json({ 
      message: 'اختبار الطلاب',
      count: students.length,
      students: students 
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في الاختبار', error: error.message });
  }
});

// استرجاع الطلبات النشطة لولي الأمر
router.get('/parents/:parentId/active-requests', async (req, res) => {
  try {
    const requests = await Request.find({ 
      parent: req.params.parentId,
      status: 'pending' // فقط الطلبات النشطة
    }).populate('student school');
    
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'خطأ في السيرفر', error: error.message });
  }
});



module.exports = router;