const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');
initializeApp();
const db = getFirestore();

// Transaction marker prevents retrying a trigger from awarding points twice.
exports.awardReview = onDocumentCreated('users/{uid}/reviews/{eventId}', async event => {
  const {uid, eventId} = event.params;
  const review = event.data.data();
  const marker = db.doc(`users/${uid}/awarded/${eventId}`);
  const leaderboard = db.doc(`leaderboard/${uid}`);
  await db.runTransaction(async tx => {
    const awarded = await tx.get(marker);
    if (awarded.exists) return;
    const profile = await tx.get(leaderboard);
    tx.set(marker, {at: FieldValue.serverTimestamp()});
    tx.set(leaderboard, {name: profile.data()?.name ?? `Ученик ${uid.slice(0, 5)}`, xp: (profile.data()?.xp ?? 0) + (review.recall === 0 ? 2 : 10), updatedAt: FieldValue.serverTimestamp()});
  });
});

// One due-review push per UTC day. Local, customizable daily reminders are separate.
exports.remindDueReviews = onSchedule({schedule:'every day 16:00',timeZone:'Etc/UTC'}, async () => {
  const day = new Date().toISOString().slice(0,10);
  const users = await db.collection('leaderboard').get();
  for (const user of users.docs) {
    const refs = db.collection('users').doc(user.id);
    const reviews = await refs.collection('reviews').get();
    const latest = new Map();
    for (const doc of reviews.docs) {
      const review = doc.data();
      if (!latest.has(review.wordId) || latest.get(review.wordId).at < review.at) latest.set(review.wordId, review);
    }
    const due = [...latest.values()].filter(r => Date.parse(r.progress?.due) <= Date.now()).length;
    if (!due) continue;
    const devices = await refs.collection('devices').get();
    if(devices.empty) continue;
    const marker = refs.collection('reminders').doc(day);
    const claimed = await db.runTransaction(async tx => {
      if((await tx.get(marker)).exists) return false;
      tx.set(marker,{claimedAt:FieldValue.serverTimestamp()});
      return true;
    });
    if(!claimed) continue;
    for (const device of devices.docs) {
      try {
        await getMessaging().send({token:device.data().token,notification:{title:'Слова ждут встречи',body:`Пора повторить ${due} слов. Уделите себе несколько минут.`},android:{notification:{channelId:'daily_review'}}});
      } catch(error) {
        if(['messaging/registration-token-not-registered','messaging/invalid-registration-token'].includes(error.code)) await device.ref.delete();
        else console.error('Reminder delivery failed', error.code);
      }
    }
  }
});
