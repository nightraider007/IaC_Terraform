variable "dbapp_environment" {
    type=map(object(
        {
            server=map(object(
                {
                dbname=string
                sku=string
                }
            ))           
            
        }
    )
    )
}