using System.Linq;
using System.Text.Json;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;

namespace VitruviusAddin;

public static class SelectionCommands
{
    public static string GetSelection(UIDocument uidoc, JsonElement args)
    {
        if (uidoc == null)
            return Err("Nenhum documento ativo no Revit");

        try
        {
            var doc = uidoc.Document;
            var ids = uidoc.Selection.GetElementIds();

            var elements = ids
                .Select(id => doc.GetElement(id))
                .Where(el => el != null)
                .Select(el => new
                {
                    element_id = el.Id.Value,
                    name = el.Name,
                    category = el.Category?.Name ?? "Desconhecida"
                })
                .ToList();

            return Ok(new
            {
                count = elements.Count,
                elements,
                element_id = elements.Count == 1 ? elements[0].element_id : (long?)null,
                status = elements.Count == 0 ? "vazio" : "sucesso"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao ler seleção: {ex.Message}");
        }
    }

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
