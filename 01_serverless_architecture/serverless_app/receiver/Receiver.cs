using System.Collections.Generic;
using System.Text.Json;
using data;

namespace receiver
{
    public class Receiver
    {

        public Receiver() { }

        public int CheckAsap(List<DataModel> data)
        {
            var n = 0;
            foreach (var d in data)
            {
                if (d.Note.Contains("ASAP"))
                    n++;
            }
            return n;
        }

        public List<DataModel> ReadData(string payload)
        {
            return JsonSerializer.Deserialize<List<DataModel>>(payload);
        }
    }
}
