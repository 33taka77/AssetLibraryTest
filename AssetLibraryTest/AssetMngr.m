//
//  AssetMngr.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "AssetMngr.h"
#import <ImageIO/ImageIO.h>

@implementation AssetMngr

static AssetMngr* gAssetManager = nil;

@synthesize m_assetLibrary;
@synthesize m_assetsGroups;

+ (AssetMngr*)create
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gAssetManager = [[AssetMngr alloc] init];
    });
    return gAssetManager;
}

- (void)initializeALAssetLibrary
{
    self.m_assetLibrary = [[ALAssetsLibrary alloc] init];
    
}

- (void)buildAssetData
{
    void (^groupBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if( group != nil )
        {
            AssetGroupData* data = [[AssetGroupData alloc] init];
            data.m_assetGroup = group;
            data.m_assets = [[NSMutableArray alloc] init];
            [self searchPhotos:data];
            [self.m_assetsGroups addObject:data];
            NSLog(@"Group:%@ images:%lu",[group valueForProperty:ALAssetsGroupPropertyName], (unsigned long)data.m_assets.count );
            [self.delegate updateView];
        }
    };
    [self.m_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:groupBlock failureBlock:^(NSError *error) {
        NSLog(@"AssetLib error %@",error);
    }];
}

- (UIImage*)getThumbnail:(NSURL*)url
{
    ALAsset* asset = [self GetAssetFromArray:url];
    UIImage* image = [UIImage imageWithCGImage:[asset thumbnail]];
    return image;
}

- (NSArray*)GetGroupNames
{
    NSMutableArray* array = [[NSMutableArray alloc ] init];
    for( AssetGroupData* data in self.m_assetsGroups )
    {
        NSString* name = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyName];
        [array addObject:name];
    }
    NSArray* retArray = [[NSArray alloc] initWithArray:array];
    return retArray;
}

- (NSArray*)enumeImagesWithGroupName:(NSString*)groupName
{
    NSMutableArray* array = [[NSMutableArray alloc ] init];
    for( AssetGroupData* data in self.m_assetsGroups )
    {
        NSString* name = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyName];
        if( [name isEqualToString:groupName] )
        {
            for( ALAsset* asset in data.m_assets )
            {
                NSURL* url = [asset valueForProperty:ALAssetPropertyAssetURL];
                [array addObject:url];
            }
            break;
        }
    }
    NSArray* retArray = [[NSArray alloc] initWithArray:array];
    return retArray;
}

- (UIImage*)GetFullImage:(NSURL*)url
{
    ALAsset* asset = [self GetAssetFromArray:url];
    UIImage* image = [UIImage imageWithCGImage:[[asset defaultRepresentation]  fullScreenImage]];
    return image;
}

- (NSArray*)buildSectionsForDateWithGroupName:(NSString*)groupName
{
    NSMutableArray* array = [self getAssetsByGroupName:groupName];
    NSMutableArray* retArray;
    for( ALAsset* asset in array )
    {
        @autoreleasepool {
            NSDictionary* dict = [[asset defaultRepresentation] metadata];
            NSDictionary* exifData = [self getPhotoExifMetaData:dict];
            NSString* date = exifData[@"DateTimeOriginal"];
            retArray = [self rebuildForDate:date asset:asset];
            dict = nil;
            exifData = nil;
            date = nil;
        }
    }
    return retArray;
}

//---------- local functions -----------------------

- (void)searchPhotos:(AssetGroupData*)data
{
        void (^photosBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset* asset, NSUInteger index, BOOL* stop){
        if( data.m_assets != nil )
        {
            if( ![data.m_assets containsObject:asset] )
            {
                if( [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] )
                {
                    [data.m_assets addObject:asset];
                }
            }
        }
    };
    [data.m_assetGroup enumerateAssetsUsingBlock:photosBlock];
}

- (ALAsset*)GetAssetFromArray:(NSURL*)url
{
    ALAsset* result = nil;
    for( AssetGroupData* assetGroupData in self.m_assetsGroups )
    {
        for( ALAsset* asset in assetGroupData.m_assets )
        {
            if( [[asset valueForProperty:ALAssetPropertyAssetURL] isEqual:url] )
            {
                result = asset;
                break;
            }
        }
        if( result != nil )
            break;
    }
    return result;
}

- (NSMutableArray*)getAssetsByGroupName:(NSString*)groupName
{
    NSMutableArray* array;
    for( AssetGroupData* data in self.m_assetsGroups )
    {
        NSString* name = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyName];
        if( [name isEqualToString:groupName] )
        {
            array = data.m_assets;
            break;
        }
    }
    return array;
}

- (NSDictionary *)getPhotoExifMetaData:(NSDictionary*)dict {
    //NSDictionary *metaData = [[asset defaultRepresentation] metadata];
    return [dict objectForKey:(NSString *)kCGImagePropertyExifDictionary];
}



- (NSMutableArray*)rebuildForDate:(NSString*)date asset:(ALAsset*)asset
{
    NSMutableArray* retArry = [[NSMutableArray alloc] init];

    NSArray* strs = [date componentsSeparatedByString:@" "];
    NSString* title = strs[0];
    NSURL* url = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    if( title == nil )
    {
        title = @"Unknown";
    }
    BOOL isNewItem = YES;
    for( SectionData* section in retArry )
    {
        if( [section.sectionTitle isEqual:title] )
        {
            [section.items addObject:url];
            isNewItem = NO;
            break;
        }
    }
    if( isNewItem == YES )
    {
        SectionData* newSection = [[SectionData alloc] initWithTitle:title];
        [newSection.items addObject:url];
        [retArry addObject:newSection];
    }
    //NSLog(@"title: %@ sub:%@",strs[0],strs[1]);
    strs = nil;
    title = nil;
    url = nil;
    return retArry;
}

@end
