//
//  WZMPlayer.m
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WZMPlayerItem.h"
#import "WZMMacro.h"
#import "WZMLogPrinter.h"

@interface WZMPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVPlayer *player;     //音频播放器
@property (nonatomic, assign) CGFloat playProgress; //播放进度
@property (nonatomic, assign) CGFloat loadProgress; //缓冲进度
@property (nonatomic, assign) CGFloat duration;     //音频总时长
@property (nonatomic, assign) CGFloat currentTime;  //当前播放时间
@property (nonatomic, assign) id playTimeObserver;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskId;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, getter=isLocking) BOOL locking;
@property (nonatomic, assign, getter=isRelated) BOOL related;

@end

@implementation WZMPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.volume = 1.0;
        self.playing = NO;
        self.locking = NO;
        self.related = NO;
        self.background = NO;
        self.allowPlay = YES;
        self.trackingRunLoop = YES;
        
        //监听音频播放结束
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        //监听程序进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        //监听程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
        
        //监听音频播放中断
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
        
        //设置并激活后台播放
        AVAudioSession *session=[AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
        
        //允许应用程序接收远程控制
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

- (void)resetConfig:(BOOL)clear {
    self.duration = 0;
    self.currentTime = 0;
    self.playProgress = 0;
    self.loadProgress = 0;
    [self seekToTime:0.0];
    if (clear) {
        [self relatePlayer:nil];
    }
}

//url：文件路径或文件网络地址
- (void)playWithURL:(NSURL *)url {
    if (self.isAllowPlay == NO) return;
    [self stop];
    //加载视频资源的类
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    //AVURLAsset 通过tracks关键字会将资源异步加载在程序的一个临时内存缓冲区中
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        //能够得到资源被加载的状态
        NSError *error;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        //如果资源加载完成,开始进行播放
        if (status == AVKeyValueStatusLoaded) {
            //将加载好的资源放入AVPlayerItem 中，item中包含视频资源数据,视频资源时长、当前播放的时间点等信息
            self.locking = NO;
            WZMPlayerItem *item = [[WZMPlayerItem alloc] initWithAsset:asset];
            item.observer = self;
            
            if (_player) {
                [_player removeTimeObserver:_playTimeObserver];
                [_player replaceCurrentItemWithPlayerItem:item];
            }
            else {
                _player = [[AVPlayer alloc] initWithPlayerItem:item];
            }
            _player.volume = self.volume;
            
            //观察播放状态
            [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            //观察缓冲进度
            [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            //缓冲区空了，需要等待数据
            [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            // 缓冲区有足够数据可以播放了
            [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
            //需要时时显示播放的进度
            //根据播放的帧数、速率，进行时间的异步(在子线程中完成)获取
            @wzm_weakify(self);
            _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 10.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
                @wzm_strongify(self);
                while (self.isTrackingRunLoop) {
                    if ([NSRunLoop mainRunLoop].currentMode == UITrackingRunLoopMode) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self loop_pause];
                        });
                        [NSThread sleepForTimeInterval:0.5];
                        continue;
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isLocking == NO) {
                                [self play];
                            }
                        });
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //获取当前播放时间
                    self.currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
                    if (self.duration == 0) {
                        NSString *dur = [NSString stringWithFormat:@"%@",@(CMTimeGetSeconds(self.player.currentItem.duration))];
                        self.duration = [dur doubleValue];
                        [self wzm_loadSuccess];
                        [self wzm_beginPlaying];
                    }
                    if (self.duration > 0) {
                        float pro = self.currentTime*1.0/self.duration;
                        if (pro >= 0.0 && pro <= 1.0) {
                            self.playProgress = pro;
                        }
                        [self wzm_playing];
                    }
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadFailed:@"未识别的音频文件"];
            });
        }
    }];
}

//监听播放开始
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (self.isAllowPlay == NO) return;
    if (self.isBackground == NO && self.isLocking) return;
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (item.status == AVPlayerStatusReadyToPlay) {
            [self play];
        }
        else if (item.status == AVPlayerStatusFailed) {
            [self loadFailed:@"未识别的音频文件"];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if (self.duration > 0) {
            NSInteger timeInterval = [self availableDuration];
            float pro = timeInterval*1.0/self.duration;
            if (pro >= 0.0 && pro <= 1.0) {
                self.loadProgress = pro;
                [self wzm_loadProgress];
            }
        }
    }
}

- (void)relatePlayer:(AVPlayer *)myPlayer {
    if (self.playerView) {
        if (myPlayer) {
            if (self.isRelated) return;
            self.related = YES;
        }
        else {
            if (self.isRelated == NO) return;
            self.related = NO;
        }
        AVPlayerLayer *playerLayer=(AVPlayerLayer *)self.playerView.layer;
        [playerLayer setPlayer:myPlayer];
    }
}

