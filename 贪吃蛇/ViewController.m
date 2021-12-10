//
//  ViewController.m
//  贪吃蛇
//
//  Created by 蒋雪姣 on 15/11/25.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#define up 1
#define left 2
#define down 3
#define right 4

#import "ViewController.h"

@interface ViewController ()
{
    CGFloat _viewWidth;
    NSMutableArray *_snake;
    NSMutableArray *_wall;
    CGRect _lastFrame;
    NSTimer *_timer;
    int _direction;
    int _score;
    float _time;
    UILabel *_label;
    UIView *_food;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _snake = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    _viewWidth = [UIScreen mainScreen].bounds.size.width;
    [self createUI];
    
}
-(void)createUI
{
    //添加蛇的画布
    int width = (int)(_viewWidth-20)/10*10;
    CGFloat btnWidth = 60;
    UIView *gameScreen = [[UIView alloc] initWithFrame:CGRectMake(10, 20, width, width)];
    gameScreen.backgroundColor = [UIColor lightGrayColor];
    gameScreen.tag = 1000;
    gameScreen.clipsToBounds = YES;
    [self.view addSubview:gameScreen];
    //创建开始按钮
   UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
   [startButton setTitle:@"开始" forState:UIControlStateNormal];
   startButton.frame = CGRectMake(_viewWidth / 2 - 60, _viewWidth, 50, 40);
   [startButton addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:startButton];
   //创建暂停按钮
   UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
   [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
   pauseButton.frame = CGRectMake(_viewWidth / 2 + 10, _viewWidth, 50, 40);
   [pauseButton addTarget:self action:@selector(pauseGame:) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:pauseButton];
    //创建向上按钮
    UIImage *upImage = [UIImage imageNamed:@"上.png"];
    UIImage *updImage = [UIImage imageNamed:@"上1.png"];
    UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    upButton.frame = CGRectMake((_viewWidth - btnWidth) / 2.0, _viewWidth+50, btnWidth, btnWidth);
    [upButton setImage:upImage forState:UIControlStateNormal];
    [upButton setImage:updImage forState:UIControlStateHighlighted];
    upButton.tag = 1;
    [upButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upButton];
    //创建向左按钮
    UIImage *leftImage = [UIImage imageNamed:@"左.png"];
    UIImage *leftdImage = [UIImage imageNamed:@"左1.png"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(_viewWidth / 2 - btnWidth - btnWidth / 2, upButton.frame.origin.y + upButton.frame.size.height, btnWidth, btnWidth);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton setImage:leftdImage forState:UIControlStateHighlighted];
    leftButton.tag = 2;
    [leftButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    //创建向下按钮
    UIImage *downImage = [UIImage imageNamed:@"下.png"];
    UIImage *downdImage = [UIImage imageNamed:@"下1.png"];
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downButton.frame = CGRectMake((_viewWidth - btnWidth) / 2.0, leftButton.frame.origin.y + leftButton.frame.size.height, btnWidth, btnWidth);
    [downButton setImage:downImage forState:UIControlStateNormal];
    [downButton setImage:downdImage forState:UIControlStateHighlighted];
    downButton.tag = 3;
    [downButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downButton];
    //创建向右按钮
    UIImage *rightImage = [UIImage imageNamed:@"右.png"];
    UIImage *rightdImage = [UIImage imageNamed:@"右1.png"];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(upButton.frame.origin.x + upButton.frame.size.width, leftButton.frame.origin.y, btnWidth, btnWidth);
    [rightButton setImage:rightImage forState:UIControlStateNormal];
    [rightButton setImage:rightdImage forState:UIControlStateHighlighted];
    rightButton.tag = 4;
    [rightButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
}
//初始化贪吃蛇
-(void)createSnake
{
    //创建蛇头
    UIView *snakeHead = [[UIView alloc] initWithFrame:CGRectMake(50, 20, 10, 10)];
    snakeHead.backgroundColor = [UIColor greenColor];
//    snakeHead.layer.borderColor = [UIColor whiteColor].CGColor;
//    snakeHead.layer.borderWidth = 1;
    [_snake addObject:snakeHead];
    [[self.view viewWithTag:1000] addSubview:snakeHead];
    //创建蛇身
    UIView *snakeBody = [[UIView alloc] initWithFrame:CGRectMake(40, 20, 10, 10)];
    snakeBody.backgroundColor = [UIColor blueColor];
//    snakeBody.layer.borderColor = [UIColor whiteColor].CGColor;
//    snakeBody.layer.borderWidth = 1;
    [_snake addObject:snakeBody];
    [[self.view viewWithTag:1000] addSubview:snakeBody];
    _lastFrame = snakeBody.frame;
    UIButton *btn1 = [self.view viewWithTag:2];
    btn1.enabled = NO;
    UIButton *btn2 = [self.view viewWithTag:4];
    btn2.enabled = NO;
    UIButton *btn3 = [self.view viewWithTag:1];
    btn3.enabled = YES;
    UIButton *btn4 = [self.view viewWithTag:3];
    btn4.enabled = YES;
    _direction = right;
    _score = 0;
    _time = 0.5;
    //创建定时器
    [self createWall];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(moveSnake) userInfo:nil repeats:YES];
}

//创建障碍物方法
-(void)createWall
{
    _wall = [[NSMutableArray alloc] init];
    NSMutableArray *gameWorld = [[NSMutableArray alloc] init];
    int wallNum = 30;
    //构建游戏世界地图
    for (int i = 0; i < (_viewWidth-20)/10; ++i)
    {
        for (int j = 0; j < (_viewWidth-20)/10; ++j)
        {
            CGRect squareFrame = CGRectMake(j*10, i*10, 10, 10);
            NSValue *squareRect = [NSValue valueWithCGRect:squareFrame];
            [gameWorld addObject:squareRect];
        }
    }
    //删除蛇的身体
    for (int num = 0; num < gameWorld.count; ++num)
    {
        CGRect rect = [gameWorld[num] CGRectValue];
        for (int k = 0; k < _snake.count; ++k)
        {
            CGRect frame = [_snake[k] frame];
            if (rect.origin.x == frame.origin.x && rect.origin.y == frame.origin.y)
            {
                [gameWorld removeObject:gameWorld[num]];
            }
        }
    }
    //构建20个障碍物
    for (int i = 0; i < wallNum; ++i)
    {
        int num = arc4random()%gameWorld.count;
        CGRect wallRect = [gameWorld[num] CGRectValue];
        UIView *wall = [[UIView alloc] initWithFrame:wallRect];
        wall.backgroundColor = [UIColor blackColor];
        [_wall addObject:wall];
        [gameWorld removeObjectAtIndex:num];
        UIView *gameView = [self.view viewWithTag:1000];
        [gameView addSubview:wall];
    }
    [self createFood];
}
//创建食物
-(void)createFood
{
    NSMutableArray *gameWorld = [[NSMutableArray alloc] init];
    //构建游戏世界地图
    for (int i = 0; i < (_viewWidth-25)/10; ++i)
    {
        for (int j = 0; j < (_viewWidth-25)/10; ++j)
        {
            CGRect squareFrame = CGRectMake(j*10, i*10, 10, 10);
            NSValue *squareRect = [NSValue valueWithCGRect:squareFrame];
            [gameWorld addObject:squareRect];
        }
    }
    //删除蛇的身体
    for (int num = 0; num < gameWorld.count; ++num)
    {
        CGRect rect = [gameWorld[num] CGRectValue];
        for (int k = 0; k < _snake.count; ++k)
        {
            CGRect frame = [_snake[k] frame];
            if (rect.origin.x == frame.origin.x && rect.origin.y == frame.origin.y)
            {
                [gameWorld removeObject:gameWorld[num]];
            }
        }
    }
    //删除障碍物
    for (int num = 0; num < gameWorld.count; ++num)
    {
        CGRect rect = [gameWorld[num] CGRectValue];
        for (int k = 0; k < _wall.count; ++k)
        {
            CGRect frame = [_wall[k] frame];
            if (rect.origin.x == frame.origin.x && rect.origin.y == frame.origin.y)
            {
                [gameWorld removeObject:gameWorld[num]];
            }
        }
    }
    //创建食物
    int num = arc4random()%gameWorld.count;
    CGRect foodRect = [gameWorld[num] CGRectValue];
    UIView *food = [[UIView alloc] initWithFrame:foodRect];
    food.backgroundColor = [UIColor redColor];
    _food = food;
    UIView *gameView = [self.view viewWithTag:1000];
    [gameView addSubview:food];
}
//方向键单击处理函数
-(void)btnClick:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        _direction = up;
        sender.enabled = NO;
        UIButton *btn1 = [self.view viewWithTag:3];
        btn1.enabled = NO;
        UIButton *btn2 = [self.view viewWithTag:2];
        btn2.enabled = YES;
        UIButton *btn3 = [self.view viewWithTag:4];
        btn3.enabled = YES;
        return;
    }
    if (sender.tag == 2)
    {
        _direction = left;
        sender.enabled = NO;
        UIButton *btn1 = [self.view viewWithTag:4];
        btn1.enabled = NO;
        UIButton *btn2 = [self.view viewWithTag:1];
        btn2.enabled = YES;
        UIButton *btn3 = [self.view viewWithTag:3];
        btn3.enabled = YES;
        return;
    }
    if (sender.tag == 3)
    {
        _direction = down;
        sender.enabled = NO;
        UIButton *btn1 = [self.view viewWithTag:1];
        btn1.enabled = NO;
        UIButton *btn2 = [self.view viewWithTag:2];
        btn2.enabled = YES;
        UIButton *btn3 = [self.view viewWithTag:4];
        btn3.enabled = YES;
        return;
    }
    if (sender.tag == 4)
    {
        _direction = right;
        sender.enabled = NO;
        UIButton *btn1 = [self.view viewWithTag:2];
        btn1.enabled = NO;
        UIButton *btn2 = [self.view viewWithTag:1];
        btn2.enabled = YES;
        UIButton *btn3 = [self.view viewWithTag:3];
        btn3.enabled = YES;
        return;
    }
}
-(void)startGame:(UIButton *)sender
{
    if (_timer == nil)
    {
        [_label removeFromSuperview];
        [self createSnake];
    }
    else
    {
        [_timer setFireDate:[NSDate distantPast]];
    }
}
-(void)pauseGame:(UIButton *)sender
{
    if ([_timer isValid])
    {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}
//蛇身移动
-(void)moveSnake
{
    _lastFrame = [_snake.lastObject frame];
    for (int i = (int)_snake.count - 1; i > 0; --i)
    {
        CGRect rect = [_snake[i-1] frame];
        UIView *view = _snake[i];
        view.frame = rect;
    }
    //判断移动方向
    if (_direction == up)
    {
        UIView *head = _snake[0];
        head.frame = CGRectMake(head.frame.origin.x, head.frame.origin.y-10, 10, 10);
    }
    else if (_direction == left)
    {
        UIView *head = _snake[0];
        head.frame = CGRectMake(head.frame.origin.x-10, head.frame.origin.y, 10, 10);
    }
    else if (_direction == down)
    {
        UIView *head = _snake[0];
        head.frame = CGRectMake(head.frame.origin.x, head.frame.origin.y+10, 10, 10);
    }
    else if (_direction == right)
    {
        UIView *head = _snake[0];
        head.frame = CGRectMake(head.frame.origin.x+10, head.frame.origin.y, 10, 10);
    }
    //判断是否游戏结束
    BOOL ret = [self judgeGameOver];
    //判断是否吃到食物
    if (!ret)
    {
    if ([self eatFood:_snake[0]])
    {
        _score++;
        UIView *lastSnake = [[UIView alloc] initWithFrame:_lastFrame];
        lastSnake.backgroundColor = [UIColor blueColor];
        UIView *superView = [self.view viewWithTag:1000];
        [superView addSubview:lastSnake];
        [_snake addObject:lastSnake];
        [_food removeFromSuperview];
        [self createFood];
        //减少时间间隔
        [self reduceTime];
    }
    }
}
//判断游戏结束
-(BOOL)judgeGameOver
{
    //判断是否超出边界
    if ([self judgeEdge:_snake[0]])
    {
        [self gameOver];
        return YES;
    }
    else if ([self judgeWall:_snake[0]])
    {
        [self gameOver];
        return YES;
    }
    else if ([self judgeSelf:_snake[0]])
    {
        [self gameOver];
        return YES;
    }
    else
    {
        return NO;
    }
}
//判断是否超出边界
-(BOOL)judgeEdge:(UIView *)head
{
    if (head.frame.origin.x > _viewWidth-30 || head.frame.origin.x < 0 || head.frame.origin.y > _viewWidth-30 || head.frame.origin.y < 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//判断是否撞墙
-(BOOL)judgeWall:(UIView *)head
{
    BOOL flag = NO;
    for (UIView *re in _wall)
    {
        if (head.frame.origin.x == re.frame.origin.x && head.frame.origin.y == re.frame.origin.y)
        {
            flag = YES;
            break;
        }
    }
    return flag;
}
//判断是否撞到自己
-(BOOL)judgeSelf:(UIView *)head
{
    BOOL flag = NO;
    for (int i = 1; i < _snake.count; ++i)
    {
        UIView *snakeBody = _snake[i];
        if (head.frame.origin.x == snakeBody.frame.origin.x && head.frame.origin.y == snakeBody.frame.origin.y)
        {
            flag = YES;
            break;
        }
    }
    return flag;
}
//游戏结束
-(void)gameOver
{
    //清理游戏场景
    UIView *view = [self.view viewWithTag:1000];
    NSArray *subView = [view subviews];
    for (UIView *vi in subView)
    {
        [vi removeFromSuperview];
    }
    //显示结果
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 200, 100)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"GameOver\n得分:%d", _score];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    _label = label;
    [view addSubview:label];
    [_timer invalidate];
    _timer = nil;
    _score = 0;
    [_snake removeAllObjects];
    [_wall removeAllObjects];
}
//判断吃到食物
-(BOOL)eatFood:(UIView *)head
{
    if (head.frame.origin.x == _food.frame.origin.x && head.frame.origin.y == _food.frame.origin.y)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//减少时间间隔
-(void)reduceTime
{
    [_timer invalidate];
    _timer = nil;
    if (_score < 5)
    {
        _time = _time - 0.03;
    }
    else if (_score < 10)
    {
        _time = _time - 0.02;
    }
    else if (_score >= 10)
    {
        _time = _time - 0.01;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(moveSnake) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
