//
//  MKSoundCoordinatedAnimationView.h
//  
// Copyright 2010-2011 Michael F. Kamprath
// michael@claireware.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <AVFoundation/AVFoundation.h>
#import "MKSoundCoordinatedAnimationView.h"

@implementation MKSoundCoordinatedAnimationView
@dynamic config;
@dynamic stillImage;
@dynamic naturalCycleDuration;
@dynamic cycleDuration;
@dynamic isAnimating;
@dynamic silenced;
@dynamic completionInvocation;


- (id)initWithFrame:(CGRect)inFrame 
{
    self = [super initWithFrame:inFrame];
    if (self) 
	{
		
		CGPoint centerPt = CGPointMake( self.frame.size.width/2.0, self.frame.size.height/2.0 );
		CGRect boundsRct = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
		
		_animationLayer = [[MKSoundCoordinatedAnimationLayer alloc] init];
		_animationLayer.bounds = boundsRct;
		_animationLayer.position = centerPt;
		
		[self.layer addSublayer:_animationLayer];
		
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if (self)
	{
 		CGPoint centerPt = CGPointMake( self.frame.size.width/2.0, self.frame.size.height/2.0 );
		CGRect boundsRct = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
		
		_animationLayer = [[MKSoundCoordinatedAnimationLayer alloc] init];
		_animationLayer.bounds = boundsRct;
		_animationLayer.position = centerPt;
		
		[self.layer addSublayer:_animationLayer];
	}
	return self;
}


- (void)dealloc 
{
	[_animationLayer removeFromSuperlayer];
	[_animationLayer release];
	
    [super dealloc];
}



- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	
	[self.layer setNeedsDisplay];
}

#pragma mark - Properties

- (NSDictionary*)config;
{
	return _animationLayer.config;
}
-(void)setConfig:(NSDictionary *)inConfig
{
	_animationLayer.config = inConfig;
}

- (UIImage*)stillImage
{
	return _animationLayer.stillImage;
}	   
-(void)setStillImage:(UIImage *)inImage
{
	_animationLayer.stillImage = inImage;
	
}

- (NSTimeInterval)cycleDuration
{
	return _animationLayer.cycleDuration;
}
- (void)setCycleDuration:(NSTimeInterval)inCycleDuration
{
	_animationLayer.cycleDuration = inCycleDuration;
}

- (NSTimeInterval)naturalCycleDuration
{
	return _animationLayer.naturalCycleDuration;
}

- (BOOL)isAnimating
{
	return	_animationLayer.isAnimating;
}

- (BOOL)isSilenced
{
	return _animationLayer.isSilenced;
}

- (void)setSilenced:(BOOL)inBool
{
	_animationLayer.silenced = inBool;
}

-(NSInvocation*)completionInvocation {
    return _animationLayer.completionInvocation;
}

-(void)setCompletionInvocation:(NSInvocation *)inCompletionInvocation {
    [_animationLayer setCompletionInvocation:inCompletionInvocation];
}

#pragma mark - Public Methods

-(void)startAnimating {
	[_animationLayer startAnimating];
}

// starts the animation sequence looping for a specific number of counts. 
// Passing 0 cycle count value has no effect. If called while animating, will set the 
// remining loop counter to passed value after current loop finishes. 
- (void)animateWithCycleCount:(NSUInteger)inCycleCount withCompletionInvocation:(NSInvocation*)inInvocation finalStaticImage:(UIImage*)inFinalStaticImage {
    [_animationLayer animateWithCycleCount:inCycleCount withCompletionInvocation:inInvocation finalStaticImage:inFinalStaticImage];
	
}


- (void)animateOnceWithCompletionInvocation:(NSInvocation*)inInvocation {
	[_animationLayer animateOnceWithCompletionInvocation:inInvocation];
}

- (void)animateOnceWithCompletionInvocation:(NSInvocation*)inInvocation finalStaticImage:(UIImage*)inFinalStaticImage {
    [_animationLayer animateOnceWithCompletionInvocation:inInvocation finalStaticImage:inFinalStaticImage];
}



- (void)animateRepeatedlyForDuration:(NSTimeInterval)inRepeatDuration withCompletionInvocation:(NSInvocation*)inInvocation finalStaticImage:(UIImage*)inFinalStaticImage {
    [_animationLayer animateRepeatedlyForDuration:inRepeatDuration withCompletionInvocation:inInvocation finalStaticImage:inFinalStaticImage];
}


// Stops the animation, either immediately or after the end of the current loop.
-(void)stopAnimatingImmeditely:(BOOL)inImmediately
{
	[_animationLayer stopAnimatingImmeditely:inImmediately];
	
}

#pragma mark - Class Methods
//
// converts a "property list" configuration dictionary to the format expected by the config property of an instance.
// The "property list" verison of the configuraiton does not contain sound or image objects, but in stead filenames.
// This method will generate a config dictionary containin the sound and image objects based. Useful for configuring
// an animation with a plist file.
// The property list format is:
//
// key = NSNumber containing a float value indicating he number of seconds since start this item should be applied
// value = a dictionary containing one or more of the following key/value pairs
//					key			| value
//				----------------+------------------------------------------------------------
//				 "soundFile"	| the file name a sound file, including extension (NSString)
//				 "imageFile"	| the file name of an image, inclding extension (NSString)
//
+(NSDictionary*)configFromPropertList:(NSDictionary*)inPropertyList
{
	
	return [MKSoundCoordinatedAnimationLayer configFromPropertList:inPropertyList];
}

+(NSDictionary*)configFromPropertList:(NSDictionary*)inPropertyList usingObjectFactory:(id <MKSoundCoordinatedAnimationObjectFactory>)inObjectFactory
{
	return [MKSoundCoordinatedAnimationLayer configFromPropertList:inPropertyList usingObjectFactory:inObjectFactory];
	
}


//
// UIImage objects can shared between multiple instnaces of a given animation, but AVAudioPlayer objects
// cannot because each animation instance may have a different play state. This method will "copy" a config
// dictionary by producing an (autoreleased) copy of it where the UIImage objects are shared by the 
// AVAudioPlayer objects are distinct copies. 
+(NSDictionary*)copyConfig:(NSDictionary*)inConfig
{
	return [MKSoundCoordinatedAnimationLayer copyConfig:inConfig];
	
}

@end
