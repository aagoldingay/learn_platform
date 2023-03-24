using Google.Cloud.Functions.Framework;
using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using receiver;

namespace gcp_host
{
    public class receiver : IHttpFunction
    {
        public async Task HandleAsync(HttpContext context)
        {
            var req = context.Request;

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var receiver = new Receiver();
            var num = receiver.CheckAsap(receiver.ReadData(requestBody));

            Console.WriteLine($"{num} ASAP orders to process");

            await context.Response.WriteAsync(new OkResult().ToString());
        }
    }
}
