//
//  Home.swift
//  CryptoApp
//
//  Created by MINH DUC NGUYEN on 02/07/2022.
//

import SwiftUI

struct Home: View {
    @State var currentCoin: String = "BTC"
    @Namespace var animation
    @StateObject var appModel: AppViewModel = AppViewModel()
    var body: some View {
        VStack {
            if let coins = appModel.coins, let coin = appModel.currentCoin {
                //MARK: - Sample UI
                HStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Circle()
                            .fill(.orange)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Bitcoin")
                                .font(.callout)
                            Text("BTC")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image("Profile")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CustomControl(coins: coins)
                    .padding(.vertical, 10)
                
                GraphView(coin: coin)
                
                Controls()
            } else {
                ProgressView()
                    .tint(Color("Orange"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //MARK: - Custom Segented Control
    @ViewBuilder
    func CustomControl(coins: [CryptoModel]) -> some View {
        // Sample Data
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(coins) { coin in
                    Text(coin.symbol.uppercased())
                        .foregroundColor(currentCoin == coin.symbol.uppercased() ? .black : .gray)
                        .font(.callout.bold())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .contentShape(RoundedRectangle(cornerRadius: 20))
                        .background {
                            if currentCoin == coin.symbol.uppercased() {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("Orange"))
                                    .matchedGeometryEffect(id: "SEGMENTEDTAB", in: animation)
                            }
                        }
                        .onTapGesture {
                            appModel.currentCoin = coin
                            withAnimation { currentCoin = coin.symbol.uppercased() }
                        }
                }
            }
        }
    }
    
    //MARK: - Graph View
    func GraphView(coin: CryptoModel) -> some View {
        GeometryReader { _ in
            LineGraph(data: coin.last_7days_price.price)
        }
        .padding(.vertical, 30)
//        .padding(.horizontal, 20)
    }
    
    //MARK: - Controls
    @ViewBuilder
    func Controls() -> some View {
        HStack(spacing: 20) {
            Button {
                
            } label: {
                Text("Sell")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color("Red"))
                    }
            }
            
            Button {
                
            } label: {
                Text("Buy")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color("Green"))
                    }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
