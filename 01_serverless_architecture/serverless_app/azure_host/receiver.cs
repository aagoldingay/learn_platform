using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using receiver;

namespace azure_host
{
    public static class receiver
    {
        [FunctionName("receiver")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Receiver function initiated.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var receiver = new Receiver();
            var num = receiver.CheckAsap(receiver.ReadData(requestBody));

            log.LogInformation($"{num} ASAP orders to process");

            return new OkResult();
        }
    }
}
