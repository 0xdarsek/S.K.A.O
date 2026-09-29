<%@ Page Title="Self-Assessment Quiz" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="SKAO.web.Roadmaps.Quiz" %>

<asp:Content ID="QuizContent" ContentPlaceHolderID="MainContent" runat="server">

    <main aria-labelledby="quizTitle">

        <div class="p-4 mb-4 bg-light rounded-3">
            <h2 id="quizTitle"><asp:Label ID="lblQuizTitle" runat="server" Text="Self-Assessment Quiz" /></h2>
            <p class="lead mb-0">Answer each question, then submit to see your score.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-3" />

        <!-- The quiz form: one question block per row in QuizQuestions -->
        <asp:Panel ID="pnlQuiz" runat="server">
            <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                <ItemTemplate>
                    <div class="card mb-3 shadow-sm">
                        <div class="card-body">
                            <asp:HiddenField ID="hdnQuestionID" runat="server"
                                             Value='<%# Eval("QuestionID") %>' />
                            <p class="fw-bold mb-2">
                                <%# Container.ItemIndex + 1 %>.
                                <%# Server.HtmlEncode(Eval("QuestionText").ToString()) %>
                            </p>
                            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="ms-3" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-primary"
                        Text="Submit Answers" OnClick="btnSubmit_Click" />
        </asp:Panel>

        <!-- Result panel, shown after submission -->
        <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="alert alert-success mt-3">
            <h4 class="alert-heading">Quiz complete</h4>
            <p class="mb-0 fs-5"><asp:Label ID="lblScore" runat="server" /></p>
            <asp:Label ID="lblSaveNote" runat="server" CssClass="d-block mt-2 small" />
        </asp:Panel>

        <asp:Label ID="lblNoQuiz" runat="server" Visible="false" CssClass="text-muted"
                   Text="There is no quiz available for this path yet." />

        <p class="mt-3">
            <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary">
                &larr; Back to Roadmap
            </asp:HyperLink>
        </p>

    </main>

</asp:Content>
