//
//  FaceDetectResult.h
//  AcessoBio
//
//  Created by  Matheus Domingos on 16/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceDetectResult : NSObject

@property (readwrite) int FaceResult;
@property (assign, nonatomic) BOOL Similars;
@property (readwrite) double SimilarScore;
@end

NS_ASSUME_NONNULL_END
