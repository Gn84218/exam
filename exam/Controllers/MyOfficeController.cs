using exam.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using exam.Data;
using System.Data;
using Newtonsoft.Json;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Data;
using System.Data.SqlClient;
using SqlConnection = System.Data.SqlClient.SqlConnection;
using SqlCommand = System.Data.SqlClient.SqlCommand;
using SqlParameter = System.Data.SqlClient.SqlParameter;
using exam.Service;

namespace BackendExamHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MyOfficeController : ControllerBase
    {
        private readonly IMyOfficeService _myOfficeService;

        public MyOfficeController(IMyOfficeService myOfficeService)
        {
            _myOfficeService = myOfficeService;
        }

        // CREATE operation
        [HttpPost("CreateACPD")]
        public async Task<IActionResult> CreateACPD([FromBody] MyOffice_ACPD acpd)
        {
            var result = await _myOfficeService.CreateACPD(acpd);
            return Ok(result);
        }

        // READ operation
        [HttpGet("GetACPD/{sid}")]
        public async Task<IActionResult> GetACPD(string sid)
        {
            var result = await _myOfficeService.GetACPD(sid);
            if (result == null)
            {
                return NotFound();
            }
            return Ok(result);
        }

        // UPDATE operation
        [HttpPut("UpdateACPD")]
        public async Task<IActionResult> UpdateACPD([FromBody] MyOffice_ACPD acpd)
        {
            var result = await _myOfficeService.UpdateACPD(acpd);
            return Ok(result);
        }

        // DELETE operation
        [HttpDelete("DeleteACPD/{sid}")]
        public async Task<IActionResult> DeleteACPD(string sid)
        {
            var result = await _myOfficeService.DeleteACPD(sid);
            return Ok(result);
        }

        // READ execution logs
        [HttpGet("GetExecutionLogs/{groupId}")]
        public async Task<IActionResult> GetExecutionLogs(Guid groupId)
        {
            var result = await _myOfficeService.GetExecutionLogs(groupId);
            return Ok(result);
        }
    }
}