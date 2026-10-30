import 'dart:convert';import 'dart:typed_data';import 'package:cryptography/cryptography.dart';
class BackupService {
 final _algo=AesGcm.with256bits();
 Future<Uint8List> encrypt(String json,String password) async {final salt=Cryptography.instance.randomBytes(16),nonce=Cryptography.instance.randomBytes(12);final key=await Pbkdf2(macAlgorithm:Hmac.sha256(),iterations:120000, bits:256).deriveKey(secretKey:SecretKey(utf8.encode(password)),nonce:salt);final box=await _algo.encrypt(utf8.encode(json),secretKey:key,nonce:nonce);return Uint8List.fromList([...utf8.encode('BVB2'),...salt,...nonce,...box.cipherText,...box.mac.bytes]);}
 Future<String> decrypt(Uint8List data,String password) async {if(data.length<48||utf8.decode(data.sublist(0,4))!='BVB2')throw const FormatException('پشتیبان نامعتبر است');final salt=data.sublist(4,20),nonce=data.sublist(20,32),cipher=data.sublist(32,data.length-16),mac=data.sublist(data.length-16);final key=await Pbkdf2(macAlgorithm:Hmac.sha256(),iterations:120000,bits:256).deriveKey(secretKey:SecretKey(utf8.encode(password)),nonce:salt);return utf8.decode(await _algo.decrypt(SecretBox(cipher,nonce:nonce,mac:Mac(mac)),secretKey:key));}
}
