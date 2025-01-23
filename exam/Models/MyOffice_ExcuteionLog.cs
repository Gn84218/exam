namespace exam.Models
{
    public class MyOffice_ExcuteionLog
    {
        public long DeLog_AutoID { get; set; } // bigint, IDENTITY(1,1)
        public string DeLog_StoredPrograms { get; set; } // nvarchar(120)
        public Guid DeLog_GroupID { get; set; } // uniqueidentifier
        public bool DeLog_isCustomDebug { get; set; } // bit
        public string DeLog_ExecutionProgram { get; set; } // nvarchar(120)
        public string DeLog_ExecutionInfo { get; set; } // nvarchar(max)
        public bool? DeLog_verifyNeeded { get; set; } // bit, 可為 NULL
        public DateTime DeLog_ExDateTime { get; set; } // datetime
    }
}
