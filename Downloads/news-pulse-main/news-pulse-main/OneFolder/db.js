const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error("MongoDB connection error:", error.message);
    // Don't exit process, allow server to start without DB for development
    console.log(
      "Server starting without MongoDB connection. Please configure MONGODB_URI in .env"
    );
  }
};

module.exports = connectDB;
