using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SKAO.web.Shared;

namespace SKAO.web.Roadmaps
{
    public partial class Detail : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["SKAOConnection"].ConnectionString;

        // The career path this page is showing, taken from the query string (?id=).
        private int PathID
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // No valid path id -> send the visitor back to the listing.
            if (PathID == 0)
            {
                Response.Redirect("Index.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadHeader();
                lnkQuiz.NavigateUrl = "Quiz.aspx?id=" + PathID;
                pnlLoginNotice.Visible = !AuthHelper.IsLoggedIn();
                BindRoadmap();
                BindMedia();
            }
        }

        /// <summary>Fills the path name and description from CareerPaths.</summary>
        private void LoadHeader()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT PathName, Description FROM CareerPaths WHERE PathID = @PathID", conn);
                cmd.Parameters.AddWithValue("@PathID", PathID);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    lblPathName.Text = Server.HtmlEncode(reader["PathName"].ToString());
                    lblPathDesc.Text = Server.HtmlEncode(reader["Description"].ToString());
                }
                else
                {
                    // id points to a path that does not exist
                    Response.Redirect("Index.aspx");
                }
            }
        }

        /// <summary>
        /// Reads the ordered certifications for this path. A LEFT JOIN on
        /// UserProgress pulls in the current member's status for each cert
        /// (NULL when they are not enrolled, or when nobody is logged in).
        /// The ORDER BY StepOrder is what turns a set of certs into a sequence.
        /// </summary>
        private void BindRoadmap()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query =
                    "SELECT c.CertID, c.CertName, c.Provider, c.Level, c.Description, c.Website, " +
                    "       pc.StepOrder, up.Status AS MyStatus " +
                    "FROM PathCertifications pc " +
                    "JOIN Certifications c ON pc.CertID = c.CertID " +
                    "LEFT JOIN UserProgress up ON up.CertID = c.CertID AND up.UserID = @UserID " +
                    "WHERE pc.PathID = @PathID " +
                    "ORDER BY pc.StepOrder";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@PathID", PathID);
                cmd.Parameters.AddWithValue("@UserID", AuthHelper.GetUserID());

                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    lblNoCerts.Visible = true;
                    rptRoadmap.Visible = false;
                }
                else
                {
                    lblNoCerts.Visible = false;
                    rptRoadmap.Visible = true;
                    rptRoadmap.DataSource = dt;
                    rptRoadmap.DataBind();
                }
            }
        }

        /// <summary>
        /// Per-row set-up: show the current status and reveal the Enrol / Complete /
        /// Unenrol buttons only to logged-in members.
        /// </summary>
        protected void rptRoadmap_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            Label lblStatus = (Label)e.Item.FindControl("lblStatus");
            Panel pnlActions = (Panel)e.Item.FindControl("pnlActions");
            Button btnEnrol = (Button)e.Item.FindControl("btnEnrol");
            Button btnComplete = (Button)e.Item.FindControl("btnComplete");
            Button btnUnenrol = (Button)e.Item.FindControl("btnUnenrol");

            bool loggedIn = AuthHelper.IsLoggedIn();
            pnlActions.Visible = loggedIn;

            string status = row["MyStatus"] == DBNull.Value ? null : row["MyStatus"].ToString();

            if (string.IsNullOrEmpty(status))
            {
                lblStatus.Text = "<span class='rm-badge rm-stat-none'>Not enrolled</span>";
                // Only Enrol makes sense before the member has a progress row.
                btnComplete.Visible = false;
                btnUnenrol.Visible = false;
            }
            else
            {
                lblStatus.Text = "<span class='rm-badge rm-stat-" + status + "'>" + FriendlyStatus(status) + "</span>";
                btnEnrol.Visible = false;                       // already enrolled
                btnComplete.Visible = status != "Completed";    // hide once done
                btnUnenrol.Visible = true;
            }
        }

        /// <summary>
        /// Renders the certification's official website as a link (or nothing when
        /// no URL is stored). Used by Detail.aspx to satisfy the "links" requirement.
        /// </summary>
        protected string CertLink(object website)
        {
            if (website == null || website == DBNull.Value) return "";
            string url = website.ToString().Trim();
            if (string.IsNullOrEmpty(url)) return "";
            string safe = Server.HtmlEncode(url);
            return "<a class='rm-link' href='" + safe + "' target='_blank' rel='noopener'>Official page &#8599;</a>";
        }

        private static string FriendlyStatus(string status)
        {
            switch (status)
            {
                case "InProgress": return "In Progress";
                case "NotStarted": return "Not Started";
                default: return status;
            }
        }

        /// <summary>
        /// Handles the three CRUD actions on the UserProgress table:
        ///   Enrol    -> INSERT a new progress row  (Insert operation)
        ///   Complete -> UPDATE the row's status    (Update operation)
        ///   Unenrol  -> DELETE the progress row    (Delete operation)
        /// </summary>
        protected void rptRoadmap_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!AuthHelper.IsLoggedIn())
            {
                Response.Redirect("../Member/Login.aspx");
                return;
            }

            int certId = Convert.ToInt32(e.CommandArgument);
            int userId = AuthHelper.GetUserID();

            switch (e.CommandName)
            {
                case "Enrol":
                    Enrol(userId, certId);
                    break;
                case "Complete":
                    UpdateStatus(userId, certId, "Completed");
                    break;
                case "Unenrol":
                    Unenrol(userId, certId);
                    break;
            }

            // Re-read so the row reflects its new status immediately.
            BindRoadmap();
        }

        // ----- INSERT -------------------------------------------------------
        private void Enrol(int userId, int certId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Guard against duplicate rows (the table allows them).
                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM UserProgress WHERE UserID = @UserID AND CertID = @CertID", conn);
                check.Parameters.AddWithValue("@UserID", userId);
                check.Parameters.AddWithValue("@CertID", certId);

                if ((int)check.ExecuteScalar() > 0)
                {
                    lblMessage.Text = "<div class='rm-note rm-note--warn'>You are already enrolled in that certification.</div>";
                    return;
                }

                SqlCommand cmd = new SqlCommand(
                    "INSERT INTO UserProgress (UserID, CertID, Status, UpdatedAt) " +
                    "VALUES (@UserID, @CertID, 'InProgress', GETDATE())", conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CertID", certId);
                cmd.ExecuteNonQuery();

                lblMessage.Text = "<div class='rm-note rm-note--ok'>Enrolled. Certification added to your progress.</div>";
            }
        }

        // ----- UPDATE -------------------------------------------------------
        private void UpdateStatus(int userId, int certId, string newStatus)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "UPDATE UserProgress SET Status = @Status, UpdatedAt = GETDATE() " +
                    "WHERE UserID = @UserID AND CertID = @CertID", conn);
                cmd.Parameters.AddWithValue("@Status", newStatus);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CertID", certId);

                int affected = cmd.ExecuteNonQuery();
                lblMessage.Text = affected > 0
                    ? "<div class='rm-note rm-note--ok'>Progress updated to " + FriendlyStatus(newStatus) + ".</div>"
                    : "<div class='rm-note rm-note--warn'>Enrol first, then you can update your status.</div>";
            }
        }

        // ----- DELETE -------------------------------------------------------
        private void Unenrol(int userId, int certId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM UserProgress WHERE UserID = @UserID AND CertID = @CertID", conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CertID", certId);
                cmd.ExecuteNonQuery();

                lblMessage.Text = "<div class='rm-note rm-note--muted'>Unenrolled. Certification removed from your progress.</div>";
            }
        }

        /// <summary>
        /// Pulls video resources for any certification on this path and binds
        /// them to the media repeater. This is the required multimedia element,
        /// driven by data rather than hard-coded.
        /// </summary>
        private void BindMedia()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query =
                    "SELECT r.Title, r.Url, c.CertName " +
                    "FROM Resources r " +
                    "JOIN Certifications c ON r.CertID = c.CertID " +
                    "JOIN PathCertifications pc ON pc.CertID = c.CertID " +
                    "WHERE pc.PathID = @PathID AND r.ResourceType = 'Video' " +
                    "ORDER BY pc.StepOrder";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@PathID", PathID);

                conn.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                if (dt.Rows.Count > 0)
                {
                    pnlMedia.Visible = true;
                    rptMedia.DataSource = dt;
                    rptMedia.DataBind();
                }
            }
        }
    }
}
