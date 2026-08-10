using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class RotateCommands
{
    public static string RotateElement(Document doc, JsonElement args)
    {
        var elementId = GetLong(args, "element_id");
        if (!elementId.HasValue || elementId.Value <= 0)
            return Err("element_id é obrigatório");

        var angleDegrees = GetDouble(args, "angle_degrees");
        if (!angleDegrees.HasValue || angleDegrees.Value == 0)
            return Err("angle_degrees é obrigatório (em graus)");

        var axisName = GetString(args, "axis") ?? "Z";

        try
        {
            using var trans = new Transaction(doc, "Vitruvius: rotacionar elemento");
            trans.Start();

            var element = doc.GetElement(new ElementId(elementId.Value));
            if (element == null)
            {
                trans.RollBack();
                return Err($"Elemento {elementId} não encontrado");
            }

            if (!(element.Location is LocationCurve || element.Location is LocationPoint))
            {
                trans.RollBack();
                return Err("Elemento não suporta rotação (sem LocationCurve ou LocationPoint)");
            }

            var angleRadians = angleDegrees.Value * Math.PI / 180.0;

            XYZ axis = axisName.ToUpperInvariant() switch
            {
                "X" => XYZ.BasisX,
                "Y" => XYZ.BasisY,
                "Z" => XYZ.BasisZ,
                _ => XYZ.BasisZ
            };

            var center = element.Location switch
            {
                LocationPoint lp => lp.Point,
                LocationCurve lc => lc.Curve.Evaluate(0.5, true),
                _ => XYZ.Zero
            };

            ElementTransformUtils.RotateElement(doc, element.Id, Line.CreateBound(center, center.Add(axis)), angleRadians);

            trans.Commit();

            return Ok(new
            {
                element_id = elementId.Value,
                angle_degrees = angleDegrees.Value,
                axis = axisName,
                status = "rotacionado"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao rotacionar: {ex.Message}");
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

    private static string GetString(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.String
            ? prop.GetString()
            : null;

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
