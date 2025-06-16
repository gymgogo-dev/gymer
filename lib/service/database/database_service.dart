import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  // ✅ Gunakan URL dari project kamu
  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://gymer-8b429-default-rtdb.firebaseio.com/",
  );

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> recordAttendance(String email, String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = database.ref().child('users');
      DatabaseReference attendanceRef = database.ref().child('attendance/');

      try {
        // Query to find user with matching email
        var query = userRef.orderByChild('email').equalTo(email);
        DatabaseEvent event = await query.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic>? users =
              snapshot.value as Map<dynamic, dynamic>?;

          String? userId;
          users?.forEach((key, value) {
            if (value['email'] == email) {
              userId = key;
            }
          });

          if (userId != null) {
            var userData = users?[userId];
            var membership = userData?['membership'];
            var remainingDays = membership?['remainingDays'];

            var now = DateTime.now();
            var todayString = "${now.year}-${now.month}-${now.day}";
            var timeString = "${now.hour}:${now.minute}";

            var attendanceSnapshot =
                await attendanceRef.orderByChild('email').equalTo(email).get();

            bool alreadyMarkedToday = false;

            if (attendanceSnapshot.value != null) {
              Map<dynamic, dynamic>? attendanceRecords =
                  attendanceSnapshot.value as Map<dynamic, dynamic>?;
              attendanceRecords?.forEach((key, value) {
                if (value['date'] == todayString) {
                  alreadyMarkedToday = true;
                }
              });
            }

            if (!alreadyMarkedToday &&
                remainingDays != null &&
                remainingDays > 0) {
              remainingDays -= 1;
              await userRef.child(userId!).child('membership').update({
                'remainingDays': remainingDays,
              });
            }

            await attendanceRef.push().set({
              'date': todayString,
              'time': timeString,
              'email': email,
              'name': name,
              'remainingDays': remainingDays
            });
          } else {
            print('Email $email not found in the database.');
          }
        } else {
          print('Email $email not found in the database.');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<Map<String, String>?> getUserName() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        final ref = database.ref();
        DataSnapshot snapshot = await ref.child('users/${user.uid}/').get();
        if (snapshot.exists) {
          String name = snapshot.child('nama').value.toString();
          return {
            'name': name,
          };
        } else {
          print('No data available');
          return null;
        }
      }
    } catch (e) {
      print('Error getting userName: $e');
      return null;
    }
    return null;
  }

  Stream<List<Map<String, String>>> getAbsenceList() {
    final ref = database.ref().child('attendance/');

    return ref.onValue.map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        List<Map<String, String>> absences = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          absences.add({
            'date': value['date'].toString(),
            'email': value['email'].toString(),
            'name': value['name'].toString(),
            'remainingDays': value['remainingDays'].toString(),
            'time': value['time'].toString()
          });
        });

        return absences;
      } else {
        print('No absence data available');
        return [];
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getMemberList() {
    final ref = database.ref().child('users');

    return ref.onValue.map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        List<Map<String, dynamic>> members = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final memberData = {
            'uid': key.toString(),
            'email': value['email']?.toString() ?? '',
            'nama': value['nama']?.toString() ?? '',
            'membership': {
              'package': value['membership']?['package']?.toString() ?? '',
              'remainingDays': value['membership']?['remainingDays'] ?? 0,
            }
          };

          members.add(memberData);
        });

        return members;
      } else {
        print('No member data available');
        return [];
      }
    });
  }

  Future<void> deleteMember(String uid) async {
    try {
      await database.ref().child('users').child(uid).remove();
    } catch (e) {
      print('Error deleting member: $e');
      throw Exception('Gagal menghapus member.');
    }
  }

  Future<void> updateMember(
      String uid, Map<String, dynamic> updatedData) async {
    final ref = database.ref().child('users').child(uid);
    await ref.update(updatedData);
  }

  Stream<Map<String, String>?> getUserDetailsStream() {
    User? user = auth.currentUser;
    if (user != null) {
      final ref = database.ref().child('users/${user.uid}');
      return ref.onValue.map((event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          String name = snapshot.child('nama').value.toString();
          String email = snapshot.child('email').value.toString();
          String package =
              snapshot.child('membership/package').value.toString();
          String remainingDays =
              snapshot.child('membership/remainingDays').value.toString();

          return {
            'name': name,
            'email': email,
            'package': package,
            'remainingDays': remainingDays,
          };
        } else {
          print('No data available');
          return null;
        }
      });
    } else {
      print('User not logged in');
      return Stream.value(null);
    }
  }
}
