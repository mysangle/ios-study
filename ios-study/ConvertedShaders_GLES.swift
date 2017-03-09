//
//  ConvertedShaders_GLES.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public let YUVConversionFullRangeFragmentShader = "varying highp vec2 textureCoordinate;\n varying highp vec2 textureCoordinate2;\n \n uniform sampler2D inputImageTexture;\n uniform sampler2D inputImageTexture2;\n \n uniform mediump mat3 colorConversionMatrix;\n \n void main()\n {\n     mediump vec3 yuv;\n     \n     yuv.x = texture2D(inputImageTexture, textureCoordinate).r;\n     yuv.yz = texture2D(inputImageTexture2, textureCoordinate).ra - vec2(0.5, 0.5);\n     lowp vec3 rgb = colorConversionMatrix * yuv;\n     \n     gl_FragColor = vec4(rgb, 1.0);\n }\n "
public let YUVConversionVideoRangeFragmentShader = "varying highp vec2 textureCoordinate;\n varying highp vec2 textureCoordinate2;\n \n uniform sampler2D inputImageTexture;\n uniform sampler2D inputImageTexture2;\n \n uniform mediump mat3 colorConversionMatrix;\n \n void main()\n {\n     mediump vec3 yuv;\n     \n     yuv.x = texture2D(inputImageTexture, textureCoordinate).r - (16.0/255.0);\n     yuv.yz = texture2D(inputImageTexture2, textureCoordinate).ra - vec2(0.5, 0.5);\n     lowp vec3 rgb = colorConversionMatrix * yuv;\n     \n     gl_FragColor = vec4(rgb, 1.0);\n }\n "
