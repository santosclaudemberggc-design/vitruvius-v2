using Autodesk.Revit.UI;

namespace VitruviusAddin;

public class App : IExternalApplication
{
    private const int Port = 48884;
    private HttpBridge _bridge;
    private ExternalEvent _event;

    public Result OnStartup(UIControlledApplication application)
    {
        try
        {
            var handler = new RevitCommandHandler();
            _event = ExternalEvent.Create(handler);
            _bridge = new HttpBridge(handler, _event, Port);
            _bridge.Start();
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            TaskDialog.Show("Vitruvius", $"Erro ao iniciar: {ex.Message}");
            return Result.Failed;
        }
    }

    public Result OnShutdown(UIControlledApplication application)
    {
        _bridge?.Stop();
        _event?.Dispose();
        return Result.Succeeded;
    }
}
