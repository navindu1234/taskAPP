const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Replace with your email & app password
const emailSender = "your-email@gmail.com";
const emailPassword = "your-app-password";

// Setup mail transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: emailSender,
    pass: emailPassword,
  },
});

// Cloud function to send an email
exports.sendEmail = functions.https.onCall(async (data, context) => {
  const { email, uniqueCode } = data;

  const mailOptions = {
    from: emailSender,
    to: email,
    subject: "TASKNEST Seller Registration",
    text: `Thank you for registering as a seller. Your unique code is: ${uniqueCode}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
