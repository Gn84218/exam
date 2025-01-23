using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using exam.Models;

namespace exam.Data
{

    public class MyOfficeContext : DbContext
    {
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MyOffice_ACPD>(entity =>
            {
                entity.HasKey(e => e.ACPD_SID); // 设置 AcPDSid 为主键
                entity.Property(e => e.ACPD_SID)
                    .IsRequired()
                    .HasMaxLength(20); // 确保长度与数据库一致
            });

            modelBuilder.Entity<MyOffice_ExcuteionLog>(entity =>
            {
                entity.HasKey(e => e.DeLog_AutoID); // 设置 DelogAutoId 为主键
                entity.Property(e => e.DeLog_AutoID)
                    .IsRequired()
                    .HasMaxLength(20); // 确保长度与数据库一致
            });
        }


        public MyOfficeContext(DbContextOptions<MyOfficeContext> options)
            : base(options)
        {
        }
        public DbSet<exam.Models.MyOffice_ACPD> MyOffice_ACPD { get; set; }
      
        public DbSet<exam.Models.MyOffice_ExcuteionLog> MyOffice_ExcuteionLog { get; set; }
    }
}
