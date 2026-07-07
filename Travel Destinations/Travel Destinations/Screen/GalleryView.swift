//
//  GalleryView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum StickerStudioMode: String, CaseIterable {
    case single = "Single"
    case pack = "Pack"
}

enum StickerShape: String, CaseIterable {
    case rounded = "Rounded"
    case circle = "Circle"
    case ticket = "Ticket"
}

enum StickerPalette: String, CaseIterable {
    case ocean = "Ocean"
    case sunset = "Sunset"
    case forest = "Forest"
}

struct StickerExport: Transferable, Identifiable {
    let id = UUID()
    let filename: String
    let imageData: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { export in
            export.imageData
        }
        .suggestedFileName { export in
            export.filename
        }
    }
}

struct StickerSharePayload: Identifiable {
    let id = UUID()
    let activityItems: [Any]
    let photosSuccessMessage: String
    let filesSuccessMessage: String
    let genericSuccessMessage: String
}

struct StickerToast: Identifiable {
    let id = UUID()
    let message: String
    let isSuccess: Bool
}

struct GalleryView: View {
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var viewState: ViewState<[TravelDestination]> = .idle
    @State private var selectedMode = StickerStudioMode.single
    @State private var selectedDestinationID: TravelDestination.ID?
    @State private var selectedShape = StickerShape.rounded
    @State private var selectedPalette = StickerPalette.ocean
    @State private var selectedStickerImageIndex = 0
    @State private var isRendering = false
    @State private var exportMessage: String?
    @State private var sharePayload: StickerSharePayload?
    @State private var toast: StickerToast?

    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .background(AppTheme.appGradient.ignoresSafeArea())
                .task {
                    await fetchDestinationsIfNeeded()
                }
                .sheet(item: $sharePayload) { payload in
                    ActivityView(activityItems: payload.activityItems) { activityType, completed, error in
                        if let error {
                            showExportToast(error.localizedDescription, isSuccess: false)
                        } else if completed {
                            showExportToast(exportCompletionMessage(for: activityType, payload: payload))
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if let toast {
                        StickerToastView(toast: toast)
                            .padding(.top, 16)
                            .padding(.horizontal, 18)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                    }
                }
                .alert(
                    "Sticker Export",
                    isPresented: Binding(
                        get: { exportMessage != nil },
                        set: { isPresented in
                            if !isPresented {
                                exportMessage = nil
                            }
                        }
                    )
                ) {
                    Button("OK", role: .cancel) {
                        exportMessage = nil
                    }
                } message: {
                    Text(exportMessage ?? "")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewState {
        case .idle, .loading:
            AppLoadingView(
                title: "Opening Sticker Studio",
                message: "Preparing destination artwork"
            )
        case .loaded(let destinations):
            if destinations.isEmpty {
                ContentUnavailableView("No Destinations", systemImage: "sparkles")
            } else {
                stickerStudio(for: destinations)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load Stickers", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await fetchDestinations()
                    }
                }
            }
        }
    }

    private func stickerStudio(for destinations: [TravelDestination]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                stickerHeader

                modeSelector

                controls(for: destinations)

                if selectedMode == .single {
                    singleStickerSection(for: destinations)
                } else {
                    stickerPackSection(for: destinations)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(.bottom, 110)
        }
        .refreshable {
            await fetchDestinations(shouldShowLoading: false)
        }
    }

    private var stickerHeader: some View {
        AppHeaderView(
            title: "Sticker",
            highlightedTitle: " Studio",
            subtitle: "Create polished travel stickers from your destination media."
        )
    }

    private var modeSelector: some View {
        HStack(spacing: 0) {
            stickerModeButton(.single, icon: "square")
            stickerModeButton(.pack, icon: "square.stack.3d.up")
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(AppTheme.softBorder))
    }

