//
//  JTBEncryptedArchiver.m
//  Archiver
//
//  Created by Jonathan Backer on 1/20/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

#import "JTBEncryptedArchiver.h"
#import "NSData+AES.h"

@interface JTBEncryptedArchiver ()

//@property (nonatomic, strong) NSKeyedArchiver* archiver;
//@property (nonatomic, strong) NSKeyedUnarchiver* unarchiver;
//@property (nonatomic, strong) NSMutableData* unencryptedData;

@end


@implementation JTBEncryptedArchiver

#pragma mark - Save methods

+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename {
    return [[self class] saveObject:object toFilename:filename inDirectory:NSDocumentDirectory withEncryptionKey:nil];
}

+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename withEncryptionKey:(NSString *)encrpytionKey {
    return [[self class] saveObject:object toFilename:filename inDirectory:NSDocumentDirectory withEncryptionKey:encrpytionKey];
}

+ (BOOL)saveObject:(id)object toFilename:(NSString *)filename inDirectory:(NSSearchPathDirectory)directory withEncryptionKey:(NSString *)encrpytionKey {
    BOOL saved = NO;
    
    // check for empty input parameters
    if (object != nil && filename != nil && filename.length > 0) {
        // covert root object to NSData
        NSData* binaryData = [NSKeyedArchiver archivedDataWithRootObject:object];
        NSData* encryptedData = nil;
        
        // do we have an encryption key?
        if (encrpytionKey != nil && encrpytionKey.length > 0) {
            // yes, encrypt NSData
            encryptedData = [binaryData encryptWithString:encrpytionKey];
            
        } else {
            // no, store NSData raw
            encryptedData = binaryData;
            
        }
        
        // get path for directory type
        NSURL* directoryPath = [[self class] pathForDirectoryType:directory];
        
        // is the directory path valid?
        if (directoryPath != nil) {
            // yes, add filename to directory path
            NSURL* fullPath = [NSURL URLWithString:filename relativeToURL:directoryPath];
            
            // save data to path
            saved = [[self class] saveData:encryptedData toPath:fullPath];
            
        } else {
            DebugLog(@"Error: Invalid NSSearchPathDirectory: %i", directory);
        }
        
    } else {
        DebugLog(@"Error: Missing object or filename");
    }
    
    return saved;
}

#pragma mark - Load methods

+ (id)objectFromFilename:(NSString *)filename {
    return [[self class] objectFromFilename:filename inDirectory:NSDocumentDirectory withDecryptionKey:nil];
}

+ (id)objectFromFilename:(NSString *)filename withDecryptionKey:(NSString *)decryptionKey {
    return [[self class] objectFromFilename:filename inDirectory:NSDocumentDirectory withDecryptionKey:decryptionKey];
}

+ (id)objectFromFilename:(NSString *)filename inDirectory:(NSSearchPathDirectory)directory withDecryptionKey:(NSString *)decryptionKey {
    NSData* data = nil;
    
    // check for empty input parameters
    if (filename != nil && filename.length > 0) {
        // get path for directory type
        NSURL* directoryPath = [[self class] pathForDirectoryType:directory];

        // is the directory path valid?
        if (directoryPath != nil) {
            // yes, add filename to directory path
            NSURL* fullPath = [NSURL URLWithString:filename relativeToURL:directoryPath];
            
            // load data from path
            NSData* rawData = [[self class] loadDataFromPath:fullPath];
            if (rawData != nil) {
                NSData* decryptedData = nil;
                
                // do we have an decryption key?
                if (decryptionKey != nil && decryptionKey.length > 0) {
                    // yes, decrypt NSData
                    @try {
                        decryptedData = [rawData decryptWithString:decryptionKey];
                    }
                    @catch (NSException *exception) {
                        // decryption key is incorrect or not needed
                        decryptedData = nil;
                        DebugLog(@"Error decrypting file: %@", filename);
                    }
                } else {
                    // no, use NSData raw
                    decryptedData = rawData;
                }
                
                if (decryptedData != nil) {
                    // convert NSData to rootObject
                    @try {
                        data = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                    }
                    @catch (NSException *exception) {
                        // decryptedData is not a recognized object
                        data = nil;
                        DebugLog(@"Error unarchiving object from file: %@", filename);
                    }
                }
            }
        }
        
    } else {
        DebugLog(@"Error: Missing filename");
    }
    
    return data;
}

#pragma mark - Load/Save to Disk methods

+ (BOOL)saveData:(NSData *)data toPath:(NSURL *)path {
    BOOL saved = NO;
    
    // atomic = write to disk as temp, verify write, rename and overwrite old file
    // complete = file is encrypted by system when device is locked (this is on top of any encryption set in the code by this class)
    NSError* writeError = nil;
    BOOL success = [data writeToURL:path options:(NSDataWritingAtomic | NSDataWritingFileProtectionComplete) error:&writeError];
    
    if (success) {
        // success
        saved = YES;
        DebugLog(@"Wrote: %@", path);
        
    } else if (writeError != nil) {
        // failure
        DebugLog(@"Error writing %@: %@", path, writeError);
        
    } else {
        // failure
        DebugLog(@"Error writing %@: Unknown", path);
        
    }
    
    return saved;
}

+ (NSData *)loadDataFromPath:(NSURL *)path {
    NSData* retVal = nil;
    
    if (path != nil) {
        NSError* readError = nil;
        // uncached = do not cache anywhere else on system (this improves performance of files only read once)
        NSData* readData = [NSData dataWithContentsOfURL:path options:NSDataReadingUncached error:&readError];
        
        if (readData != nil) {
            // success
            retVal = readData;
            DebugLog(@"Read: %@", path);
            
        } else if (readError != nil) {
            // failure
            DebugLog(@"Error reading %@: %@", path, readError);

        } else {
            // failure
            DebugLog(@"Error reading %@: Unknown", path);
            
        }
    }
    
    return retVal;
}

#pragma mark - User Directory methods

+ (NSURL *)pathForDirectoryType:(NSSearchPathDirectory)directory {
    NSURL* retVal = nil;
    
    // get shared fileManager singleton
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    
    // get possible paths of given Directory
    NSArray* possiblePaths = [sharedFileManager URLsForDirectory:directory inDomains:NSUserDomainMask];
    
    // do we have at least one URL?
    if (possiblePaths != nil && possiblePaths.count > 0) {
        // yes, return first URL
        retVal = [possiblePaths objectAtIndex:0];
    }
    
    return retVal;
}

@end
