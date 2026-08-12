using System.Text.Json;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;

namespace VitruviusAddin;

public class RevitCommandHandler : IExternalEventHandler
{
    public class JobData
    {
        public string Action { get; set; }
        public JsonElement Args { get; set; }
    }

    public JobData Job { get; set; } = new();
    public string Response { get; set; } = "{\"ok\":false,\"error\":\"Nenhuma ação\"}";

    public void Execute(UIApplication app)
    {
        try
        {
            var doc = app.ActiveUIDocument.Document;

            // Debug: retornar informação sobre Job.Action
            if (string.IsNullOrEmpty(Job.Action))
            {
                Response = JsonResult(false, $"DEBUG: Job.Action vazio. Job={System.Text.Json.JsonSerializer.Serialize(Job)}");
                return;
            }

            Response = Job.Action switch
            {
                "load_family" => FamilyCommands.LoadFamily(doc, Job.Args),
                "rotate_element" => RotateCommands.RotateElement(doc, Job.Args),
                "move_element" => MoveCommands.MoveElement(doc, Job.Args),
                "get_selection" => SelectionCommands.GetSelection(app.ActiveUIDocument, Job.Args),
                "get_parameter" => ParameterCommands.GetParameter(doc, Job.Args),
                "set_parameter" => ParameterCommands.SetParameter(doc, Job.Args),
                "get_element_info" => InfoCommands.GetElementInfo(doc, Job.Args),
                "select_by_category" => SelectionCommands.SelectByCategory(doc, Job.Args),
                _ => JsonResult(false, $"Ação desconhecida: '{Job.Action}'")
            };
        }
        catch (Exception ex)
        {
            Response = JsonResult(false, ex.Message);
        }
    }

    public string GetName() => "VitruviusCommandHandler";

    private static string JsonResult(bool ok, object data)
    {
        var obj = ok ? (object)new { ok, result = data } : new { ok, error = data };
        return System.Text.Json.JsonSerializer.Serialize(obj);
    }
}
