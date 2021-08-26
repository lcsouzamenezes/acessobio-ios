//
//  ExifUtils.m
//  AcessoBio
//
//  Created by Matheus Domingos on 26/08/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "ExifUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation ExifUtils

- (void)addMetataDataEXIFToImage : (CMSampleBufferRef)imageSampleBuffer  {

    
    CFDictionaryRef metaDict = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
    
    CFMutableDictionaryRef mutable = CFDictionaryCreateMutableCopy(NULL, 0, metaDict);
    
    
    /*
     // Create formatted date
     NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
     NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
     [formatter setTimeZone:timeZone];
     [formatter setDateFormat:@"HH:mm:ss.SS"];
     
     // Create GPS Dictionary
     NSDictionary *gpsDict   = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:fabs(loc.coordinate.latitude)], kCGImagePropertyGPSLatitude
     , ((loc.coordinate.latitude >= 0) ? @"N" : @"S"), kCGImagePropertyGPSLatitudeRef
     , [NSNumber numberWithFloat:fabs(loc.coordinate.longitude)], kCGImagePropertyGPSLongitude
     , ((loc.coordinate.longitude >= 0) ? @"E" : @"W"), kCGImagePropertyGPSLongitudeRef
     , [formatter stringFromDate:[loc timestamp]], kCGImagePropertyGPSTimeStamp
     , [NSNumber numberWithFloat:fabs(loc.altitude)], kCGImagePropertyGPSAltitude
     , nil];
     
     // The gps info goes into the gps metadata part
     
     CFDictionarySetValue(mutable, kCGImagePropertyGPSDictionary, (__bridge void *)gpsDict);
     
     // Here just as an example im adding the attitude matrix in the exif comment metadata
     
     CMRotationMatrix m = att.rotationMatrix;
     GLKMatrix4 attMat = GLKMatrix4Make(m.m11, m.m12, m.m13, 0, m.m21, m.m22, m.m23, 0, m.m31, m.m32, m.m33, 0, 0, 0, 0, 1);
     */
    
    NSMutableDictionary *EXIFDictionary = (__bridge NSMutableDictionary*)CFDictionaryGetValue(mutable, kCGImagePropertyExifDictionary);
    
    [EXIFDictionary setValue:@"teste som" forKey:(NSString *)kCGImagePropertyExifUserComment];
    
    CFDictionarySetValue(mutable, kCGImagePropertyExifDictionary, (__bridge void *)EXIFDictionary);
    
    NSData *jpeg = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer] ;
    

    // -------
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    NSMutableData *dest_data = [NSMutableData data];
    
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) mutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImagesFolder"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    //    NSString *imageName = @"ImageName";
    
    NSString *fullPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", @"myOwnImage"]]; //add our image to the path
    
    [dest_data writeToFile:fullPath atomically:YES];
    

    //cleanup
    CFRelease(destination);
    CFRelease(source);
    
    NSLog(@"%@", [self getMetadataDictFromDestinationData:dest_data]);
    
    
}

- (NSDictionary *)getMetadataDictFromDestinationData : (NSData *)data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    NSDictionary* metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,nil));
    return metadata;
}

- (NSString *)getBase64FromData : (NSData *)data  {
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return base64;
}


@end
