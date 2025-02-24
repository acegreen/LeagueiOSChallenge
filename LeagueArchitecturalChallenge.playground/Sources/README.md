# LEAGUE - DOCUMENT/CLAIMS MANAGEMENT ARCHITECTURE

## Solution Overview
The architecture was designed with a focus on scalability, maintainability, and user experience in a document/claims management context. I chose MVVM with protocol-oriented design to ensure clear separation of concerns while maintaining flexibility for future extensions and testing. The offline-first approach with local storage prioritization addresses potential connectivity issues and ensures a responsive user experience. The modular component structure, shared between documents and claims handling, reduces code duplication while maintaining specific business logic where needed.

#### NOTE: MVVM was also chosen to show an alternative solution to the original coding challenge which was MVC 

## 1. Architecture Flow Diagram
![Architecture Flow Diagram](./LeagueArchitecturalChallenge.playground/Resources/LeagueArchitecturalChallenge.drawio)

### Document Model
- ID
- Type (enum: ID, gym membership, beneficiary form)
- Image URLs
- Metadata
  - Document type
  - Additional notes
- Status (pending, verified, rejected)
- Upload date

### Claim Model
- ID
- Type (enum: medical, dental, vision)
- Supporting document references
- Metadata
  - Dollar amount
  - Additional notes
- Status
- Submission date

## 2. Architectural Components

### App Layer
- Dependency management
- Environment setup
- Initial routing

### View Layer
- DocumentListView/ClaimListView
- DocumentDetailView/ClaimDetailView
- DocumentUploadView/ClaimUploadView

### ViewModel Layer
- DocumentListViewModel/ClaimListViewModel
- DocumentDetailViewModel/ClaimDetailViewModel
- DocumentUploadViewModel/ClaimUploadViewModel

### Storage Layer
- `StorageManagerProtocol` protocol (Generic Protocol)
  - `func save<T: Encodable & Sendable>(_ item: T, key: String) async throws`
  - `func fetch<T: Decodable & Sendable>(_ key: String) async throws -> T`
  - `func remove(key: String) async throws`

- `StorageManager` class (Concrete Implementation)
  - In-memory storage using `[String: Data]`
  - Generic CRUD operations with type safety
  - Document-specific convenience methods:
    - `func fetchDocuments() async throws -> [Document]`
    - `func saveDocument(_ document: Document) async throws`
    - `func removeDocument(_ documentId: String) async throws`

## 3. Key Flows

### Documents/Claims List Flow
- Displays list of documents/claims in a scrollable list
- Each row shows document type, status, and preview
- "+" button to add new document/claim
- Tapping item navigates to detail view

### Document/Claim Details Flow
- Shows full document/claim information
- Displays image/PDF preview
- Shows metadata (type, status, notes)
- Edit functionality for updating metadata
- Resubmission capability for rejected items
- Delete functionality
- Share document capability

### Add Document/Claim Flow
- Image selection via camera or photo library
- Required metadata input fields
- Validation of all required fields
- Preview before submission
- Progress indicator during upload

## 4. Error Handling

### Types of Errors
- Error Handling
  - `StorageError` enum
    - `.notFound`
    - `.saveFailed`
    - `.invalidData`
  - `ValidationError` enum
    - `.invalidDocumentType`
    - `.invalidImageFormat`
    - `.missingRequiredFields`
  - `ImageProcessingError` enum
    - `.compressionFailed`
    - `.invalidFormat`
    - `.sizeTooLarge`

### Error Recovery
- Retry mechanisms
- Error state UI
- User feedback

## 5. Testing Strategy

### Unit Tests
- ViewModel logic
- Storage operations
- Data models

### Integration Tests
- View-ViewModel integration
- Storage operations

### UI Tests
- User flows
- Error states
- Loading states

## 6. Reusability Considerations

### Shared Components
- Base upload view
- Image picker
- Status indicators
- List views
- Detail views

### Protocol-Based Design
- Generic Protocols
- Clear interfaces
- Dependency injection

## 7. Assumptions
- Offline-first architecture
- Document/Claims storage handled locally
- User authentication handled separately
- Device has camera access

## 8. Future Considerations
- Remote sync capabilities
- Document expiry notifications
- Advanced search/filtering
- OCR for documents
- Multi-platform support
- Accessibility improvements

## 9. Architectural Patterns

### MVVM
- Clear separation of concerns
- Better testability
- SwiftUI compatibility

### Dependency Injection
- Environment-based DI
- Protocol-based abstractions
- Testable components

### Protocol-Oriented Design
- Flexible implementation
- Easy to extend
- Type-safe operations
