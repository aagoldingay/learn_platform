using System.Collections.Generic;
using System.Text.Json;
using data;

namespace sender
{
    public class Sender
    {
        private int count;
        private IDataGenerator dataGenerator;

        public Sender(IDataGenerator dataGenerator, int count)
        {
            this.dataGenerator = dataGenerator;
            this.count = count;
        }

        public List<DataModel> GetData()
        {
            var dataList = new List<DataModel>();
            for (int i = 0; i < count; i++)
                dataList.Add(dataGenerator.GenerateModel(i));
                
            return dataList;
        }

        public string PrepareDataForSend(List<DataModel> dataList)
        {
            return JsonSerializer.Serialize(dataList);
        }
    }
}
