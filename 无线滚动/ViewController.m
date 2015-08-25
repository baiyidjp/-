//
//  ViewController.m
//  无线滚动
//
//  Created by I Smile going on 15/8/15.
//  Copyright (c) 2015年 iOS_小董. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height
#define COUNT self.imageUrl.count

static long count = 0; //记录时钟动画调用次数

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;

//上一张图片

@property (nonatomic, strong) UIImageView* preImageView;
//下一张图片

@property (nonatomic, strong) UIImageView* nextImageView;
//当前图片

@property (nonatomic, strong) UIImageView* currentImageView;

//当前图片的索引
@property (nonatomic, assign) NSInteger index;

//计时器

@property (nonatomic, strong) CADisplayLink* timer;

//是否在滚动

@property(nonatomic,assign)BOOL isDraging;

//page页码

@property(nonatomic,strong)UIPageControl *pageControl;

//存放图片地址

@property(nonatomic,strong)NSArray *imageUrl;

@end

@implementation ViewController

- (NSArray *)imageUrl
{
    if (!_imageUrl) {
        
        _imageUrl = [[NSArray alloc]init];
        
        _imageUrl = @[@"http://b101.photo.store.qq.com/psb?/V12dZnwM1r5vq1/x4BAXi3zSru3w6nHNvu01e.Gs3zSZgMpY*S6*fTsrKk!/b/YRoyRDyKFAAAYuR9OTxbFAAA&bo=ngJ4AQAAAAABBMY!&rf=viewer_4",
                     @"http://b96.photo.store.qq.com/psb?/V12dZnwM1r5vq1/GkOucNt9yZJgb5SUQTlytv3xOQuGvYrxtXwmypnFWk8!/b/Yf4dQDkBUAAAYuKIOzkiUAAA&bo=ngJ4AQAAAAABAMI!&rf=viewer_4",
                     @"http://b93.photo.store.qq.com/psb?/V12dZnwM1r5vq1/3S2aMvNif1YrXAm.bnhLGblHQMTtLYO*uZGZu9FsV1M!/b/YftdeTeykwAAYhFEczfYkgAA&bo=ngJ4AQAAAAABAMI!&rf=viewer_4",
                     @"http://b101.photo.store.qq.com/psb?/V12dZnwM1r5vq1/iPNlzMLKjZ5txy4CSpPDWPaDCHM1**tK2UrleGv2NjI!/b/YXscPjz9FQAAYqdwNjwIFgAA&bo=ngJ4AQAAAAABAMI!&rf=viewer_4"];
    }
    
    return _imageUrl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];

    scrollView.contentSize = CGSizeMake(3 * WIDTH, 0);

    scrollView.pagingEnabled = YES;

    scrollView.showsHorizontalScrollIndicator = NO;

    scrollView.showsVerticalScrollIndicator = NO;

    scrollView.contentOffset = CGPointMake(WIDTH, 0);

    scrollView.delegate = self;

    scrollView.bounces = NO;

    self.scrollView = scrollView;

    [self.view addSubview:scrollView];
    
    //默认页码是 0

    self.index = 0;

    [self addImageView];

    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];

    //加入runlop

    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    UIPageControl *pageControl = [[UIPageControl alloc]init];
    
    //页码
    
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
    pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    
    pageControl.numberOfPages = COUNT;
    
    pageControl.frame = CGRectMake(0, HEIGHT - 35, WIDTH, 35);
    
    self.pageControl = pageControl;
    
    [self.view addSubview:pageControl];
    
}

- (void)update:(CADisplayLink*)timer
{
    count++;
    
    if (count % 120 != 0 || self.isDraging) {
        
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(2 * WIDTH, 0) animated:YES];
    
    NSLog(@"%ld",count);
}

//添加图片控件

- (void)addImageView
{
    //上一张

    UIImageView* preImageView = [[UIImageView alloc] init];

    self.preImageView = preImageView;

    preImageView.frame = CGRectMake(0, HEIGHT/4, WIDTH, HEIGHT/2);

    [self.scrollView addSubview:preImageView];

    //下一张
    UIImageView* nextImageView = [[UIImageView alloc] init];

    self.nextImageView = nextImageView;

    nextImageView.frame = CGRectMake(2 * WIDTH, HEIGHT/4, WIDTH, HEIGHT/2);

    [self.scrollView addSubview:nextImageView];


    //当前

    UIImageView* currentImageView = [[UIImageView alloc] init];

    self.currentImageView = currentImageView;

    currentImageView.frame = CGRectMake(WIDTH, HEIGHT/4, WIDTH, HEIGHT/2);

    [currentImageView sd_setImageWithURL:self.imageUrl[self.index] ];
    //    currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //placeholderImage:[UIImage imageNamed:@"无线滚动图片_01"]

    [self.scrollView addSubview:currentImageView];

}

//开始

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isDraging = YES;
    
}

//结束

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isDraging = NO;
    
    count = 0;
}
//滚动代理

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{

    if (self.preImageView.image == nil || self.nextImageView.image == nil) {

        [self.preImageView sd_setImageWithURL:self.imageUrl[self.index == 0 ? COUNT - 1 : self.index - 1] ];

        [self.nextImageView sd_setImageWithURL:self.imageUrl[self.index == COUNT - 1? 0 : self.index + 1] ];
    }

    //判断是向左还是向右

    if (scrollView.contentOffset.x == 2 * WIDTH) {
        //向右

        if (self.index == COUNT - 1) {

            self.index = 0;
        }
        else {
            self.index += 1;
        }

        self.currentImageView.image = self.nextImageView.image;

        self.nextImageView.image = nil;

        scrollView.contentOffset = CGPointMake(WIDTH, 0);
    }

    if (scrollView.contentOffset.x == 0) {

        //向左

        if (self.index == 0) {

            self.index = COUNT - 1;
        }
        else {
            self.index -= 1;
        }

        self.currentImageView.image = self.preImageView.image;

        self.preImageView.image = nil;

        scrollView.contentOffset = CGPointMake(WIDTH, 0);
    }
    
    self.pageControl.currentPage = self.index ;

//    NSLog(@"%zd", self.index);
}



@end
