using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class FamilyCommands
{
    public static string LoadFamily(Document doc, JsonElement args)
    {
        var familyPath = GetString(args, "family_path");
        if (string.IsNullOrWhiteSpace(familyPath))
            return Err("family_path é obrigatório");

        if (!File.Exists(familyPath))
            return Err($"Arquivo não encontrado: {familyPath}");

        if (!familyPath.EndsWith(".rfa", StringComparison.OrdinalIgnoreCase))
            return Err("Arquivo deve ser .rfa");

        try
        {
            using var trans = new Transaction(doc, "Vitruvius: carregar família");
            trans.Start();

            var familyName = Path.GetFileNameWithoutExtension(familyPath);
            var existing = new FilteredElementCollector(doc)
                .OfClass(typeof(Family))
                .Cast<Family>()
                .FirstOrDefault(f => f.Name.Equals(familyName, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                trans.Commit();
                return Ok(new { status = "já_carregada", family_id = existing.Id.Value, family_name = existing.Name });
            }

            if (!doc.LoadFamily(familyPath, out var family))
            {
                trans.RollBack();
                return Err("Falha ao carregar família");
            }

            var symbol = new FilteredElementCollector(doc)
                .OfClass(typeof(FamilySymbol))
                .Cast<FamilySymbol>()
                .FirstOrDefault(fs => fs.Family.Id == family.Id);

            if (symbol != null && !symbol.IsActive)
                symbol.Activate();

            trans.Commit();

            return Ok(new
            {
                status = "carregada",
                family_id = family.Id.Value,
                family_name = family.Name,
                symbol_id = symbol?.Id.Value,
                symbol_name = symbol?.Name,
                category = family.FamilyCategory?.Name ?? "Unknown"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro: {ex.Message}");
        }
    }

    private static string GetString(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.String
            ? prop.GetString()
            : null;

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
