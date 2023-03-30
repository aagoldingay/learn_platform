namespace data
{
    public class DataModel
    {
        public int Id { get; set; }
        public string Item { get; set; }
        public int Quantity { get; set; }
        public string Note { get; set; }

        public DataModel() { }

        public DataModel(int id, string item, int quantity, string note)
        {
            Id = id;
            Item = item;
            Quantity = quantity;
            Note = note;
        }
    }
}
