import SwiftUI
import PlaygroundSupport

// MARK: - Models
struct Document: Identifiable, Codable, Sendable {
    let id: String
    let type: DocumentType
    var metadata: DocumentMetadata
    var status: VerificationStatus
    var imageUrls: [URL]
}

struct Claim: Identifiable, Codable, Sendable {
    let id: String
    let type: ClaimType
    var metadata: ClaimMetadata
    var status: VerificationStatus
    var supportingDocuments: [Document]
}

enum DocumentType: String, Codable, CaseIterable {
    case identification, gymMembership, beneficiaryForm
}

enum ClaimType: String, Codable {
    case medical, dental, vision
}

enum VerificationStatus: String, Codable {
    case pending, verified, rejected
}

struct DocumentMetadata: Codable, Sendable {
    var type: String
    var notes: String
}

struct ClaimMetadata: Codable, Sendable {
    var amount: Decimal
    var notes: String
}

// MARK: - Error Types
enum StorageError: Error {
    case notFound
    case saveFailed
    case invalidData
}

enum ValidationError: Error {
    case invalidDocumentType
    case invalidImageFormat
    case missingRequiredFields
}

enum ImageProcessingError: Error {
    case compressionFailed
    case invalidFormat
    case sizeTooLarge
}

// MARK: - API Protocol
protocol APIClientProtocol: Sendable {
    func fetchDocuments() async throws -> [Document]
    func uploadDocument(_ document: Document) async throws
    func fetchClaims() async throws -> [Claim]
    func uploadClaim(_ claim: Claim) async throws
}

// MARK: - Storage Protocol
protocol StorageManagerProtocol {
    func save<T: Encodable & Sendable>(_ item: T, key: String) async throws
    func fetch<T: Decodable & Sendable>(_ key: String) async throws -> T
    func remove(key: String) async throws
}

// MARK: - APIClient Implementation
actor APIClient: APIClientProtocol, Observable {
    func fetchDocuments() async throws -> [Document] {
        // API implementation
        []
    }
    
    func uploadDocument(_ document: Document) async throws {
        // API implementation
    }
    
    func fetchClaims() async throws -> [Claim] {
        // API implementation
        []
    }
    
    func uploadClaim(_ claim: Claim) async throws {
        // API implementation
    }
}

