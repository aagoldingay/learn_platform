using NUnit.Framework;

namespace data.test
{
    public class DataModelTests
    {
        [Test]
        [TestCase(0, "item", 1, "note")]
        public void DataModel_Attributes_AreAccessible(int id, string item, int quantity, string note)
        {
            var obj = new DataModel(id, item, quantity, note);
            
            Assert.That(obj.Id, Is.EqualTo(id));
            Assert.That(obj.Item, Is.EqualTo(item));
            Assert.That(obj.Quantity, Is.EqualTo(quantity));
            Assert.That(obj.Note, Is.EqualTo(note));
        }
    }
}