using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace SKAO.web.Roadmaps
{
    public partial class Index : Page
    {
        // Connection string is defined once in Web.config (name: SKAOConnection).
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["SKAOConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPaths();
            }
        }

        /// <summary>
        /// Returns a usable image URL for a path card. Uses the CareerPaths.ImageUrl
        /// value when present, and falls back to a default banner otherwise.
        /// </summary>
        protected string ImgSrc(object imageUrl)
        {
            string url = imageUrl == null || imageUrl == DBNull.Value ? "" : imageUrl.ToString().Trim();
            if (string.IsNullOrEmpty(url))
                return ResolveUrl("~/Assets/img/pentest.png");
            // Stored as an app-relative path (e.g. ~/Assets/img/soc.png).
            return url.StartsWith("~") ? ResolveUrl(url) : url;
        }

        /// <summary>
        /// Reads every career path from the CareerPaths table and binds the
        /// repeater so one card is rendered per path.
        /// </summary>
        private void BindPaths()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT PathID, PathName, Description FROM CareerPaths ORDER BY PathID", conn);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    rptPaths.DataSource = reader;
                    rptPaths.DataBind();
                }
                else
                {
                    lblEmpty.Visible = true;
                }
            }
        }
    }
}
