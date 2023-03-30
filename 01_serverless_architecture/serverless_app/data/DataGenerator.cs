using System;

namespace data
{
    public class DataGenerator : IDataGenerator
    {
        private Random random;
        private static readonly string[] items = { "Paper", "Pen", "Keyboard", "Mouse", "Pigeon" };
        private static readonly string[] notes = {
            "Deliver ASAP",
            "Deliver only one per day",
            "Gift wrap please",
            "DO NOT BEND",
            "n/a",
            "Leave in a safe place"
        };

        public DataGenerator(int randomSeed)
        {
            random = new Random(randomSeed);
        }

        public DataModel GenerateModel(int id)
        {
            return new DataModel(
                id,
                items[random.Next(items.Length)],
                random.Next(100),
                notes[random.Next(notes.Length)]
            );
        }
    }
}