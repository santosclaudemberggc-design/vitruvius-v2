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

    public static string SelectByCategory(Document doc, JsonElement args)
    {
        if (doc == null)
            return Err("Nenhum documento ativo no Revit");

        try
        {
            if (!args.TryGetProperty("category_name", out var catNameEl) || catNameEl.ValueKind == JsonValueKind.Null)
                return Err("Parâmetro 'category_name' obrigatório (ex: 'Paredes', 'Portas', 'Mobiliário')");

            var categoryName = catNameEl.GetString();
            if (string.IsNullOrWhiteSpace(categoryName))
                return Err("'category_name' não pode estar vazio");

            // Buscar a categoria por nome
            var category = doc.Settings.Categories.Cast<Category>()
                .FirstOrDefault(c => c.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));

            if (category == null)
                return Err($"Categoria '{categoryName}' não encontrada no Revit. Verifique a grafia.");

            // Usar FilteredElementCollector com ElementCategoryFilter
            var collector = new FilteredElementCollector(doc)
                .WherePasses(new ElementCategoryFilter(category.Id));

            var elements = collector
                .Select(el => new
                {
                    element_id = el.Id.Value,
                    name = el.Name,
                    category = el.Category?.Name ?? categoryName,
                    element_type = el.GetType().Name
                })
                .ToList();

            return Ok(new
            {
                count = elements.Count,
                category = categoryName,
                elements,
                status = elements.Count == 0 ? "nenhum_resultado" : "sucesso"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro ao selecionar por categoria: {ex.Message}");
        }
    }

    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });

    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
