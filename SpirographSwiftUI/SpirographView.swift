//
//  ContentView.swift
//  SpirographSwiftUI
//
//  Created by Joshua Homann on 6/21/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI

struct SpirographView : View {

  @ObjectBinding private var spirographModel: SpirographModel
  private let majorRadius: Binding<CGFloat>
  private let minorRadius: Binding<CGFloat>
  private let offset: Binding<CGFloat>
  private let samples: Binding<CGFloat>

  init(spirographModel: SpirographModel) {
    majorRadius = spirographModel.majorRadius.makeBinding()
    minorRadius = spirographModel.minorRadius.makeBinding()
    offset = spirographModel.offset.makeBinding()
    samples = spirographModel.samples.makeBinding()
    self.spirographModel = spirographModel
  }

  var body: some View {
    VStack {
      GeometryReader { geometry in
        Path { path in
          path.addLines(self.spirographModel.points)
        }
        .applying( {
          let rect = geometry.frame(in: .local)
          let scale = min(
            rect.width / (SpirographModel.Constant.maxMajorRadius * 2),
            rect.height / (SpirographModel.Constant.maxMajorRadius * 2)
          )
          return CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2)
            .scaledBy(x: scale, y: scale)
          }()
        )
        .strokedPath(.init(lineWidth: 1))
        .foregroundColor(.blue)
        .clipped()
      }
      VStack {
        sliderView(name: "Major", min: 0, max: SpirographModel.Constant.maxMajorRadius, binding: majorRadius)
        sliderView(name: "Minor", min: 0, max: SpirographModel.Constant.maxMinorRadius, binding: minorRadius)
        sliderView(name: "Offset", min: 0, max: SpirographModel.Constant.maxOffset, binding: offset)
        sliderView(name: "Sample", min: 2, max: SpirographModel.Constant.maxSamples, binding: samples)
      }.padding()
    }
  }

  private func sliderView(name: String, min: CGFloat, max: CGFloat, binding: Binding<CGFloat>) -> some View {
    HStack {
      Text(name)
        .font(.caption)
        .frame(width: 50)
      Slider(value: binding, from: min, through: max, by: 1)
      Text("\(Int(binding.value))").frame(width: 40)
    }
  }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    SpirographView(spirographModel: SpirographModel())
  }
}
#endif
