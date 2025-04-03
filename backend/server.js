require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());
app.use(cors({ origin: '*' }));

const Goal = mongoose.model('Goal', new mongoose.Schema({
  userId: String,
  title: String,
  description: String,
  date: Date,
}));

app.get('/api/recent-activities/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    
    const goals = await Goal.find({ userId }).sort({ date: -1 }).limit(5);
    const events = await Event.find({ userId }).sort({ date: -1 }).limit(5);
    
    res.json({ goals, events });
  } catch (err) {
    res.status(500).json({ error: 'Error fetching recent activities' });
  }
});

app.post("/api/goal", async (req, res) => {
    const { title, description } = req.body;
    const newGoal = new Goal({ title, description });
    await newGoal.save();
    res.json({ message: "Goal saved successfully!" });
});

app.get("/api/goals", async (req, res) => {
    const goals = await Goal.find();
    res.json(goals);
});

app.get('/api/goals/:userId', async (req, res) => {
  try {
      const goals = await Goal.find({ userId: req.params.userId }).sort({ createdAt: -1 });
      res.json(goals);
  } catch (error) {
      res.status(500).json({ error: 'Failed to fetch goals' });
  }
});
app.get('/api/events/:userId', async (req, res) => {
  try {
      const events = await Event.find({ userId: req.params.userId }).sort({ date: -1 });
      res.json(events);
  } catch (error) {
      res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// MongoDB Connection
mongoose.connect("mongodb+srv://sadneyasam05:root@cluster1.zxxgt.mongodb.net/?retryWrites=true&w=majority&appName=Cluster1", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log("✅ MongoDB Connected"))
  .catch(err => console.error(err));

// User Schema
const userSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  displayName: { type: String, required: true },
  password: { type: String, required: true },
  name: { type: String, default: 'Your Name' },
  phone: { type: String, default: 'Your Phone' },
  bio: { type: String, default: 'A short bio about yourself.' },
  instagram: { type: String, default: '' },
  linkedin: { type: String, default: '' },
  whatsapp: { type: String, default: '' },
});

const User = mongoose.model('User', userSchema);

// Get User Details
const jwt = require('jsonwebtoken');

// 🔹 Register / Check User
app.post('/api/users', async (req, res) => {
  try {
    const { uid, email, displayName, password } = req.body;
    if (!uid || !email || !password) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const existingUser = await User.findOne({ uid });
    if (existingUser) {
      return res.status(200).json({ message: 'User present, proceed to login' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ uid, email, displayName, password: hashedPassword });
    await newUser.save();
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

// 🔹 Login User
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ uid: user.uid }, 'social', { expiresIn: '1h' });
    res.status(200).json({ message: 'Login successful', token, user });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

app.get('/api/users/:uid', async (req, res) => {
  const userUid = req.params.uid;
  console.log("👉 Fetching user with UID:", userUid); // Log the requested UID

  try {
    const user = await User.findOne({ uid: userUid });

    if (!user) {
      console.log("❌ User not found in database");
      return res.status(404).json({ message: 'User not found' });
    }

    console.log("✅ User found:", user);
    res.json(user);
  } catch (error) {
    console.error("🔥 Error fetching user:", error);
    res.status(500).json({ message: 'Server error', error });
  }
});

app.put('/api/users/email/:email', async (req, res) => {
  try {
    const userEmail = req.params.email;
    const updateData = req.body; // Data to update

    console.log("🔄 Updating user with email:", userEmail);

    const updatedUser = await User.findOneAndUpdate(
      { email: userEmail }, // Find user by email
      { $set: updateData }, // Update fields dynamically
      { new: true } // Return updated user
    );

    if (!updatedUser) {
      console.log("❌ User not found");
      return res.status(404).json({ message: 'User not found' });
    }

    console.log("✅ User updated successfully:", updatedUser);
    res.json({ message: 'User updated successfully', user: updatedUser });

  } catch (error) {
    console.error("🔥 Error updating user:", error);
    res.status(500).json({ message: 'Server error', error });
  }
});


const eventSchema = new mongoose.Schema({
  userId: String,
  title: String,
  description: String,
  date: String,
  time: String,
  qrCodeUrl: String,
  title: String,
  location: String,
  date: Date,
});

const Event = mongoose.model("Event", eventSchema);

const registrationSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: "Event", required: true },
  email: { type: String, required: true },
});

const Registration = mongoose.model("Registration", registrationSchema);

app.post("/registerEvent/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.status(200).json({ message: "User registered for the event successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error", error });
  }
});



app.get("/events", async (req, res) => {
  const events = await Event.find();
  res.json({ 
    events: events.map(event => ({
      _id: event._id || "",
      title: event.title || "",
      description: event.description || "",
      date: event.date || "",
      time: event.time || "",
      qrCodeUrl: event.qrCodeUrl || "",
    }))
  });
});


app.post("/createEvent", async (req, res) => {
  const { title, description, date, time } = req.body;
  const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?data=Event:${title}`;
  const newEvent = new Event({ title, description, date, time, qrCodeUrl });
  await newEvent.save();
  res.json({ message: "Event created successfully!" });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));