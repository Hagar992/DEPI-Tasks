using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarShowroomMVC_Tssk_2_.Migrations
{
    /// <inheritdoc />
    public partial class AddImageLinkToCar : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageLink",
                table: "Cars",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageLink",
                table: "Cars");
        }
    }
}
