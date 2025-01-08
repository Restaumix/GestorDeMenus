import Foundation

class PersistenceHelper {
    
    /// Guarda un objeto codificable en un archivo JSON
    static func save<T: Encodable>(_ object: T, to filename: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(object)
            if let url = getDocumentsDirectory()?.appendingPathComponent(filename) {
                try data.write(to: url)
                print("Guardado exitoso en \(filename)")
            }
        } catch {
            print("Error al guardar el archivo \(filename): \(error.localizedDescription)")
        }
    }
    
    /// Carga un objeto codificable desde un archivo JSON
    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        if let url = getDocumentsDirectory()?.appendingPathComponent(filename) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode(type, from: data)
            } catch {
                print("Error al cargar el archivo \(filename): \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /// Obtiene la URL del directorio de documentos
    private static func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