    private func stickerModeButton(_ mode: StickerStudioMode, icon: String) -> some View {
        let isSelected = selectedMode == mode

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMode = mode
            }
        } label: {
            Label(mode.rawValue, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(isSelected ? .white : AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    if isSelected {
                        AppTheme.brandGradient
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func controls(for destinations: [TravelDestination]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Menu {
                Picker("Destination", selection: selectedDestinationBinding(for: destinations)) {
                    ForEach(destinations) { destination in
                        Text(destination.name).tag(destination.id)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle")
                        .font(.title2)
                    Text(selectedDestination(from: destinations)?.name ?? "Destination")
                        .font(.title2.weight(.bold))
                    Image(systemName: "chevron.down")
                        .font(.headline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.elevatedSurface.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            HStack(spacing: 10) {
                shapeButton(.rounded, icon: "square")
                shapeButton(.circle, icon: "circle")
                shapeButton(.ticket, icon: "ticket")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(AppTheme.softBorder))
    }

    private func shapeButton(_ shape: StickerShape, icon: String) -> some View {
        let isSelected = selectedShape == shape

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedShape = shape
            }
        } label: {
            Label(shape.rawValue, systemImage: icon)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(isSelected ? AppTheme.primaryText : AppTheme.secondaryText)
                .background(AppTheme.elevatedSurface.opacity(isSelected ? 0.95 : 0.55))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? AppTheme.violet : AppTheme.softBorder, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func singleStickerSection(for destinations: [TravelDestination]) -> some View {
        let destination = selectedDestination(from: destinations)

        return VStack(spacing: 16) {
            if let destination {
                let imageURLs = stickerImageURLs(for: destination)
                let selectedImageURL = selectedStickerImageURL(from: imageURLs)

                VStack(spacing: 10) {
                    TabView(selection: $selectedStickerImageIndex) {
                        ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, imageURL in
                            StickerPreview(
                                imageURL: imageURL,
                                title: destination.name,
                                shape: selectedShape,
                                palette: selectedPalette
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 28)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: imageURLs.count > 1 ? .automatic : .never))
                    .frame(height: 388)
                    .onChange(of: imageURLs.count) { _, count in
                        selectedStickerImageIndex = min(selectedStickerImageIndex, max(count - 1, 0))
                    }

                    if imageURLs.count > 1 {
                        imageCarouselControls(count: imageURLs.count)
                    }
                }

                Button {
                    Task {
                        if let selectedImageURL {
                            await saveSingleSticker(
                                destination,
                                imageURL: selectedImageURL,
                                imageIndex: selectedStickerImageIndex
                            )
                        }
                    }
                } label: {
                    Label(isRendering ? "Preparing" : "Save Sticker", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.violet)
                .disabled(isRendering || selectedImageURL == nil)
            }
        }
    }

    private func stickerPackSection(for destinations: [TravelDestination]) -> some View {
        let destination = selectedDestination(from: destinations)

        return VStack(alignment: .leading, spacing: 16) {
            if let destination {
                let imageURLs = stickerImageURLs(for: destination)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                    ForEach(Array(imageURLs.enumerated()), id: \.offset) { _, imageURL in
                        StickerPreview(
                            imageURL: imageURL,
                            title: destination.name,
                            shape: selectedShape,
                            palette: selectedPalette,
                            isCompact: true
                        )
                    }
                }

                Button {
                    Task {
                        await saveStickerPack(destination, imageURLs: imageURLs)
                    }
                } label: {
                    Label(isRendering ? "Preparing Pack" : "Save \(destination.name) Pack", systemImage: "square.and.arrow.up.on.square")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.violet)
                .disabled(isRendering || imageURLs.isEmpty)
            }
        }
    }

    private func selectedDestinationBinding(for destinations: [TravelDestination]) -> Binding<TravelDestination.ID> {
        Binding {
            selectedDestinationID ?? destinations[0].id
        } set: { newValue in
            selectedDestinationID = newValue
            selectedStickerImageIndex = 0
        }
    }

    private func selectedDestination(from destinations: [TravelDestination]) -> TravelDestination? {
        if let selectedDestinationID,
           let destination = destinations.first(where: { $0.id == selectedDestinationID }) {
            return destination
        }

        return destinations.first
    }

    private func stickerImageURLs(for destination: TravelDestination) -> [URL] {
        var imageURLs: [URL] = []

        if let displayImageURL = destination.displayImageURL {
            imageURLs.append(displayImageURL)
        }

        imageURLs.append(contentsOf: destination.displayGalleryURLs)

        var seenURLs: Set<URL> = []
        return imageURLs.filter { seenURLs.insert($0).inserted }
    }

    private func selectedStickerImageURL(from imageURLs: [URL]) -> URL? {
        guard !imageURLs.isEmpty else {
            return nil
        }

        return imageURLs[min(selectedStickerImageIndex, imageURLs.count - 1)]
    }

    private func imageCarouselControls(count: Int) -> some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    selectedStickerImageIndex = max(selectedStickerImageIndex - 1, 0)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .frame(width: 42, height: 34)
            }
            .buttonStyle(.bordered)
            .disabled(selectedStickerImageIndex == 0)

            Text("\(min(selectedStickerImageIndex + 1, count)) / \(count)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.secondaryText)
                .frame(minWidth: 54)

            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    selectedStickerImageIndex = min(selectedStickerImageIndex + 1, count - 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .frame(width: 42, height: 34)
            }
            .buttonStyle(.bordered)
            .disabled(selectedStickerImageIndex >= count - 1)
        }
    }

    @MainActor
    private func saveSingleSticker(_ destination: TravelDestination, imageURL: URL, imageIndex: Int) async {
        isRendering = true
        defer { isRendering = false }

        guard let export = await renderExport(for: destination, imageURL: imageURL, imageIndex: imageIndex) else {
            exportMessage = "Unable to prepare sticker. Please try again."
            return
        }

        presentShareSheet(for: [export])
    }

    @MainActor
    private func saveStickerPack(_ destination: TravelDestination, imageURLs: [URL]) async {
        isRendering = true
        defer { isRendering = false }

        var exports: [StickerExport] = []
        for (index, imageURL) in imageURLs.enumerated() {
            if let export = await renderExport(for: destination, imageURL: imageURL, imageIndex: index) {
                exports.append(export)
            }
        }

        guard !exports.isEmpty else {
            exportMessage = "Unable to prepare sticker pack. Please try again."
            return
        }

        presentShareSheet(for: exports)
    }

    @MainActor
    private func renderExport(for destination: TravelDestination, imageURL: URL, imageIndex: Int) async -> StickerExport? {
        guard let image = try? await ImagePipeline.shared.image(for: imageURL) else {
            return nil
        }

        let sticker = StickerCanvas(
            image: image,
            title: destination.name,
            shape: selectedShape,
            palette: selectedPalette,
            includesPreviewBackground: false
        )
        .frame(width: 512, height: 512)

        let renderer = ImageRenderer(content: sticker)
        renderer.scale = 3

        guard let renderedImage = renderer.uiImage,
              let imageData = renderedImage.pngData() else {
            return nil
        }

        let imageName = imageIndex == 0 ? "main" : "gallery-\(imageIndex)"
        let filename = "\(destination.id)-sticker-\(imageName).png"
        return StickerExport(filename: filename, imageData: imageData)
    }

    @MainActor
    private func presentShareSheet(for exports: [StickerExport]) {
        let imageItems = exports.compactMap { UIImage(data: $0.imageData) }

        guard imageItems.count == exports.count else {
            exportMessage = "Unable to prepare sticker export. Please try again."
            return
        }

        let successMessage = exports.count == 1
            ? "Sticker saved to Photos"
            : "\(exports.count) stickers saved to Photos"
        let filesSuccessMessage = exports.count == 1
            ? "Sticker saved to Files"
            : "\(exports.count) stickers saved to Files"
        let genericSuccessMessage = exports.count == 1
            ? "Sticker exported"
            : "\(exports.count) stickers exported"

        sharePayload = StickerSharePayload(
            activityItems: imageItems,
            photosSuccessMessage: successMessage,
            filesSuccessMessage: filesSuccessMessage,
            genericSuccessMessage: genericSuccessMessage
        )
    }

    private func exportCompletionMessage(
        for activityType: UIActivity.ActivityType?,
        payload: StickerSharePayload
    ) -> String {
        guard let activityType else {
            return payload.genericSuccessMessage
        }

        let rawValue = activityType.rawValue.lowercased()

        if activityType == .saveToCameraRoll || rawValue.contains("camera") || rawValue.contains("photo") {
            return payload.photosSuccessMessage
        }

        if rawValue.contains("file") || rawValue.contains("document") || rawValue.contains("icloud") {
            return payload.filesSuccessMessage
        }

        return payload.genericSuccessMessage
    }

    @MainActor
    private func showExportToast(_ message: String, isSuccess: Bool = true) {
        let nextToast = StickerToast(message: message, isSuccess: isSuccess)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            toast = nextToast
        }

        Task {
            try? await Task.sleep(for: .seconds(2))

            await MainActor.run {
                guard toast?.id == nextToast.id else { return }

                withAnimation(.easeInOut(duration: 0.2)) {
                    toast = nil
                }
            }
        }
    }

    @MainActor
    private func fetchDestinationsIfNeeded() async {
        guard viewState.shouldPerformInitialLoad else {
            return
        }

        await fetchDestinations()
    }

    @MainActor
    private func fetchDestinations(shouldShowLoading: Bool = true) async {
        let existingDestinations = viewState.loadedValue

        if shouldShowLoading, existingDestinations == nil {
            viewState = .loading
        }

        do {
            let destinations: [TravelDestination] = try await firestoreService.fetchData(collection: "TravelDestinations")
            selectedDestinationID = selectedDestinationID ?? destinations.first?.id
            viewState = .loaded(destinations)
            Task(priority: .utility) {
                await ImagePipeline.shared.prefetch(destinations.flatMap(stickerImageURLs(for:)))
            }
        } catch {
            if let existingDestinations {
                viewState = .loaded(existingDestinations)
            } else {
                viewState = .failed(error.localizedDescription)
            }
        }
    }
}

struct StickerPreview: View {
    let imageURL: URL
    let title: String
    let shape: StickerShape
    let palette: StickerPalette
    var isCompact = false

    var body: some View {
        ZStack {
            shapedImage(
                RemoteImageView(url: imageURL, contentMode: .fill)
                    .frame(width: isCompact ? 150 : 280, height: isCompact ? 150 : 280)
            )
            .shadow(color: palette.shadowColor, radius: isCompact ? 8 : 16, x: 0, y: isCompact ? 4 : 10)

            VStack {
                Spacer()
                StickerTitleBadge(title: title, isCompact: isCompact)
                    .padding(.bottom, isCompact ? 10 : 18)
            }
        }
        .frame(width: isCompact ? 170 : 320, height: isCompact ? 180 : 340)
    }

    @ViewBuilder
    private func shapedImage(_ image: some View) -> some View {
        let lineWidth = isCompact ? 5.0 : 8.0

        switch shape {
        case .rounded:
            image
                .clipShape(RoundedRectangle(cornerRadius: 42))
                .overlay(RoundedRectangle(cornerRadius: 42).stroke(.white, lineWidth: lineWidth))
        case .circle:
            image
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: lineWidth))
        case .ticket:
            let shape = UnevenRoundedRectangle(
                topLeadingRadius: 50,
                bottomLeadingRadius: 18,
                bottomTrailingRadius: 50,
                topTrailingRadius: 18
            )
            image
                .clipShape(shape)
                .overlay(shape.stroke(.white, lineWidth: lineWidth))
        }
    }
}

struct StickerCanvas: View {
    let image: UIImage
    let title: String
    let shape: StickerShape
    let palette: StickerPalette
    var includesPreviewBackground = true

    var body: some View {
        ZStack {
            Color.clear

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 390, height: 390)
                .modifier(StickerShapeModifier(shape: shape, lineWidth: 14))
                .shadow(color: palette.shadowColor, radius: 24, x: 0, y: 14)

            VStack {
                Spacer()
                StickerTitleBadge(title: title, isCompact: false)
                    .scaleEffect(1.3)
                    .padding(.bottom, 46)
            }
        }
    }

}

