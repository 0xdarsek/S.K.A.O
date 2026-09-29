using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SKAO.web.Shared;

namespace SKAO.web.Roadmaps
{
    public partial class Quiz : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["SKAOConnection"].ConnectionString;

        private int PathID
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        // The quiz being taken, kept across the postback so scoring can find its questions.
        private int QuizID
        {
            get { return ViewState["QuizID"] == null ? 0 : (int)ViewState["QuizID"]; }
            set { ViewState["QuizID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (PathID == 0)
            {
                Response.Redirect("Index.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lnkBack.NavigateUrl = "Detail.aspx?id=" + PathID;
                LoadQuiz();
            }
        }

        /// <summary>Finds the quiz for this path and binds its questions.</summary>
        private void LoadQuiz()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // One quiz per path (take the first if several exist).
                SqlCommand quizCmd = new SqlCommand(
                    "SELECT TOP 1 QuizID, Title FROM Quizzes WHERE PathID = @PathID ORDER BY QuizID", conn);
                quizCmd.Parameters.AddWithValue("@PathID", PathID);

                SqlDataReader qr = quizCmd.ExecuteReader();
                if (!qr.Read())
                {
                    // No quiz seeded for this path.
                    pnlQuiz.Visible = false;
                    lblNoQuiz.Visible = true;
                    qr.Close();
                    return;
                }

                QuizID = (int)qr["QuizID"];
                lblQuizTitle.Text = Server.HtmlEncode(qr["Title"].ToString());
                qr.Close();

                // Load the questions for this quiz.
                SqlCommand qCmd = new SqlCommand(
                    "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD " +
                    "FROM QuizQuestions WHERE QuizID = @QuizID ORDER BY QuestionID", conn);
                qCmd.Parameters.AddWithValue("@QuizID", QuizID);

                DataTable dt = new DataTable();
                dt.Load(qCmd.ExecuteReader());

                if (dt.Rows.Count == 0)
                {
                    pnlQuiz.Visible = false;
                    lblNoQuiz.Visible = true;
                    return;
                }

                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
            }
        }

        /// <summary>
        /// Builds the radio buttons for one question, skipping any option that
        /// is empty in the database. Each item's value is the option letter.
        /// </summary>
        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");

            AddOption(rbl, "A", row["OptionA"]);
            AddOption(rbl, "B", row["OptionB"]);
            AddOption(rbl, "C", row["OptionC"]);
            AddOption(rbl, "D", row["OptionD"]);
        }

        private static void AddOption(RadioButtonList rbl, string letter, object text)
        {
            if (text == null || text == DBNull.Value || string.IsNullOrWhiteSpace(text.ToString()))
                return;

            rbl.Items.Add(new ListItem(letter + ". " + text, letter));
        }

        /// <summary>
        /// Scores the quiz: compares each selected letter against CorrectOption,
        /// shows the total, and saves the result to QuizResults for logged-in members.
        /// </summary>
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (QuizID == 0)
                return;

            // Pull the correct answers once into a lookup keyed by QuestionID.
            Dictionary<int, string> answers = LoadCorrectAnswers(QuizID);

            int total = answers.Count;
            int score = 0;

            foreach (RepeaterItem item in rptQuestions.Items)
            {
                HiddenField hdn = (HiddenField)item.FindControl("hdnQuestionID");
                RadioButtonList rbl = (RadioButtonList)item.FindControl("rblOptions");

                int qid = int.Parse(hdn.Value);
                string selected = rbl.SelectedValue;          // "" if unanswered

                if (!string.IsNullOrEmpty(selected) &&
                    answers.ContainsKey(qid) &&
                    answers[qid] == selected)
                {
                    score++;
                }
            }

            // Show the result and hide the form.
            pnlQuiz.Visible = false;
            pnlResult.Visible = true;
            lblScore.Text = string.Format("You scored {0} out of {1}.", score, total);

            SaveResult(score);
        }

        private Dictionary<int, string> LoadCorrectAnswers(int quizId)
        {
            Dictionary<int, string> map = new Dictionary<int, string>();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT QuestionID, CorrectOption FROM QuizQuestions WHERE QuizID = @QuizID", conn);
                cmd.Parameters.AddWithValue("@QuizID", quizId);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    map[(int)reader["QuestionID"]] = reader["CorrectOption"].ToString().Trim();
                }
            }
            return map;
        }

        /// <summary>Inserts the score into QuizResults (only when a member is logged in).</summary>
        private void SaveResult(int score)
        {
            if (!AuthHelper.IsLoggedIn())
            {
                lblSaveNote.Text = "Log in before taking the quiz to save your score to your account.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "INSERT INTO QuizResults (UserID, QuizID, Score, TakenAt) " +
                    "VALUES (@UserID, @QuizID, @Score, GETDATE())", conn);
                cmd.Parameters.AddWithValue("@UserID", AuthHelper.GetUserID());
                cmd.Parameters.AddWithValue("@QuizID", QuizID);
                cmd.Parameters.AddWithValue("@Score", score);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            lblSaveNote.Text = "Your score has been saved to your account.";
        }
    }
}
