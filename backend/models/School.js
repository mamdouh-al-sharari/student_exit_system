const mongoose = require('mongoose');
const bcrypt = require('bcryptjs'); // أضف هذا

const schoolSchema = new mongoose.Schema({
  name: { type: String, required: true },
  code: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  phone: { type: String, required: true },
  password: { type: String, required: true }, // أضف هذا
  createdAt: { type: Date, default: Date.now }
});

schoolSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

module.exports = mongoose.models.School || mongoose.model('School', schoolSchema);