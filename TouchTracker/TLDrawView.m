//
//  TLDrawView.m
//  TouchTracker
//
//  Created by lushuishasha on 2016/12/13.
//  Copyright © 2016年 lushuishasha. All rights reserved.
//

#import "TLDrawView.h"
#import "TLLine.h"

@interface TLDrawView()<UIGestureRecognizerDelegate>
//同一时刻只能处理一个触摸消息（只能华一根线）
//@property (nonatomic,strong) TLLine *currentLine;
@property (nonatomic,strong) NSMutableArray *finishedLines;
// 可以同时画出多根线
@property (nonatomic,strong) NSMutableDictionary *lineInProgress;
@property (nonatomic,weak) TLLine *selectedLine;
@property (nonatomic,strong) UIPanGestureRecognizer *moveRecognizer;
@end

@implementation TLDrawView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineInProgress = [[NSMutableDictionary alloc]init];
        self.finishedLines = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor grayColor];
        //可以同时接受多个触摸事件
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        //tapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:tapRecognizer];
        
        
        //双击屏幕时，清除屏幕上的所有线条
        UITapGestureRecognizer *douobleTapRecognozer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        //双击（不写，默认就是单击）
        douobleTapRecognozer.numberOfTouchesRequired = 2;
        //避免在双击位置画出一个原点（只是识别手势，也就是避免触发touchesBegan: withEvent: 现在是使用了这个方法就只画了一个点，不能正常的划线了）
      // douobleTapRecognozer.delaysTouchesBegan = YES;

//        //在单击时候暂时不进行识别，知道确定不是双击手势后在识别为单击手势（避免将双击事件拆分为两个单击事件）
        [tapRecognizer requireGestureRecognizerToFail:douobleTapRecognozer];
        [self addGestureRecognizer:douobleTapRecognozer];
        
        //长按手势
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        //拖拽手势
        self.moveRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveLine:)];
        self.moveRecognizer.delegate  = self;
        [self addGestureRecognizer:self.moveRecognizer];
    }
    return self;
}

#pragma Mark UIResponder(触摸事件)
- (void)strokeLine:(TLLine *)line {
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] set];
    for (TLLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    //    if (self.currentLine) {
    //        [[UIColor redColor] set];
    //        [self strokeLine:self.currentLine];
    //    }
    for (NSValue *key in self.lineInProgress) {
        [[UIColor redColor] set];
        [self strokeLine:self.lineInProgress[key]];
    }
    //用绿色绘制选中的线条
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //向控制台输出日志，查看触摸事件的顺序
    NSLog(@"%@",NSStringFromSelector(_cmd));
    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];
        TLLine *line = [[TLLine alloc]init];
        line.begin = location;
        line.end = location;
        //使用valueWithNonretainedObject将UITouch的内存地址封装成NSValue对象，内存地址相同UITouch一定是同一个对象
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.lineInProgress[key] = line;
    }
    
    //当前对象只能是一个
//        UITouch *t = [touches anyObject];
//        CGPoint location = [t locationInView:self];
//        self.currentLine = [[TLLine alloc]init];
//        self.currentLine.begin = location;
//        self.currentLine.end = location;
//        [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        TLLine *line = self.lineInProgress[key];
        line.end = [t locationInView:self];
    }
//        UITouch *t = [touches anyObject];
//        CGPoint location = [t locationInView:self];
//        self.currentLine.end = location;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        TLLine *line = self.lineInProgress[key];
        [self.finishedLines addObject:line];
        [self.lineInProgress removeObjectForKey:key];
    }
//        [self.finishedLines addObject:self.currentLine];
//        self.currentLine = nil;
    [self setNeedsDisplay];
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.lineInProgress removeObjectForKey:key];
    }
    [self setNeedsDisplay];
}

#pragma Mark UIGestureRecognizer(手势)
-(void)doubleTap:(UITapGestureRecognizer *)gr {
    NSLog(@"Recognizer Double Tap");
    [self.lineInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

//选中线条用绿色重绘
- (void)tap:(UITapGestureRecognizer *)gr{
    NSLog(@"Recognized tap");
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    if (self.selectedLine) {
        //使视图成为UIMenuItem动作消息的目标(显示UIMenuController对象的UIView对象必须是当前UIWindow对象的第一响应者)
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        //创建一个新的标题为Delete的UIMenuItem对象
        UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:@"Delete" action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        //先为UIMenuController设置显示区域
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES];
    } else {
        //如果没有选中的线条 ，隐藏UIMenuController对象
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    [self setNeedsDisplay];
}

//根据传入的位置找出最近的那个TLLine
- (TLLine *)lineAtPoint:(CGPoint)p {
    for (TLLine *line in self.finishedLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        //检查线条的若干点
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            //如果线条的摸个点和p点的距离在20点以内，就返回相应的TLLine对象
            if (hypot(x - p.x, y - p.y) < 20) {
                return line;
            }
        }
    }
    return nil;
}

//UIMenuController弹出时 要将某个自定义的View子类对象设置为第一响应对象，必须覆盖这个方法
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//必须实现动作方法，参会显示UIMenuController
- (void)deleteLine:(id)sender {
    //从已经完成的线条中删除选中的线条
    [self.finishedLines removeObject:self.selectedLine];
    //重画整个视图
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        //找出离点击地方离的最近的那条线
        self.selectedLine = [self lineAtPoint:point];
        if (self.selectedLine) {
            [self.lineInProgress removeAllObjects];
        }
    }else if (gr.state == UIGestureRecognizerStateEnded){
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
}

//识别多个手势的时候使用(比如说既有长按手势又有拖拽手势的时候)，当UIGestureRecognizer的某个子类对象识别了特定的手势后，发现其他的UIGestureRecognizer对象也识别了特定的手势，就会调用这个方法，返回Yes，则这个UIGestureRecognizer对象与其他的UIGestureRecognizer对象共享UITouch对象
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    return NO;
}

- (void)moveLine:(UIPanGestureRecognizer *)gr {
    if (!self.selectedLine) {
        return;
    }
    //UIPanGestureRecognizer处于变化后的状态
    if (gr.state == UIGestureRecognizerStateChanged) {
        //获取手指的拖移的距离
        CGPoint translate = [gr translationInView:self];
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translate.x;
        begin.y += translate.y;
        end.x +=  translate.x;
        end.y += translate.y;
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        [self setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:self];
    }
}


@end
