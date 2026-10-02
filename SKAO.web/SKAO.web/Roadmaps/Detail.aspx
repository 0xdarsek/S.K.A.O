<%@ Page Title="Roadmap" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Detail.aspx.cs" Inherits="SKAO.web.Roadmaps.Detail" %>

<asp:Content ID="RoadmapDetailContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- External CSS --%>
    <link rel="stylesheet" href="../Assets/roadmaps.css" />

    <main class="rm-wrap" aria-labelledby="pathTitle">

        <!-- Path header -->
        <section class="rm-hero">
            <div class="rm-container">
                <p class="rm-eyebrow">Certification Roadmap</p>
                <h1 id="pathTitle"><asp:Label ID="lblPathName" runat="server" /></h1>
                <p><asp:Label ID="lblPathDesc" runat="server" /></p>
                <div style="margin-top:20px;">
                    <asp:HyperLink ID="lnkQuiz" runat="server" CssClass="rm-btn rm-btn--primary">
                        Take the Self-Assessment Quiz
                    </asp:HyperLink>
                    <a href="Index.aspx" class="rm-btn rm-btn--light">&larr; All Paths</a>
                </div>
            </div>
        </section>

        <div class="rm-container">

            <!-- feedback + login notice -->
            <asp:Label ID="lblMessage" runat="server" />
            <asp:Panel ID="pnlLoginNotice" runat="server" Visible="false" CssClass="rm-note rm-note--info">
                <a href="../Member/Login.aspx">Log in</a> to enrol in a certification and track your progress.
            </asp:Panel>

            <h2 class="rm-section-title">Your Certification Roadmap</h2>

            <asp:Repeater ID="rptRoadmap" runat="server" OnItemCommand="rptRoadmap_ItemCommand"
                          OnItemDataBound="rptRoadmap_ItemDataBound">
                <ItemTemplate>
                    <div class="rm-step">
                        <div class="rm-step__no"><%# Eval("StepOrder") %></div>
                        <div class="rm-step__head">
                            <h3 class="rm-step__name"><%# Server.HtmlEncode(Eval("CertName").ToString()) %></h3>
                            <span class='rm-badge rm-lvl-<%# Eval("Level") %>'><%# Eval("Level") %></span>
                        </div>
                        <p class="rm-step__provider">Provider: <%# Server.HtmlEncode(Eval("Provider") == DBNull.Value ? "-" : Eval("Provider").ToString()) %></p>
                        <p class="rm-step__desc"><%# Server.HtmlEncode(Eval("Description") == DBNull.Value ? "" : Eval("Description").ToString()) %></p>

                        <div class="rm-step__meta">
                            <%# CertLink(Eval("Website")) %>
                            <span>Your status: <asp:Label ID="lblStatus" runat="server" /></span>
                        </div>

                        <asp:Panel ID="pnlActions" runat="server" Visible="false" CssClass="rm-actions">
                            <asp:Button ID="btnEnrol" runat="server" CssClass="rm-btn rm-btn--primary rm-btn--sm"
                                        Text="Enrol" CommandName="Enrol" CommandArgument='<%# Eval("CertID") %>' />
                            <asp:Button ID="btnComplete" runat="server" CssClass="rm-btn rm-btn--ok rm-btn--sm"
                                        Text="Mark Completed" CommandName="Complete" CommandArgument='<%# Eval("CertID") %>' />
                            <asp:Button ID="btnUnenrol" runat="server" CssClass="rm-btn rm-btn--danger rm-btn--sm"
                                        Text="Unenrol" CommandName="Unenrol" CommandArgument='<%# Eval("CertID") %>' />
                        </asp:Panel>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Label ID="lblNoCerts" runat="server" CssClass="rm-empty" Visible="false"
                       Text="This path does not have any certifications mapped yet." />

            <!-- Multimedia: overview videos from the Resources table -->
            <asp:Panel ID="pnlMedia" runat="server" Visible="false">
                <h2 class="rm-section-title">Overview Videos</h2>
                <asp:Repeater ID="rptMedia" runat="server">
                    <ItemTemplate>
                        <div class="rm-video">
                            <h4><%# Server.HtmlEncode(Eval("Title").ToString()) %>
                                <small>&mdash; <%# Eval("CertName") %></small></h4>
                            <div class="rm-ratio">
                                <iframe src='<%# Eval("Url") %>' title='<%# Server.HtmlEncode(Eval("Title").ToString()) %>'
                                        allowfullscreen></iframe>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <p class="rm-backbar">
                <a href="Index.aspx" class="rm-btn rm-btn--ghost">&larr; Back to All Paths</a>
            </p>

        </div>

    </main>

</asp:Content>
