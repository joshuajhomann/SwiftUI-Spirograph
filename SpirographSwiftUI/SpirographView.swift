//
//  ContentView.swift
//  SpirographSwiftUI
//
//  Created by Joshua Homann on 6/21/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI
import Combine

class SpirographModel: BindableObject {
  enum Constant {
    static let maxMajorRadius: CGFloat = 100
    static let maxMinorRadius: CGFloat = 100
    static let maxOffset: CGFloat = 50
    static let maxSamples: CGFloat = 100
    static let iterations = 1000
  }
  let willChange: AnyPublisher<Void, Never>
  let majorRadius: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxMajorRadius)
  let minorRadius: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxMinorRadius/2)
  let pointOffset: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxOffset/2)
  let samples: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxSamples/2)
  private (set) var points: [CGPoint] = []
  private var pointSubscription: AnyCancellable?
  init() {
    let combined = Publishers.CombineLatest4(majorRadius, minorRadius, pointOffset, samples)

    willChange = combined
      .receive(on: RunLoop.main)
      .map { _ in () }
      .eraseToAnyPublisher()

    pointSubscription = combined
      .map { (majorRadius, minorRadius, pointOffset, samples) -> [CGPoint] in
        let Δr = majorRadius - minorRadius
        let Δθ = 2 * CGFloat.pi / samples
        return (0..<Constant.iterations).map { iteration in
          let θ = Δθ * CGFloat(iteration)
          return CGPoint(
            x: CGFloat(Δr * cos(θ) + pointOffset * cos(Δr * θ / minorRadius)),
            y: CGFloat(Δr * sin(θ) + pointOffset * sin(Δr * θ / minorRadius))
          )
        }
      }
      .assign(to: \.points, on: self)
  }

}

struct SpirographView : View {
  @ObjectBinding private var spirographModel: SpirographModel
  private let majorRadius: Binding<CGFloat>
  private let minorRadius: Binding<CGFloat>
  private let offset: Binding<CGFloat>
  private let samples: Binding<CGFloat>

  init(spirographModel: SpirographModel) {
    majorRadius = Binding<CGFloat>(
      getValue: { spirographModel.majorRadius.value },
      setValue: { spirographModel.majorRadius.value = $0}
    )
    minorRadius = Binding<CGFloat>(
      getValue: { spirographModel.minorRadius.value },
      setValue: { spirographModel.minorRadius.value = $0}
    )
    offset = Binding<CGFloat>(
      getValue: { spirographModel.pointOffset.value },
      setValue: { spirographModel.pointOffset.value = $0}
    )
    samples = Binding<CGFloat>(
      getValue: { spirographModel.samples.value },
      setValue: { spirographModel.samples.value = $0}
    )
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
