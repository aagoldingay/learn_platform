using System;
using System.Net.Http;
using Google.Cloud.Functions.Framework;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using data;
using sender;

namespace gcp_host
{
    public class sender : IHttpFunction
    {
        public async Task HandleAsync(HttpContext context)
        {
            var rand = new Random();
            var count = rand.Next(10);
            var sender = new Sender(new DataGenerator(rand.Next()), count);
            var payload = sender.PrepareDataForSend(sender.GetData());
            
            HttpClient client = new HttpClient();
            var url = Environment.GetEnvironmentVariable("RECEIVERADDR");
            Console.WriteLine(url);
            var result = await client.PostAsync(url, new StringContent(payload));

            if (result.IsSuccessStatusCode)
                await context.Response.WriteAsync("receiver responded successfully");            
        }
    }
}
