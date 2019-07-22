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
  }
  let willChange: AnyPublisher<Void, Never>
  let majorRadius: CurrentValueSubject<CGFloat, Never> = .init(50)
  let minorRadius: CurrentValueSubject<CGFloat, Never> = .init(100)
  let pointOffset: CurrentValueSubject<CGFloat, Never> = .init(50)
  let samples: CurrentValueSubject<CGFloat, Never> = .init(30)
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
        return (0..<1000).map { iteration in
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
  @ObjectBinding var spirographModel: SpirographModel
  let slider1: Binding<CGFloat>
  let slider2: Binding<CGFloat>
  let slider3: Binding<CGFloat>
  let slider4: Binding<CGFloat>

  init(spirographModel: SpirographModel) {
    slider1 = Binding<CGFloat>(
      getValue: { [majorRadius = spirographModel.majorRadius] in majorRadius.value },
      setValue: { [majorRadius = spirographModel.majorRadius] in majorRadius.value = $0}
    )
    slider2 = Binding<CGFloat>(
      getValue: { [minorRadius = spirographModel.minorRadius] in minorRadius.value },
      setValue: { [minorRadius = spirographModel.minorRadius] in minorRadius.value = $0}
    )
    slider3 = Binding<CGFloat>(
      getValue: { [pointOffset = spirographModel.pointOffset] in pointOffset.value },
      setValue: { [pointOffset = spirographModel.pointOffset] in pointOffset.value = $0}
    )
    slider4 = Binding<CGFloat>(
      getValue: { [samples = spirographModel.samples] in samples.value },
      setValue: { [samples = spirographModel.samples] in samples.value = $0}
    )
    self.spirographModel = spirographModel
  }

  private func scale(to rect: CGRect) -> CGAffineTransform {
    let scale = min(
      rect.width / (SpirographModel.Constant.maxMajorRadius * 2),
      rect.height / (SpirographModel.Constant.maxMajorRadius * 2)
    )
    return CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2)
      .scaledBy(x: scale, y: scale)
  }

  var body: some View {
    VStack {
      GeometryReader { geometry in
        Path { path in
          path.addLines(self.spirographModel.points)
        }
        .applying(self.scale(to: geometry.frame(in: .global)))
        .strokedPath(.init(lineWidth: 1))
        .foregroundColor(.blue)
        .clipped()
      }
      VStack {
        HStack {
          Text("Major")
            .font(.caption)
            .frame(width: 50)
          Slider(value: slider1, from: 0, through: SpirographModel.Constant.maxMajorRadius, by: 1)
          Text(String(describing: Int(slider1.value))).frame(width: 40)
        }
        HStack {
          Text("Minor")
            .font(.caption)
            .frame(width: 50)
          Slider(value: slider2, from: 0, through: SpirographModel.Constant.maxMinorRadius, by: 1)
          Text(String(describing: Int(slider2.value))).frame(width: 40)
        }
        HStack {
          Text("Offset")
            .font(.caption)
            .frame(width: 50)
          Slider(value: slider3, from: 0, through: SpirographModel.Constant.maxOffset, by: 1)
          Text(String(describing: Int(slider3.value))).frame(width: 40)
        }
        HStack {
          Text("Sample")
            .font(.caption)
            .frame(width: 50)
          Slider(value: slider4, from: 2, through: SpirographModel.Constant.maxSamples, by: 1)
          Text(String(describing: Int(slider4.value))).frame(width: 40)
        }
      }.padding()
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
