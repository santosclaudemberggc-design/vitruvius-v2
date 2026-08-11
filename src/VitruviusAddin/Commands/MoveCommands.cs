using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class MoveCommands
{
    public static string MoveElement(Document doc, JsonElement args)
    {
        var elementId = GetLong(args, "element_id");
        if (!elementId.HasValue || elementId.Value <= 0)
            return Err("element_id é obrigatório");

        var dx = GetDouble(args, "dx") ?? 0;
        var dy = GetDouble(args, "dy") ?? 0;
        var dz = GetDouble(args, "dz") ?? 0;

        if (dx == 0 && dy == 0 && dz == 0)
            return Err("Informe ao menos um deslocamento (dx, dy ou dz) diferente de zero");

        try
        {
            using var trans = new Transaction(doc, "Vitruvius: mover elemento");
            trans.Start();

            var element = doc.GetElement(new ElementId(elementId.Value));
            if (element == null)
            {
                trans.RollBack();
                return Err($"Elemento {elementId} não encontrado");
            }

            if (element.Location == null)
            {
                trans.RollBack();
                return Err("Elemento não possui Location e não pode ser movido");
            }

            var translation = new XYZ(dx, dy, dz);
            ElementTransformUtils.MoveElement(doc, element.Id, translation);

            trans.Commit();

            return Ok(new
            {
                element_id = elementId.Value,
                dx,
                dy,
                dz,
                status = "movido"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao mover: {ex.Message}");
        }
    }

    private static long? GetLong(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (long?)prop.GetInt64()
            : null;

    private static double? GetDouble(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (double?)prop.GetDouble()
            : null;

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
