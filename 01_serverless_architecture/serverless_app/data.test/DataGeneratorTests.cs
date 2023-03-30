using NUnit.Framework;

namespace data.test
{
    public class DataGeneratorTests
    {
        [Test]
        [TestCase(0, 0, "Mouse", 81, "n/a")]
        [TestCase(45, 1, "Pen", 2, "Deliver only one per day")]
        [TestCase(431, 2, "Pigeon", 28, "Deliver ASAP")]
        public void DataGenerator_GenerateModel_Success(int randomSeed, int modelId, string expectedItem, int expectedQuantity, string expectedNote)
        {
            var generator = new DataGenerator(randomSeed);
            var model = generator.GenerateModel(modelId);

            Assert.That(model.Id, Is.EqualTo(modelId));
            Assert.That(model.Item, Is.EqualTo(expectedItem));
            Assert.That(model.Quantity, Is.EqualTo(expectedQuantity));
            Assert.That(model.Note, Is.EqualTo(expectedNote));
        }
    }
}