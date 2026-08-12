using System.Linq;
using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class InfoCommands
{
    public static string GetElementInfo(Document doc, JsonElement args)
    {
        var elementId = GetLong(args, "element_id");
        if (!elementId.HasValue || elementId.Value <= 0)
            return Err("element_id é obrigatório");

        try
        {
            var element = doc.GetElement(new ElementId(elementId.Value));
            if (element == null)
                return Err($"Elemento {elementId} não encontrado");

            var info = new
            {
                element_id = element.Id.Value,
                name = element.Name,
                category = element.Category?.Name ?? "Desconhecida",
                element_type = GetElementType(element),
                family_name = GetFamilyName(element),
                host_id = GetHostId(element),
                is_instance = element is Instance,
                is_type = element is ElementType,
                level = GetLevelName(element),
                location = GetLocation(element),
                material_id = GetMaterialId(element),
                parameters_count = element.Parameters.Size
            };

            return Ok(info);
        }
        catch (Exception ex)
        {
            return Err($"Erro ao ler informações do elemento: {ex.Message}");
        }
    }

    private static string GetElementType(Element element)
    {
        var typeId = element.GetTypeId();
        if (typeId.Value <= 0) return "Sem tipo";

        var type = element.Document.GetElement(typeId);
        return type?.Name ?? "Tipo desconhecido";
    }

    private static string GetFamilyName(Element element)
    {
        if (element is FamilyInstance fi)
            return fi.Symbol?.Family?.Name ?? "Sem família";
        return null;
    }

    private static long? GetHostId(Element element)
    {
        if (element is FamilyInstance fi && fi.Host != null)
            return fi.Host.Id.Value;
        return null;
    }

    private static string GetLevelName(Element element)
    {
        if (element.LevelId != null && element.LevelId.Value > 0)
        {
            var level = element.Document.GetElement(element.LevelId);
            return level?.Name ?? "Nível desconhecido";
        }
        return null;
    }

    private static object GetLocation(Element element)
    {
        try
        {
            if (element.Location is LocationPoint lp && lp.Point != null)
            {
                return new
                {
                    type = "Point",
                    x = Math.Round(lp.Point.X, 2),
                    y = Math.Round(lp.Point.Y, 2),
                    z = Math.Round(lp.Point.Z, 2)
                };
            }
            else if (element.Location is LocationCurve lc && lc.Curve != null)
            {
                var start = lc.Curve.GetEndPoint(0);
                var end = lc.Curve.GetEndPoint(1);
                return new
                {
                    type = "Curve",
                    start_x = Math.Round(start.X, 2),
                    start_y = Math.Round(start.Y, 2),
                    start_z = Math.Round(start.Z, 2),
                    end_x = Math.Round(end.X, 2),
                    end_y = Math.Round(end.Y, 2),
                    end_z = Math.Round(end.Z, 2)
                };
            }
        }
        catch { }
        return null;
    }

    private static long? GetMaterialId(Element element)
    {
        try
        {
            var matParam = element.LookupParameter("Material");
            if (matParam != null && matParam.StorageType == StorageType.ElementId)
            {
                var matId = matParam.AsElementId();
                if (matId.Value > 0)
                    return matId.Value;
            }
        }
        catch { }
        return null;
    }

    private static long? GetLong(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (long?)prop.GetInt64()
            : null;

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
