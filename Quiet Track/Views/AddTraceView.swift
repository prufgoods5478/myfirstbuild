import SwiftUI
import PhotosUI

struct AddTraceView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: UIImage?
    @State private var selectedTag: Tag?
    @State private var selectedColor: MoodColor = MoodColor.presets[0]
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var currentStep: AddStep = .photo
    @State private var isSaving = false
    
    enum AddStep {
        case photo
        case tag
        case color
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    progressView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    TabView(selection: $currentStep) {
                        photoStepView
                            .tag(AddStep.photo)
                        
                        tagStepView
                            .tag(AddStep.tag)
                        
                        colorStepView
                            .tag(AddStep.color)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.4), value: currentStep)
                    
                    bottomButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Trace")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $selectedImage)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
    
    private var progressView: some View {
        HStack(spacing: 8) {
            ForEach([AddStep.photo, .tag, .color], id: \.self) { step in
                Capsule()
                    .fill(stepColor(for: step))
                    .frame(height: 4)
            }
        }
    }
    
    private func stepColor(for step: AddStep) -> Color {
        switch step {
        case .photo:
            return AppTheme.accent
        case .tag:
            return currentStep == .tag || currentStep == .color ? AppTheme.accent : Color.adaptiveSecondaryText.opacity(0.2)
        case .color:
            return currentStep == .color ? AppTheme.accent : Color.adaptiveSecondaryText.opacity(0.2)
        }
    }
    
    private var photoStepView: some View {
        VStack(spacing: 24) {
            Text("Capture the trace")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryText)
                .padding(.top, 30)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                    .overlay(
                        Button {
                            selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white, Color.black.opacity(0.5))
                        }
                        .padding(12),
                        alignment: .topTrailing
                    )
            } else {
                VStack(spacing: 20) {
                    Button {
                        showCamera = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40, weight: .light))
                            Text("Camera")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color.adaptivePrimaryText)
                        .frame(width: 140, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.adaptiveCardBackground)
                                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
                        )
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 40, weight: .light))
                            Text("Gallery")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color.adaptivePrimaryText)
                        .frame(width: 140, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.adaptiveCardBackground)
                                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var tagStepView: some View {
        VStack(spacing: 24) {
            Text("Choose a tag")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryText)
                .padding(.top, 30)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(dataManager.tags) { tag in
                    TagButton(
                        tag: tag,
                        isSelected: selectedTag?.id == tag.id,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTag = tag
                            }
                        }
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var colorStepView: some View {
        VStack(spacing: 24) {
            Text("Choose your mood")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryText)
                .padding(.top, 30)
            
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Circle()
                        .fill(selectedColor.color)
                        .frame(width: 32, height: 32)
                        .shadow(color: selectedColor.color.opacity(0.5), radius: 8, y: 2)
                        .padding(8)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MoodColor.presets) { color in
                    ColorButton(
                        color: color,
                        isSelected: selectedColor.id == color.id,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedColor = color
                            }
                        }
                    )
                }
            }
            
            Text(selectedColor.name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 16) {
            if currentStep != .photo {
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        switch currentStep {
                        case .tag: currentStep = .photo
                        case .color: currentStep = .tag
                        default: break
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.adaptiveCardBackground)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
                        )
                }
            }
            
            Spacer()
            
            Button {
                if currentStep == .color {
                    saveTrace()
                } else {
                    withAnimation(.spring(response: 0.4)) {
                        switch currentStep {
                        case .photo: currentStep = .tag
                        case .tag: currentStep = .color
                        default: break
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(currentStep == .color ? "Save" : "Next")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        
                        if currentStep != .color {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(canProceed ? AppTheme.headerGradient : LinearGradient(colors: [Color.gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: canProceed ? AppTheme.accent.opacity(0.4) : .clear, radius: 12, y: 6)
            }
            .disabled(!canProceed || isSaving)
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .photo: return selectedImage != nil
        case .tag: return selectedTag != nil
        case .color: return true
        }
    }
    
    private func saveTrace() {
        guard let image = selectedImage,
              let tag = selectedTag else { return }
        
        isSaving = true
        
        Task {
            guard let photoPath = PhotoManager.shared.savePhoto(image) else {
                isSaving = false
                return
            }
            
            let trace = TraceEntry(
                tagIcon: tag.icon,
                colorHex: selectedColor.hex,
                photoPath: photoPath
            )
            
            await MainActor.run {
                dataManager.addTrace(trace)
                isSaving = false
                dismiss()
            }
        }
    }
}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.accent : Color.adaptiveCardBackground)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.06), radius: isSelected ? 12 : 6, y: isSelected ? 4 : 2)
                    
                    Image(systemName: tag.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color.adaptivePrimaryText)
                }
                
                Text(tag.name)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .lineLimit(1)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1)
    }
}

struct ColorButton: View {
    let color: MoodColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 48, height: 48)
                    .shadow(color: color.color.opacity(0.5), radius: isSelected ? 10 : 4, y: isSelected ? 4 : 2)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 42, height: 42)
                }
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1)
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddTraceView(dataManager: DataManager.shared)
}