struct StickerTitleBadge: View {
    let title: String
    var isCompact = false

    var body: some View {
        HStack(spacing: isCompact ? 7 : 12) {
            Circle()
                .fill(AppTheme.violet)
                .frame(width: isCompact ? 5 : 8, height: isCompact ? 5 : 8)

            Text(title.uppercased())
                .font(isCompact ? .caption.bold() : .headline.bold())
                .foregroundStyle(Color.black.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.58)

            Circle()
                .fill(AppTheme.violet)
                .frame(width: isCompact ? 5 : 8, height: isCompact ? 5 : 8)
        }
        .padding(.horizontal, isCompact ? 10 : 18)
        .padding(.vertical, isCompact ? 6 : 9)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.18), radius: isCompact ? 5 : 10, x: 0, y: isCompact ? 2 : 5)
    }
}

struct StickerShapeModifier: ViewModifier {
    let shape: StickerShape
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        switch shape {
        case .rounded:
            content
                .clipShape(RoundedRectangle(cornerRadius: 64))
                .overlay(RoundedRectangle(cornerRadius: 64).stroke(.white, lineWidth: lineWidth))
        case .circle:
            content
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: lineWidth))
        case .ticket:
            let shape = UnevenRoundedRectangle(
                topLeadingRadius: 82,
                bottomLeadingRadius: 28,
                bottomTrailingRadius: 82,
                topTrailingRadius: 28
            )
            content
                .clipShape(shape)
                .overlay(shape.stroke(.white, lineWidth: lineWidth))
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let onExportComplete: (UIActivity.ActivityType?, Bool, Error?) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        controller.completionWithItemsHandler = { activityType, completed, _, error in
            DispatchQueue.main.async {
                onExportComplete(activityType, completed, error)
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct StickerToastView: View {
    let toast: StickerToast

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(toast.isSuccess ? AppTheme.gold : AppTheme.coral)

            Text(toast.message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
    }
}

private extension StickerPalette {
    var background: LinearGradient {
        switch self {
        case .ocean:
            LinearGradient(colors: [AppTheme.accent, AppTheme.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sunset:
            LinearGradient(colors: [AppTheme.coral, AppTheme.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .forest:
            LinearGradient(colors: [AppTheme.mint, Color(red: 0.12, green: 0.28, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var shadowColor: Color {
        switch self {
        case .ocean:
            AppTheme.accent.opacity(0.34)
        case .sunset:
            AppTheme.coral.opacity(0.34)
        case .forest:
            AppTheme.mint.opacity(0.34)
        }
    }
}
