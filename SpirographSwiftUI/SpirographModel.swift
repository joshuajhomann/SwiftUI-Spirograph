//
//  SpirographModel.swift
//  SpirographSwiftUI
//
//  Created by Joshua Homann on 7/23/19.
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
  let offset: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxOffset/2)
  let samples: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxSamples/2)
  private (set) var points: [CGPoint] = SpirographModel
    .makeSpirograph(
      majorRadius: Constant.maxMajorRadius,
      minorRadius: Constant.maxMinorRadius/2,
      offset: Constant.maxOffset/2,
      samples: Constant.maxSamples/2
    )
  private var pointSubscription: AnyCancellable?

  init() {
    let input = Publishers.CombineLatest4(majorRadius, minorRadius, offset, samples)

    willChange = input
      .receive(on: RunLoop.main)
      .map { _ in () }
      .eraseToAnyPublisher()

    pointSubscription = input
      .drop(untilOutputFrom: willChange)
      .map { SpirographModel.makeSpirograph(majorRadius: $0.0, minorRadius: $0.1, offset: $0.2, samples: $0.3) }
      .assign(to: \.points, on: self)

  }

  private static func makeSpirograph(majorRadius: CGFloat, minorRadius: CGFloat, offset: CGFloat, samples: CGFloat) -> [CGPoint] {
    let Δr = majorRadius - minorRadius
    let Δθ = 2 * CGFloat.pi / samples
    return (0..<Constant.iterations).map { iteration in
      let θ = Δθ * CGFloat(iteration)
      return CGPoint(
        x: CGFloat(Δr * cos(θ) + offset  * cos(Δr * θ / minorRadius )),
        y: CGFloat(Δr * sin(θ) + offset  * sin(Δr * θ / minorRadius ))
      )
    }
  }

}
