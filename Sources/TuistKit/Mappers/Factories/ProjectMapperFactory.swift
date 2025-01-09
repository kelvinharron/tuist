import Foundation
import TuistAutomation
import TuistCore
import TuistDependencies
import TuistGenerator
import TuistLoader
import TuistSupport

/// The protocol describes an interface for getting project mappers.
protocol ProjectMapperFactorying {
    /// Returns the default project mapper.
    /// - Parameter config: The project configuration
    /// - Returns: A project mapper instance.
    func `default`() -> [ProjectMapping]

    /// Returns a project mapper for automation.
    /// - Parameter config: The project configuration.
    /// - Parameter skipUITests: Whether UI tests should be skipped.
    /// - Returns: An instance of a project mapper.
    func automation(skipUITests: Bool) -> [ProjectMapping]
}

public final class ProjectMapperFactory: ProjectMapperFactorying {
    private let contentHasher: ContentHashing

    public init(contentHasher: ContentHashing = ContentHasher()) {
        self.contentHasher = contentHasher
    }

    public func automation(skipUITests: Bool) -> [ProjectMapping] {
        var mappers: [ProjectMapping] = []
        mappers += self.default()

        mappers.append(
            SourceRootPathProjectMapper()
        )

        if skipUITests {
            mappers.append(
                SkipUITestsProjectMapper()
            )
        }

        return mappers
    }

    public func `default`() -> [ProjectMapping] {
        var mappers: [ProjectMapping] = []

        // Delete current derived
        mappers.append(DeleteDerivedDirectoryProjectMapper())

        // Namespace generator
        mappers.append(
            SynthesizedResourceInterfaceProjectMapper(
                contentHasher: contentHasher
            )
        )

        // Logfile noise suppression
        mappers.append(TargetActionDisableShowEnvVarsProjectMapper())

        // Support for resources in libraries
        mappers.append(ResourcesProjectMapper(contentHasher: ContentHasher()))

        // Auto-generation of schemes
        // This mapper should follow the ResourcesProjectMapper in order to create schemes for bundles and cache them.
        mappers.append(AutogeneratedSchemesProjectMapper())

        // Info Plist
        mappers.append(GenerateInfoPlistProjectMapper())

        // Entitlements
        mappers.append(GenerateEntitlementsProjectMapper())

        // Privacy Manifest
        mappers.append(GeneratePrivacyManifestProjectMapper())

        // Template macros
        mappers.append(IDETemplateMacrosMapper())

        return mappers
    }
}
