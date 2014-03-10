//
//  AssetMngr.h
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetGroupData.h"
#import "SectionData.h"

@protocol AssetLibraryDelegate

- (void)updateView;

@end


@interface AssetMngr : NSObject

@property (nonatomic, retain) ALAssetsLibrary* m_assetLibrary;
@property (nonatomic, retain) NSMutableArray* m_assetsGroups;   /* AssetGroupData array */


@property id < AssetLibraryDelegate > delegate;

/*
 Create the instance by singleton pattern.
*/
+ (AssetMngr*)create;

/*
 Initialize the ALAssetsLibrary.
*/
- (void)initializeALAssetLibrary;

/*
 Build asset datas.
*/
 - (void)buildAssetData;

/*
 Get thumbnail
*/
- (UIImage*)getThumbnail:(NSURL*)url;

/*
 Get the name of the groups. return NSString array.
*/
- (NSArray*)GetGroupNames;

/*
 Enumulate the urls associated with the images.
 */
- (NSArray*)enumeImagesWithGroupName:(NSString*)groupName;

/*
 Build the url array for date.
*/
- (NSArray*)buildSectionsForDateWithGroupName:(NSString*)groupName;


@end
