const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().gmail.email,
    pass: functions.config().gmail.password
  }
});

exports.sendSupportEmail = functions.firestore
  .document('support_requests/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const mailOptions = {
      from: functions.config().gmail.email,
      to: data.email,
      subject: 'Support Request Received',
      text: `Hi,

Your support request has been received and will be reviewed by our support team. We will contact you soon.

Support Message: ${data.support_message}

Thank you,
Support Team`
    };

    try {
      const info = await transporter.sendMail(mailOptions);
      console.log('Email sent:', info.response);
    } catch (error) {
      console.error('Error sending email:', error);
    }
  });
