import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .ignoresSafeArea()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    final class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView!

        func startSession() {
            let config = ARWorldTrackingConfiguration()
            config.worldAlignment = .gravity
            config.environmentTexturing = .automatic
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            arView.session.delegate = self
        }

        func placeMarkerTwoMetersAboveDevice() {
            guard let frame = arView.session.currentFrame else { return }

            // Текущая позиция камеры
            var transform = frame.camera.transform

            // Смещаем на +2м по оси Y мира (вверх по гравитации)
            transform.columns.3.y += 2.0

            // Якорь в мире и простая красная сфера
            let anchor = AnchorEntity(world: transform)
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            anchor.addChild(sphere)
            arView.scene.addAnchor(anchor)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        context.coordinator.startSession()

        // Ставим метку спустя короткую задержку, чтобы кадр успел появиться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            context.coordinator.placeMarkerTwoMetersAboveDevice()
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
