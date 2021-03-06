
#import "PhotoView.h"
#import "API.h"

@implementation PhotoView {
}

@synthesize delegate;
@synthesize ProfileId;
@synthesize interactionType;
@synthesize index;
@synthesize proPicView;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithIndex:(int)i andData:(NSDictionary*)data {
    self = [super init];
    if (self !=nil) {
        //initialize
		
		index = i;
        int row = i/4;
        int col = i % 4;
        self.frame = CGRectMake(1.5*kPadding+col*(kThumbSide+kPadding), 1.5*kPadding+row*(kThumbSide+kPadding), kThumbSide, kThumbSide);
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
		
		self.ProfileId = [data objectForKey:@"IdUser"];
		self.interactionType = [data objectForKey:@"type"];
		
        //add the photo caption
		/*
		 UILabel* caption = [[UILabel alloc] initWithFrame:CGRectMake(0, kThumbSide-16, kThumbSide, 16)];
		 caption.backgroundColor = [UIColor blackColor];
		 caption.textColor = [UIColor whiteColor];
		 caption.textAlignment = UITextAlignmentCenter;
		 caption.font = [UIFont systemFontOfSize:12];
		 caption.text = [NSString stringWithFormat:@"@%@",[data objectForKey:@"username"]];
		 [self addSubview: caption];
		 */
		
		//add touch event
		[self addTarget:delegate action:@selector(didSelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
		
		//load the image
		API* api = [API sharedInstance];
		NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInt: [ProfileId intValue]] isThumb:YES];
		AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
			//create an image view, add it to the view
			proPicView = [[ProPicView alloc]initWithFrame:CGRectMake(0,0,kThumbSide,kThumbSide) Image:image filterType:interactionType];
            proPicView.contentMode = UIViewContentModeScaleAspectFit;
			[self addSubview: proPicView];
		}];
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
		[queue addOperation:imageOperation];
    }
    return self;
}

@end
