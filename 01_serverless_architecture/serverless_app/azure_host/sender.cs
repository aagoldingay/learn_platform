using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using sender;
using data;

namespace azure_host
{
    public static class sender
    {
        [FunctionName("sender")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Sender function initiated.");

            var rand = new Random();
            var count = rand.Next(10);
            var sender = new Sender(new DataGenerator(rand.Next()), count);
            var payload = sender.PrepareDataForSend(sender.GetData());
            
            HttpClient client = new HttpClient();
            var url = Environment.GetEnvironmentVariable("RECEIVERADDR");
            var result = await client.PostAsync(url, new StringContent(payload));

            if (result.IsSuccessStatusCode)
                log.LogInformation("receiver responded successfully");
            
            return new OkResult();
        }
    }
}
