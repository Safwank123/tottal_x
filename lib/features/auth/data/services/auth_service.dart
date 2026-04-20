import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  Future<UserCredential> signInWithGoogle() async {
    try {
      print('🔍 [AuthService] Starting Google Sign-In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('📱 [AuthService] Google Sign-In returned: ${googleUser?.email ?? "null"} | isNull: ${googleUser == null}');

      if (googleUser == null) {
        print('❌ [AuthService] Google sign-in was cancelled by user');
        throw Exception('Google sign-in was cancelled.');
      }

      print('✅ [AuthService] User logged in: ${googleUser.email}');
      print('🔐 [AuthService] Getting authentication tokens...');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('🔑 [AuthService] Authentication tokens retrieved | idToken: ${googleAuth.idToken != null} | accessToken: ${googleAuth.accessToken != null}');

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        print('❌ [AuthService] Missing authentication tokens!');
        print('   - idToken: ${googleAuth.idToken}');
        print('   - accessToken: ${googleAuth.accessToken}');
        throw Exception('Could not obtain Google authentication tokens.');
      }

      print('🔗 [AuthService] Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken,
      );

      print('🚀 [AuthService] Signing in with Firebase...');
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      print('✅ [AuthService] Firebase authentication successful!');
      print('👤 [AuthService] User UID: ${userCredential.user?.uid}');
      print('📧 [AuthService] User Email: ${userCredential.user?.email}');
      
      return userCredential;
    } catch (e, stackTrace) {
      print('❌ [AuthService] ERROR: $e');
      print('📋 [AuthService] Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
