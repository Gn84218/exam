using exam.Models;

namespace exam.Service
{
    public interface IMyOfficeService
    {
        Task<MyOffice_ACPD> CreateACPD(MyOffice_ACPD acpd);
        Task<MyOffice_ACPD> GetACPD(string sid);
        Task<MyOffice_ACPD> UpdateACPD(MyOffice_ACPD acpd);
        Task<bool> DeleteACPD(string sid);
        Task<List<MyOffice_ExcuteionLog>> GetExecutionLogs(Guid groupId);
    }

    public class MyOfficeService : IMyOfficeService
    {
        public async Task<MyOffice_ACPD> CreateACPD(MyOffice_ACPD acpd)
        {
            // 實際插入數據到資料庫的邏輯
            return await Task.FromResult(acpd); // 假設成功插入後返回
        }

        public async Task<MyOffice_ACPD> GetACPD(string sid)
        {
            // 查詢資料庫，根據 SID 查找
            return await Task.FromResult(new MyOffice_ACPD { ACPD_SID = sid }); // 假設找到並返回
        }

        public async Task<MyOffice_ACPD> UpdateACPD(MyOffice_ACPD acpd)
        {
            // 更新資料庫中的數據
            return await Task.FromResult(acpd); // 假設成功更新
        }

        public async Task<bool> DeleteACPD(string sid)
        {
            // 刪除資料庫中的數據
            return await Task.FromResult(true); // 假設成功刪除
        }

        public async Task<List<MyOffice_ExcuteionLog>> GetExecutionLogs(Guid groupId)
        {
            // 查詢執行記錄
            return await Task.FromResult(new List<MyOffice_ExcuteionLog>());
        }
    }

}
