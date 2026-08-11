using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class ParameterCommands
{
    public static string GetParameter(Document doc, JsonElement args)
    {
        var elementId = GetLong(args, "element_id");
        if (!elementId.HasValue || elementId.Value <= 0)
            return Err("element_id é obrigatório");

        var parameterName = GetString(args, "parameter_name");
        if (string.IsNullOrWhiteSpace(parameterName))
            return Err("parameter_name é obrigatório");

        try
        {
            var element = doc.GetElement(new ElementId(elementId.Value));
            if (element == null)
                return Err($"Elemento {elementId} não encontrado");

            var parameter = element.LookupParameter(parameterName);
            if (parameter == null)
                return Err($"Parâmetro '{parameterName}' não encontrado no elemento {elementId}");

            object value = parameter.StorageType switch
            {
                StorageType.Double => parameter.AsDouble(),
                StorageType.Integer => parameter.AsInteger(),
                StorageType.String => parameter.AsString(),
                StorageType.ElementId => parameter.AsElementId().Value,
                _ => parameter.AsValueString()
            };

            return Ok(new
            {
                element_id = elementId.Value,
                parameter_name = parameterName,
                value,
                value_string = parameter.AsValueString(),
                storage_type = parameter.StorageType.ToString(),
                is_read_only = parameter.IsReadOnly
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao ler parâmetro: {ex.Message}");
        }
    }

    public static string SetParameter(Document doc, JsonElement args)
    {
        var elementId = GetLong(args, "element_id");
        if (!elementId.HasValue || elementId.Value <= 0)
            return Err("element_id é obrigatório");

        var parameterName = GetString(args, "parameter_name");
        if (string.IsNullOrWhiteSpace(parameterName))
            return Err("parameter_name é obrigatório");

        if (!args.TryGetProperty("value", out var valueProp))
            return Err("value é obrigatório");

        try
        {
            using var trans = new Transaction(doc, "Vitruvius: definir parâmetro");
            trans.Start();

            var element = doc.GetElement(new ElementId(elementId.Value));
            if (element == null)
            {
                trans.RollBack();
                return Err($"Elemento {elementId} não encontrado");
            }

            var parameter = element.LookupParameter(parameterName);
            if (parameter == null)
            {
                trans.RollBack();
                return Err($"Parâmetro '{parameterName}' não encontrado no elemento {elementId}");
            }

            if (parameter.IsReadOnly)
            {
                trans.RollBack();
                return Err($"Parâmetro '{parameterName}' é somente leitura");
            }

            bool success;
            switch (parameter.StorageType)
            {
                case StorageType.Double:
                    if (valueProp.ValueKind != JsonValueKind.Number)
                    {
                        trans.RollBack();
                        return Err("value deve ser numérico para este parâmetro (Double)");
                    }
                    success = parameter.Set(valueProp.GetDouble());
                    break;

                case StorageType.Integer:
                    if (valueProp.ValueKind != JsonValueKind.Number)
                    {
                        trans.RollBack();
                        return Err("value deve ser numérico para este parâmetro (Integer)");
                    }
                    success = parameter.Set(valueProp.GetInt32());
                    break;

                case StorageType.String:
                    if (valueProp.ValueKind != JsonValueKind.String)
                    {
                        trans.RollBack();
                        return Err("value deve ser texto para este parâmetro (String)");
                    }
                    success = parameter.Set(valueProp.GetString());
                    break;

                case StorageType.ElementId:
                    if (valueProp.ValueKind != JsonValueKind.Number)
                    {
                        trans.RollBack();
                        return Err("value deve ser um element_id numérico para este parâmetro (ElementId)");
                    }
                    success = parameter.Set(new ElementId(valueProp.GetInt64()));
                    break;

                default:
                    trans.RollBack();
                    return Err("Tipo de parâmetro não suportado");
            }

            if (!success)
            {
                trans.RollBack();
                return Err("Falha ao definir o parâmetro");
            }

            trans.Commit();

            return Ok(new
            {
                element_id = elementId.Value,
                parameter_name = parameterName,
                status = "definido"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao definir parâmetro: {ex.Message}");
        }
    }

    private static long? GetLong(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (long?)prop.GetInt64()
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
