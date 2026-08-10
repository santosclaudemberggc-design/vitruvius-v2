using System.Net;
using System.Text;
using System.Text.Json;
using Autodesk.Revit.UI;

namespace VitruviusAddin;

public class HttpBridge
{
    private readonly HttpListener _listener;
    private readonly RevitCommandHandler _handler;
    private readonly ExternalEvent _event;
    private volatile bool _running;

    public HttpBridge(RevitCommandHandler handler, ExternalEvent externalEvent, int port)
    {
        _handler = handler;
        _event = externalEvent;
        _listener = new HttpListener();
        _listener.Prefixes.Add($"http://localhost:{port}/");
    }

    public void Start()
    {
        _listener.Start();
        _running = true;
        Task.Run(Loop);
    }

    public void Stop()
    {
        _running = false;
        try { _listener.Stop(); } catch { }
    }

    private async Task Loop()
    {
        while (_running)
        {
            try
            {
                var ctx = await _listener.GetContextAsync();
                _ = HandleRequest(ctx);
            }
            catch (HttpListenerException) when (!_running) { break; }
            catch { }
        }
    }

    private async Task HandleRequest(HttpListenerContext ctx)
    {
        try
        {
            using var reader = new StreamReader(ctx.Request.InputStream);
            var json = await reader.ReadToEndAsync();

            if (string.IsNullOrEmpty(json))
            {
                throw new Exception("JSON vazio");
            }

            var doc = JsonDocument.Parse(json);

            if (!doc.RootElement.TryGetProperty("action", out var actionElem))
            {
                throw new Exception("Propriedade 'action' não encontrada");
            }

            var action = actionElem.GetString();

            if (!doc.RootElement.TryGetProperty("args", out var argsElem))
            {
                throw new Exception("Propriedade 'args' não encontrada");
            }

            _handler.Job = new() { Action = action, Args = argsElem };
            _event.Raise();

            // Aguardar execução do handler (max 5 segundos)
            for (int i = 0; i < 50; i++)
            {
                if (_handler.Response != "{\"ok\":false,\"error\":\"Nenhuma ação\"}")
                    break;
                await Task.Delay(100);
            }

            var response = Encoding.UTF8.GetBytes(_handler.Response);
            ctx.Response.ContentLength64 = response.Length;
            await ctx.Response.OutputStream.WriteAsync(response);
        }
        catch (Exception ex)
        {
            var err = Encoding.UTF8.GetBytes($"{{\"error\": \"{ex.Message}\"}}");
            ctx.Response.ContentLength64 = err.Length;
            await ctx.Response.OutputStream.WriteAsync(err);
        }
        finally
        {
            ctx.Response.Close();
        }
    }
}
