<%@ Page Title="Self-Assessment Quiz" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="SKAO.web.Roadmaps.Quiz" %>

<asp:Content ID="QuizContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- External CSS --%>
    <link rel="stylesheet" href="../Assets/roadmaps.css" />

    <%-- Internal CSS: a small page-specific tweak on top of the external stylesheet --%>
    <style>
        .rm-progress-hint { color:#c7d2e0; font-size:.9rem; margin-top:12px; }
    </style>

    <main class="rm-wrap" aria-labelledby="quizTitle">

        <section class="rm-hero">
            <div class="rm-container">
                <p class="rm-eyebrow">Self-Assessment</p>
                <h1 id="quizTitle"><asp:Label ID="lblQuizTitle" runat="server" Text="Self-Assessment Quiz" /></h1>
                <p>Answer each question, then submit to see your score.</p>
                <p class="rm-progress-hint">Tip: log in before you start so your score is saved to your account.</p>
            </div>
        </section>

        <div class="rm-container">

            <asp:Label ID="lblMessage" runat="server" />

            <div style="margin-top:26px;">
                <asp:Panel ID="pnlQuiz" runat="server">
                    <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                        <ItemTemplate>
                            <div class="rm-q">
                                <asp:HiddenField ID="hdnQuestionID" runat="server" Value='<%# Eval("QuestionID") %>' />
                                <p class="rm-q__text">
                                    <%# Container.ItemIndex + 1 %>.
                                    <%# Server.HtmlEncode(Eval("QuestionText").ToString()) %>
                                </p>
                                <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="rm-options" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Button ID="btnSubmit" runat="server" CssClass="rm-btn rm-btn--primary"
                                Text="Submit Answers" OnClick="btnSubmit_Click" />
                </asp:Panel>

                <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="rm-result">
                    <h3>Quiz complete</h3>
                    <p class="rm-score"><asp:Label ID="lblScore" runat="server" /></p>
                    <small><asp:Label ID="lblSaveNote" runat="server" /></small>
                </asp:Panel>

                <asp:Label ID="lblNoQuiz" runat="server" Visible="false" CssClass="rm-empty"
                           Text="There is no quiz available for this path yet." />
            </div>

            <p class="rm-backbar">
                <asp:HyperLink ID="lnkBack" runat="server" CssClass="rm-btn rm-btn--ghost">
                    &larr; Back to Roadmap
                </asp:HyperLink>
            </p>

        </div>

    </main>

</asp:Content>
