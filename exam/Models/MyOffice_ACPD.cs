namespace exam.Models
{
    public class MyOffice_ACPD
    {
        public string ACPD_SID { get; set; } // char(20)
        public string ACPD_Cname { get; set; } // nvarchar(60)
        public string ACPD_Ename { get; set; } // nvarchar(40)
        public string ACPD_Sname { get; set; } // nvarchar(40)
        public string ACPD_Email { get; set; } // nvarchar(60)
        public byte? ACPD_Status { get; set; } // tinyint
        public bool? ACPD_Stop { get; set; } // bit
        public string ACPD_StopMemo { get; set; } // nvarchar(60)
        public string ACPD_LoginID { get; set; } // nvarchar(30)
        public string ACPD_LoginPWD { get; set; } // nvarchar(60)
        public string ACPD_Memo { get; set; } // nvarchar(600)
        public DateTime? ACPD_NowDateTime { get; set; } // datetime
        public string ACPD_NowID { get; set; } // nvarchar(20)
        public DateTime? ACPD_UPDDateTime { get; set; } // datetime
        public string ACPD_UPDID { get; set; } // nvarchar(20)
    }
}
