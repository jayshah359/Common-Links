//
//  JTBEncryptedArchiver.h
//  Archiver
//
//  Created by Jonathan Backer on 1/20/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

@interface JTBEncryptedArchiver : NSObject

/*
 * Recommended NSSearchPathDirectory:
 *   NSDocumentDirectory Critical user-specific documents, user can see these files in iTunes, backed up on iCloud and local iTunes backups)
 *   NSLibraryDirectory  Critical non-user-specific documents, backed up on iCloud and local iTunes backups
 *   NSCachesDirectory   Discardable cache files, not backed up
 *
 * Encryption use iOS standard CommonCrypto (256-bit AES encryption)
 */

/**
 * @abstract Method to save an NSCoding-compliant object (NSDictionary, NSArray, etc) to the file system
 *
 * @param saveObject    object to be saved
 * @param filename      Name of file to save
 * @param directory     User directory to save file to (default NSDocumentDirectory)
 * @param encrpytionKey Key to encrypt file with (nil = don't use encryption)
 *
 * @return BOOL (YES = saved, NO = error)
 *
 **/

+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename;
+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename withEncryptionKey:(NSString *)encrpytionKey;
+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename inDirectory:(NSSearchPathDirectory)directory withEncryptionKey:(NSString *)encrpytionKey;


/**
 * @abstract Method to load an NSCoding-compliant object (NSDictionary, NSArray, etc) from the file system
 *
 * @param filename      Name of file to load
 * @param directory     User directory to load file from (default = NSDocumentDirectory)
 * @param decryptionKey Key to decrypt file with (nil = decryption not needed)
 *
 * @return id (pointer to object, nil = error)
 *
 **/

+ (id)objectFromFilename:(NSString *)filename;
+ (id)objectFromFilename:(NSString *)filename withDecryptionKey:(NSString *)decryptionKey;
+ (id)objectFromFilename:(NSString *)filename inDirectory:(NSSearchPathDirectory)directory withDecryptionKey:(NSString *)decryptionKey;

@end
