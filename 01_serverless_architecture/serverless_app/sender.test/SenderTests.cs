using Moq;
using NUnit.Framework;
using System.Collections.Generic;
using data;

namespace sender.test
{
    public class SenderTests
    {
        [Test]
        public void GetData_CreatesOneModel_Success()
        {
            var testSeed = 1;
            var sender = new Sender(new DataGenerator(testSeed), 1);
            var result = sender.GetData();

            Assert.That(result.Count, Is.EqualTo(1));

            Assert.That(result[0].Id, Is.EqualTo(0));
            Assert.That(result[0].Item, Is.EqualTo("Pen"));
            Assert.That(result[0].Quantity, Is.EqualTo(11));
            Assert.That(result[0].Note, Is.EqualTo("Gift wrap please"));
        }

        [Test]
        public void GetData_CreatesMultipleModels_Success()
        {
            var sender = new Sender(new DataGenerator(1), 2);
            var result = sender.GetData();

            Assert.That(result.Count, Is.EqualTo(2));
            Assert.That(result[0].Id, Is.EqualTo(0));
            Assert.That(result[1].Id, Is.EqualTo(1));
        }

        [Test]
        public void GetData_OneModel_MustInvokeModelGenerator_Once()
        {
            var mockDataGenerator = new Mock<IDataGenerator>();
            var fakeDataModel = new DataModel(1, "test", 10, "note");
            mockDataGenerator.Setup(m => m.GenerateModel(It.IsAny<int>())).Returns(fakeDataModel);

            var sender = new Sender(mockDataGenerator.Object, 1);
            var data = sender.GetData();

            Assert.That(data.Count, Is.EqualTo(1));
            Assert.That(data[0].Id, Is.EqualTo(fakeDataModel.Id));
            Assert.That(data[0].Item, Is.EqualTo(fakeDataModel.Item));
            Assert.That(data[0].Quantity, Is.EqualTo(fakeDataModel.Quantity));
            Assert.That(data[0].Note, Is.EqualTo(fakeDataModel.Note));

            mockDataGenerator.Verify(m => m.GenerateModel(It.IsAny<int>()), Times.Once());
        }


        [Test]
        public void GetData_TwoModels_MustInvokeModelGenerator_Twice()
        {
            var mockDataGenerator = new Mock<IDataGenerator>();
            var fakeDataModel = new DataModel(1, "test", 10, "note");
            mockDataGenerator.Setup(m => m.GenerateModel(It.IsAny<int>())).Returns(fakeDataModel);

            var sender = new Sender(mockDataGenerator.Object, 2);
            var data = sender.GetData();

            Assert.That(data.Count, Is.EqualTo(2));

            mockDataGenerator.Verify(m => m.GenerateModel(It.IsAny<int>()), Times.Exactly(2));
        }

        [Test]
        public void PrepareData_OneModel_ReturnsValidJson()
        {
            var validJson = "[{\"Id\":1,\"Item\":\"test\",\"Quantity\":10,\"Note\":\"note\"}]";
            var sender = new Sender(new DataGenerator(1), 1);
            var data = new List<DataModel>();
            data.Add(new DataModel(1, "test", 10, "note"));

            var payload = sender.PrepareDataForSend(data);
            Assert.That(payload, Is.EqualTo(validJson));
        }

        [Test]
        public void PrepareData_TwoModels_ReturnsValidJson()
        {
            var validJson = "[{\"Id\":1,\"Item\":\"test\",\"Quantity\":10,\"Note\":\"note\"},{\"Id\":5,\"Item\":\"Paper\",\"Quantity\":2,\"Note\":\"Deliver ASAP\"}]";
            var sender = new Sender(new DataGenerator(1), 1);
            var data = new List<DataModel>();
            data.Add(new DataModel(1, "test", 10, "note"));
            data.Add(new DataModel(5, "Paper", 2, "Deliver ASAP"));

            var payload = sender.PrepareDataForSend(data);
            Assert.That(payload, Is.EqualTo(validJson));
        }
    }
}