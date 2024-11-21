
import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = FoodListViewModel()
        @State private var bins: [Int] = []
        @State private var binRanges: [String] = []

        var body: some View {
            VStack {
                Text("Protein Distribution Histogram")
                    .font(.title)
                    .bold()
                    .padding()

                if bins.isEmpty && !viewModel.isLoading {
                    Text("Loading data...")
                        .foregroundColor(.gray)
                } else {
                    VStack {
                        HistogramCanvas(bins: bins, binRanges: binRanges)
                            .frame(height: 300)
                            .padding()

                        HStack {
                            ForEach(binRanges, id: \.self) { range in
                                Text(range)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }

                Spacer()
            }
            .onAppear {
                loadHistogramData()
            }
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
        }

        private func loadHistogramData() {
            viewModel.loadMoreFoods()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let proteinData = viewModel.alimentos.map { $0.proteina }
                bins = createHistogramBins(from: proteinData, binCount: 5)
                binRanges = createBinRanges(from: proteinData, binCount: 5)
            }
        }

        private func createHistogramBins(from data: [Float], binCount: Int) -> [Int] {
            guard let maxValue = data.max(), let minValue = data.min() else { return [] }
            let binWidth = (maxValue - minValue) / Float(binCount)
            var bins = Array(repeating: 0, count: binCount)

            for value in data {
                let binIndex = min(binCount - 1, Int((value - minValue) / binWidth))
                bins[binIndex] += 1
            }
            return bins
        }

        private func createBinRanges(from data: [Float], binCount: Int) -> [String] {
            guard let maxValue = data.max(), let minValue = data.min() else { return [] }
            let binWidth = (maxValue - minValue) / Float(binCount)
            return (0..<binCount).map { index in
                let lowerBound = minValue + Float(index) * binWidth
                let upperBound = lowerBound + binWidth
                return String(format: "%.1f - %.1f", lowerBound, upperBound)
            }
        }
    }


struct HistogramCanvas: View {
    let bins: [Int]
    let binRanges: [String]

    var body: some View {
        Canvas { context, size in
            let barWidth = size.width / CGFloat(bins.count)
            let maxValue = bins.max() ?? 1

            for (index, bin) in bins.enumerated() {
                // Altura de la barra
                let height = size.height * CGFloat(bin) / CGFloat(maxValue)
                let rect = CGRect(
                    x: CGFloat(index) * barWidth,
                    y: size.height - height,
                    width: barWidth * 0.8,
                    height: height
                )
                
                // Dibujar barra
                context.fill(
                    Path(rect),
                    with: .color(Color.black)
                )

                // Dibujar texto con cantidad de elementos en el bin
                let text = "\(bin)"
                let textPosition = CGPoint(
                    x: rect.midX,
                    y: rect.minY - 20
                )
                context.draw(
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.primary),
                    at: textPosition
                )
            }
        }
    }
}
