//
//  AssetGroupData.h
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetGroupData : NSObject
@property (nonatomic, retain) NSURL* m_assetGroupURL;
@property (nonatomic, retain) ALAssetsGroup* m_assetGroup;
@property (nonatomic, retain) NSMutableArray* m_assets; /* ALAsset array */
@end
