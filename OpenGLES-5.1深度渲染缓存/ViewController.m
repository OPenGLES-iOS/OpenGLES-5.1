//
//  ViewController.m
//  OpenGLES-5.1深度渲染缓存
//
//  Created by ShiWen on 2017/5/19.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController ()
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mPostionBuffer;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mTextureBuffer;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mNomalBuffer;
@property (nonatomic,strong) GLKBaseEffect *mBaseEffect;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glView = (GLKView*)self.view;
//    可深度绘制格式
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    glView.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:glView.context];
    [((AGLKContext *)glView.context) setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
    self.mBaseEffect = [[GLKBaseEffect alloc] init];
    self.mBaseEffect.useConstantColor = GL_TRUE;
    self.mBaseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    //初始化缓存
    self.mPostionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts)/(3*sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];

    self.mTextureBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(sizeof(GLfloat)*2) numberOfVertices:sizeof(sphereTexCoords)/(sizeof(GLfloat)*2) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    self.mNomalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(GLfloat) * 3 numberOfVertices:sizeof(sphereNormals)/(sizeof(GLfloat)*3) bytes:sphereNormals usage:GL_STATIC_DRAW];
    //初始化、设置 纹理
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth.jpg"] CGImage];
    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:imageRef options:[NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    self.mBaseEffect.texture2d0.target = info.target;
    self.mBaseEffect.texture2d0.name = info.name;
    
    //灯光设置
    self.mBaseEffect.light0.enabled = GL_TRUE;
//    漫反射颜色
    self.mBaseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    //环境颜色 RGBA
    self.mBaseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    //光源位置
    self.mBaseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, -0.8f, 0.0f);
    [((AGLKContext*)glView.context) enable:GL_DEPTH_TEST];
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *) view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    //处理宽高比例
    GLfloat aspectRat = (GLfloat)view.drawableWidth/(GLfloat )view.drawableHeight;
    //XYZ轴比例
    self.mBaseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRat, 1.0f);

    [self.mPostionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.mNomalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.mTextureBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [self.mBaseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
