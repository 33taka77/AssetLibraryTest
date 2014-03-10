//
//  ViewController.m
//  AssetLibraryTest
//
//  Created by Aizawa Takashi on 2014/03/10.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "ViewController.h"
#import "AssetManager.h"
#import "AssetGroupData.h"

@interface ViewController () <AssetLibraryDelegate>

@property (nonatomic,retain) AssetManager* assetManager;
@property (nonatomic, retain) NSMutableArray* assetGroups;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)ButtonClicked:(id)sender;
@end

@implementation ViewController

- (void)updateItemDataItemURL:(NSURL*)url groupURL:(NSURL*)groupUrl
{
    BOOL newGroup = YES;
    for( AssetGroupData* group in self.assetGroups)
    {
        if( group.m_assetGroupURL == groupUrl )
        {
            [group.m_assets addObject:url];
            newGroup = NO;
            break;
        }
    }
    if( newGroup == YES )
    {
        AssetGroupData* newGroup = [[AssetGroupData alloc] init];
        newGroup.m_assetGroupURL = groupUrl;
        [newGroup.m_assets addObject:url];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.assetGroups = [[NSMutableArray alloc] init];
    
    self.assetManager = [AssetManager sharedAssetManager];
    [self.assetManager setAssetManagerModeIsHoldItemData:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ButtonClicked:(id)sender {
    AssetGroupData* data = self.assetGroups[2];
    NSURL* url = data.m_assets[0];
    UIImage* image = [self.assetManager getThumbnail:url];
    self.imageView.image = image;
}
@end
