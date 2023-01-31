using NUnit.Framework;
using System.Collections.Generic;
using data;

namespace receiver.test
{
    public class ReceiverTests
    {

        [Test]
        public void ReadData_Success()
        {
            var json = "[{\"Id\":1,\"Item\":\"test\",\"Quantity\":10,\"Note\":\"note\"}]";
            var receiver = new Receiver();
            var result = receiver.ReadData(json);

            Assert.That(result.Count, Is.EqualTo(1));
            Assert.That(result[0].Id, Is.EqualTo(1));
            Assert.That(result[0].Item, Is.EqualTo("test"));
            Assert.That(result[0].Quantity, Is.EqualTo(10));
            Assert.That(result[0].Note, Is.EqualTo("note"));
        }

        [Test]
        public void CheckAsap_ShouldFindOne()
        {
            var data = new List<DataModel>(){
                new DataModel(0, "Paper", 50, "Deliver ASAP"),
                new DataModel(1, "Keyboard", 25, "Gift wrap please"),
                new DataModel(2, "Pen", 6000, "n/a")
            };

            var receiver = new Receiver();
            var num = receiver.CheckAsap(data);

            Assert.That(num, Is.EqualTo(1));
        }
    }
}