// MARK: - Document Storage Manager
actor StorageManager: StorageManagerProtocol, Observable {
    private let documentsKey = "documents"
    private var storage: [String: Data] = [:] // Simple in-memory storage for demo
    
    func save<T: Encodable & Sendable>(_ item: T, key: String) async throws {
        let data = try JSONEncoder().encode(item)
        storage[key] = data
    }
    
    func fetch<T: Decodable & Sendable>(_ key: String) async throws -> T {
        guard let data = storage[key] else {
            throw StorageError.notFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func remove(key: String) async throws {
        storage.removeValue(forKey: key)
    }
    
    // Document-specific methods
    func fetchDocuments() async throws -> [Document] {
        (try? await fetch(documentsKey) as [Document]) ?? []
    }
    
    func saveDocument(_ document: Document) async throws {
        var documents = try await fetchDocuments()
        documents.append(document)
        try await save(documents, key: documentsKey)
    }
    
    func removeDocument(_ documentId: String) async throws {
        var documents = try await fetchDocuments()
        documents.removeAll { $0.id == documentId }
        try await save(documents, key: documentsKey)
    }
}

// MARK: - DocumentListViewModel
@Observable class DocumentListViewModel {
    var documents: [Document] = []
    var error: Error?
    var isLoading = false

    private let storage: StorageManager
    
    init(storage: StorageManager) {
        self.storage = storage
    }

    @MainActor
    func loadDocuments() {
        isLoading = true
        
        Task {
            do {
                documents = try await storage.fetchDocuments()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }

    @MainActor
    func deleteDocument(_ document: Document) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            try await storage.removeDocument(document.id)
            documents.removeAll { $0.id == document.id }
        } catch {
            self.error = error
            throw error
        }
    }

    @MainActor
    func refreshDocuments() async {
        isLoading = true
        defer { isLoading = false }

        do {
            documents = try await storage.fetchDocuments()
        } catch {
            self.error = error
        }
    }
}

// MARK: - DocumentListView
struct DocumentListView: View {
    @Environment(StorageManager.self) private var storageManager
    @State private var viewModel: DocumentListViewModel
    
    init(storage: StorageManager) {
        _viewModel = State(initialValue: DocumentListViewModel(storage: storage))
    }
    
    var body: some View {
        DocumentListContent(viewModel: viewModel)
            .onAppear {
                viewModel.loadDocuments()
            }
    }
}

// Separate content view to keep the hierarchy clean
private struct DocumentListContent: View {
    @Environment(StorageManager.self) private var storageManager
    let viewModel: DocumentListViewModel
    @State private var showingAddDocument = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List(viewModel.documents) { document in
                        NavigationLink(destination: DocumentDetailView(document: document)) {
                            DocumentRowView(document: document)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    try? await viewModel.deleteDocument(document)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refreshDocuments()
                    }
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddDocument = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument) {
                DocumentUploadView(onDocumentAdded: {
                    Task {
                        await viewModel.refreshDocuments()
                        print("List refreshed after adding document")
                        print("Updated documents count: \(viewModel.documents.count)")
                    }
                })
            }
            .onAppear {
                print("DocumentListContent appeared")
                print("Current documents count: \(viewModel.documents.count)")
                viewModel.loadDocuments()
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }

    struct DocumentRowView: View {
        let document: Document

        var body: some View {
            VStack(alignment: .leading) {
                Text(document.type.rawValue.uppercased())
                    .font(.headline)
                Text(document.metadata.notes)
                    .font(.subheadline)
                Text(document.status.rawValue)
                    .font(.caption)
            }
        }
    }
}

struct DocumentDetailView: View {
    @Environment(StorageManager.self) private var storageManager
    let document: Document
    @State private var isEditing = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Document Preview
                if let firstImageUrl = document.imageUrls.first {
                    AsyncImage(url: firstImageUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxHeight: 300)
                }
                
                // Metadata Section
                VStack(alignment: .leading, spacing: 12) {
                    MetadataRow(title: "Type", value: document.type.rawValue)
                    MetadataRow(title: "Status", value: document.status.rawValue)
                    MetadataRow(title: "Notes", value: document.metadata.notes)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Document Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            DocumentEditView(document: document)
        }
    }

    // Add MetadataRow view
    struct MetadataRow: View {
        let title: String
        let value: String

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

struct DocumentUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageManager.self) private var storageManager
    @State private var documentType: DocumentType = .identification
    @State private var notes: String = ""
    @State private var error: Error?
    
    // Add a callback for when document is added
    var onDocumentAdded: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Document Type", selection: $documentType) {
                    ForEach(DocumentType.allCases, id: \.self) { type in
                        Text(type.rawValue.uppercased()).tag(type)
                    }
                }
                
                TextField("Notes", text: $notes)
                
                Button("Add Image") {
                    // Image picker would go here
                }
            }
            .navigationTitle("Upload Document")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveDocument()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error Saving", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                Text(error?.localizedDescription ?? "")
            }
        }
    }
    
    private func saveDocument() async {
        let newDocument = Document(
            id: UUID().uuidString,
            type: documentType,
            metadata: DocumentMetadata(type: documentType.rawValue, notes: notes),
            status: .pending,
            imageUrls: []
        )
        
        do {
            try await storageManager.saveDocument(newDocument)
            print("Document saved successfully ID:", newDocument.id)
            // Call the callback before dismissing
            onDocumentAdded?()
            dismiss()
        } catch {
            print("Error saving document: \(error)")
            self.error = error
        }
    }
}

// Add DocumentEditView
struct DocumentEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageManager.self) private var storageManager
    let document: Document
    @State private var notes: String
    
    init(document: Document) {
        self.document = document
        _notes = State(initialValue: document.metadata.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Notes", text: $notes)
            }
            .navigationTitle("Edit Document")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - DocumentManagementApp
struct DocumentManagementApp: View {
    @State private var storageManager = StorageManager()
    
    var body: some View {
        DocumentListView(storage: storageManager)
            .environment(storageManager)
            .tint(.purple)
    }
}

// Update the hosting controller
let hostingController = UIHostingController(
    rootView: DocumentManagementApp()
)

// Set a reasonable size for the playground view
hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = hostingController
