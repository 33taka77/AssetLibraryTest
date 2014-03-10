//
//  AssetManager.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/10.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "AssetManager.h"
#import "AssetGroupData.h"

@interface AssetManager ()
@property (nonatomic, retain) ALAssetsLibrary* m_assetLibrary;
@property (nonatomic, retain) NSMutableArray* m_assetsGroups;   /* AssetGroupData array */
@property BOOL m_isHoldItemData;
@end


@implementation AssetManager

static AssetManager* g_assetManager = nil;

+ (AssetManager*)sharedAssetManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_assetManager = [[AssetManager alloc] init];
        g_assetManager.m_assetLibrary = [[ALAssetsLibrary alloc] init];
    });
    return g_assetManager;
}

- (void)setAssetManagerModeIsHoldItemData:(BOOL)isHold
{
    self.m_isHoldItemData = isHold;
}

- (void)enumeAssetItems
{
    void (^groupBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        @autoreleasepool {
            if( group != nil )
            {
                AssetGroupData* data = [[AssetGroupData alloc] init];
                data.m_assetGroup = group;
                if( self.m_isHoldItemData )
                {
                    data.m_assets = [[NSMutableArray alloc] init];
                }else{
                    data.m_assets = nil;
                }
                [self enumAssets:data];
                [self.m_assetsGroups addObject:data];
                NSLog(@"Group:%@ images:%lu",[group valueForProperty:ALAssetsGroupPropertyName], (unsigned long)data.m_assets.count );
                NSURL* groupUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
                [self.delegate updateGroupDataGroupURL:groupUrl];
            }
        }
    };
    [self.m_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:groupBlock failureBlock:^(NSError *error) {
        NSLog(@"AssetLib error %@",error);
    }];
}

- (void)getAssetByURL:(NSURL*)url selector:(SEL)foundAsset withObject:(id)obj
{
    void (^getAssetBlock)(ALAsset*) = ^(ALAsset* asset){
        [self performSelector: foundAsset withObject:(id)asset afterDelay:0.0f];
    };
    
    void (^failBlock)(NSError*) = ^(NSError* error){
        NSLog(@"exception in accessing assets by url. %@", error);
    };
    
    [self.m_assetLibrary assetForURL:url resultBlock:getAssetBlock failureBlock:failBlock];
}

- (void)foundAsset:(ALAsset*)asset
{
    
}

- (ALAsset*)getAssetByURL:(NSURL*)url
{
    __block ALAsset* retAsset = nil;
    void (^getAssetBlock)(ALAsset*) = ^(ALAsset* asset){
        retAsset = asset;
    };
    
    void (^failBlock)(NSError*) = ^(NSError* error){
        NSLog(@"exception in accessing assets by url. %@", error);
    };
    
    [self.m_assetLibrary assetForURL:url resultBlock:getAssetBlock failureBlock:failBlock];
    return retAsset;
}

- (UIImage*)getThumbnail:(NSURL*)url
{
    ALAsset* asset = [self getAssetByURL:url];
    UIImage* image = [UIImage imageWithCGImage:[asset thumbnail]];
    return image;
}

- (void)enumAssets:(AssetGroupData*)groupData
{
    void (^photosBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset* asset, NSUInteger index, BOOL* stop){
        if( ![groupData.m_assets  containsObject:asset] )
        {
            if( [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] )
            {
                if( self.m_isHoldItemData )
                {
                    [groupData.m_assets  addObject:asset];
                }
                NSURL* url = [asset valueForProperty:ALAssetPropertyAssetURL];
                NSURL* groupUrl = [groupData valueForKey:ALAssetsGroupPropertyURL];
                [self.delegate updateItemDataItemURL:url groupURL:groupUrl];
            }
        }
    };
    [groupData.m_assetGroup enumerateAssetsUsingBlock:photosBlock];
}


@end
