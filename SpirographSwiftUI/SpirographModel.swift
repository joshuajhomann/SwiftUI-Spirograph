//
//  SpirographModel.swift
//  SpirographSwiftUI
//
//  Created by Joshua Homann on 7/23/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI
import Combine

class SpirographModel: ObservableObject {

  enum Constant {
    static let maxMajorRadius: CGFloat = 100
    static let maxMinorRadius: CGFloat = 100
    static let maxOffset: CGFloat = 50
    static let maxSamples: CGFloat = 100
    static let iterations = 2000
  }
  let majorRadius: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxMajorRadius)
  let minorRadius: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxMinorRadius/2)
  let offset: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxOffset/2)
  let samples: CurrentValueSubject<CGFloat, Never> = .init(Constant.maxSamples/2)
  @Published var points: [CGPoint] =  []
  private var pointSubscription: AnyCancellable?

  init() {
    pointSubscription = Publishers
      .CombineLatest4(majorRadius, minorRadius, offset, samples)
      .map { majorRadius, minorRadius, offset, samples in
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
    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
    .receive(on: RunLoop.main)
    .assign(to: \.points, on: self)
  }
}
