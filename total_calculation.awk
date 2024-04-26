BEGIN{
    FS=","
    OFS=","
}
{
    if(NR == 1)
    {
        print $0 , "total" # appends "total" to the header of main.csv
    }
    else
    {
        total = 0;
        for (i = 3 ; i <= NF ; i++) # starts adding marks from the third field
        {
            if($i != a)
            {
                total += int($i)
            }
        }
        print $0,total
    }
}