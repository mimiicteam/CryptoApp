//
//  LineGraph.swift
//  AnalyticsPageUI
//
//  Created by MINH DUC NGUYEN on 28/06/2022.
//

import SwiftUI

// Custom View...
struct LineGraph: View {
    // Number of plots
    var data: [Double]
    var profit: Bool = false
    
    @State var currentPlot = ""
    @State var offset: CGSize = .zero
    @State var showPlot: Bool = false
    @State var translation: CGFloat = 0
    //MARK: - Animating Graph
    @State var graphProgress: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            
            let height = proxy.size.height
            let width = proxy.size.width / CGFloat(data.count - 1)
            
            let maxPoints = data.max() ?? 0
            let minPoints = data.min() ?? 0
            // Getting progress and multiplyinh with height
            let points = data.enumerated().compactMap { item -> CGPoint in
                let progress = (item.element - minPoints) / (maxPoints - minPoints)
                // height
                let pathHeight = progress * (height - 50)
                // width..
                let pathWidth = width * CGFloat(item.offset)
                // Since we need peak to top not bottom
                return CGPoint(x: pathWidth, y: -pathHeight + height)
            }
            
            ZStack {
                // Converting plot as points....
                
                AnimatedPath(progress: graphProgress, points: points)
                .fill(
                    // Gradient...
                    LinearGradient(colors: [
                        profit ? Color("Green") : Color("Red"),
                        profit ? Color("Green") : Color("Red")
                    ], startPoint: .leading, endPoint: .trailing)
                )
                
                // Path Background Coloring ...
                FillBG()
                // Clipping the shape...
                .clipShape(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLines(points)
                        path.addLine(to: CGPoint(x: proxy.size.width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                    }
                )
//                .padding(.top, 15)
            }
            .overlay(
                // Drag Indiccator...
                VStack(spacing: 0) {
                    Text(currentPlot)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color("Gradient1"), in: Capsule())
                        .offset(x: translation < 10 ? 30 : 0)
                        .offset(x: translation < (proxy.size.width - 60) ? -30 : 0)
                    
                    Rectangle()
                        .fill(Color("Gradient1"))
                        .frame(width: 1, height: 40)
                        .padding(.top)
                    
                    Circle()
                        .fill(Color("Gradient1"))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                        )
                    
                    Rectangle()
                        .fill(Color("Gradient1"))
                        .frame(width: 1, height: 50)
                }
                //Fixed Frame
                    .frame(width: 80, height: 170)
                    .offset(y: 70)
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0),
                alignment: .bottomLeading
            )
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged({ value in
                withAnimation { showPlot = true }
                
                let translation = value.location.x
                self.translation = translation
                // Getting Index...
                let index = max(min(Int((translation / width).rounded() + 1), data.count - 1), 0)
                currentPlot = "$ \(data[index])"
                offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
            }).onEnded({ value in
                withAnimation { showPlot = false }
            }))
        }
        .overlay(
            VStack(alignment: .leading) {
                let max = data.max() ?? 0
                let min = data.min() ?? 0
                Text("$ \(max.convertToCurrency())")
                    .font(.caption.bold())
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("$ \(min.convertToCurrency())")
                        .font(.caption.bold())
                    
                    Text("Last 7 Days")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .offset(y: 20)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
        )
        .padding(.horizontal, 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    graphProgress = 1
                }
            }
        }
        .onChange(of: data) { newValue in
            graphProgress = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    graphProgress = 1
                }
            }
        }
    }
    @ViewBuilder
    func FillBG() -> some View {
        let color = profit ? Color("Green") : Color("Red")
        LinearGradient(colors: [
        color
            .opacity(0.3),
        color
            .opacity(0.2),
        color
            .opacity(0.1)
        ]
        + Array(repeating: color.opacity(0.1), count: 4)
        + Array(repeating: Color.clear, count: 2),
        startPoint: .top, endPoint: .bottom)
    }
}


struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: - Animated Path
struct AnimatedPath: Shape {
    var progress: CGFloat
    var points: [CGPoint]
    var animatableData: CGFloat {
        get{ return progress }
        set{ progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // Path
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLines(points)
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
    }
}
