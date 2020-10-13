//
//  ContentView.swift
//  IsolinesDemo
//
//  Created by Reid van Melle on 2020-10-12.
//

import SwiftUI

struct DelauneyView: UIViewRepresentable {
    // @Binding var text: String

    func makeUIView(context: Context) -> TriangleView {
        return TriangleView()
    }

    func updateUIView(_ uiView: TriangleView, context: Context) {
        // uiView.text = text
    }
}

struct ContentView: View {
    var body: some View {
        // VStack {
            DelauneyView()
                // .frame(minWidth: 200, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
                .background(Color.red)
        // .frame(width: 400, height: 600, alignment: .center)
            // frame(width: self.width, height: self.height)
        //}
            // .padding()
    }

//    var body: some View {
//        Text("Hello, world!")
//            .padding()
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