//锁屏界面的用户交互
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        if (receivedEvent.subtype == UIEventSubtypeRemoteControlPlay) {//播放
            [self play];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlPause) {//暂停
            [self pause];
        }
    }
}

//程序进入前台
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isBackground) {
        [self play];//恢复播放
    }
}

//监听程序退到后台
- (void)applicationWillResignActive:(NSNotification *)notification {
    self.locking = YES;
    if (self.isBackground) {
        //注册后台播放,如果需要后台播放网络歌曲，必须注册taskId
        _bgTaskId = [self backgroundPlayerID:_bgTaskId];
    }
    else {
        [self pause];
    }
}

//监听音频播放中断
- (void)movieInterruption:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSInteger type = [[dic valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //收到中断，停止音频播放
        [self pause];
    }
    else {
        if (self.isBackground) {
            //系统中断结束，恢复音频播放
            [self play];
        }
    }
}

//监听音频播放完成
- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self wzm_endPlaying];
}

#pragma mark - private method
//播放状态
- (void)wzm_loadSuccess {
    if (self.duration > 0) {
        if ([self.delegate respondsToSelector:@selector(playerLoadSuccess:)]) {
            [self.delegate playerLoadSuccess:self];
        }
    }
}

- (void)loadFailed:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(playerLoadFailed:error:)]) {
        [self.delegate playerLoadFailed:self error:error];
    }
}

- (void)wzm_loadProgress {
    if ([self.delegate respondsToSelector:@selector(playerLoadProgress:)]) {
        [self.delegate playerLoadProgress:self];
    }
}

- (void)wzm_beginPlaying {
    if (self.duration > 0) {
        self.playing = YES;
        [self wzm_changeStatus];
        if ([self.delegate respondsToSelector:@selector(playerBeginPlaying:)]) {
            [self.delegate playerBeginPlaying:self];
        }
    }
}

- (void)wzm_playing {
    if ([self.delegate respondsToSelector:@selector(playerPlaying:)]) {
        [self.delegate playerPlaying:self];
    }
}

- (void)wzm_endPlaying {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(playerEndPlaying:)]) {
        [self.delegate playerEndPlaying:self];
    }
}

- (void)wzm_changeStatus {
    if ([self.delegate respondsToSelector:@selector(playerChangeStatus:)]) {
        [self.delegate playerChangeStatus:self];
    }
}

- (NSInteger)availableDuration {//计算缓冲时间
    NSArray *loadedTimeRanges = [_player.currentItem loadedTimeRanges];
    CMTimeRange range = [loadedTimeRanges.firstObject CMTimeRangeValue];
    NSInteger start = CMTimeGetSeconds(range.start);
    NSInteger duration = CMTimeGetSeconds(range.duration);
    return (start + duration);
}

- (void)play {
    if (self.isAllowPlay == NO) return;
    self.locking = NO;
    if (self.isPlaying) return;
    if (_player) {
        [self relatePlayer:_player];
        [_player play];
        self.playing = YES;
        [self wzm_changeStatus];
    }
}

- (void)pause {
    self.locking = YES;
    [self loop_pause];
}

- (void)stop {
    [self pause];
    [self resetConfig:YES];
}

- (void)loop_pause {
    if (self.isPlaying == NO) return;
    if (_player) {
        [_player pause];
        self.playing = NO;
        [self wzm_changeStatus];
    }
}

//注册taskId
- (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId {
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}

- (void)seekToTime:(NSInteger)time {
    if (self.duration <= 0) return;
    if (self.currentTime == time) return;
    if (time >= 0 && time < self.duration) {
        self.currentTime = time;
        self.playProgress = self.currentTime*1.0/self.duration;
        CMTime dur = self.player.currentItem.duration;
        [self.player seekToTime:CMTimeMultiplyByFloat64(dur, self.playProgress) toleranceBefore:CMTimeMake(1, 10) toleranceAfter:CMTimeMake(1, 10)];
    }
}

- (void)seekToProgress:(CGFloat)progress {
    if (self.duration <= 0) return;
    if (self.playProgress == progress) return;
    if (progress >= 0 && progress <= 1) {
        NSInteger time = self.duration*progress;
        self.currentTime = time;
        self.playProgress = progress;
        CMTime dur = self.player.currentItem.duration;
        [self.player seekToTime:CMTimeMultiplyByFloat64(dur, progress) toleranceBefore:CMTimeMake(1, 10) toleranceAfter:CMTimeMake(1, 10)];
    }
}

//移除相关监听
- (void)dealloc {
    WZMLog(@"%@释放了",NSStringFromClass(self.class));
    [_player removeTimeObserver:_playTimeObserver];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
