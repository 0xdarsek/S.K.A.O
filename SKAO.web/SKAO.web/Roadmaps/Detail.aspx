<%@ Page Title="Roadmap" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Detail.aspx.cs" Inherits="SKAO.web.Roadmaps.Detail" %>

<asp:Content ID="RoadmapDetailContent" ContentPlaceHolderID="MainContent" runat="server">

    <main aria-labelledby="pathTitle">

        <!-- Path header (filled from CareerPaths in code-behind) -->
        <div class="p-4 mb-4 bg-light rounded-3">
            <h2 id="pathTitle"><asp:Label ID="lblPathName" runat="server" /></h2>
            <p class="lead mb-3"><asp:Label ID="lblPathDesc" runat="server" /></p>
            <asp:HyperLink ID="lnkQuiz" runat="server" CssClass="btn btn-success">
                Take the Self-Assessment Quiz
            </asp:HyperLink>
            <a href="Index.aspx" class="btn btn-outline-secondary">&larr; All Paths</a>
        </div>

        <!-- Status / feedback message -->
        <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-3" />

        <!-- Prompt shown to visitors who are not logged in -->
        <asp:Panel ID="pnlLoginNotice" runat="server" Visible="false"
                   CssClass="alert alert-info">
            <a href="../Member/Login.aspx">Log in</a> to enrol in a certification and track your progress.
        </asp:Panel>

        <h3 class="mb-3">Certification Roadmap</h3>

        <!-- Ordered list of certifications on this path -->
        <asp:Repeater ID="rptRoadmap" runat="server" OnItemCommand="rptRoadmap_ItemCommand"
                      OnItemDataBound="rptRoadmap_ItemDataBound">
            <ItemTemplate>
                <div class="card mb-3 shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <h5 class="card-title">
                                <span class="badge bg-secondary me-2">Step <%# Eval("StepOrder") %></span>
                                <%# Server.HtmlEncode(Eval("CertName").ToString()) %>
                            </h5>
                            <span class="badge bg-info text-dark"><%# Eval("Level") %></span>
                        </div>
                        <h6 class="card-subtitle mb-2 text-muted">
                            Provider: <%# Server.HtmlEncode(Eval("Provider") == null ? "-" : Eval("Provider").ToString()) %>
                        </h6>
                        <p class="card-text"><%# Server.HtmlEncode(Eval("Description") == null ? "" : Eval("Description").ToString()) %></p>

                        <!-- Current progress status for the logged-in member -->
                        <p class="mb-2">
                            <strong>Your status:</strong>
                            <asp:Label ID="lblStatus" runat="server" />
                        </p>

                        <!-- Member actions: Insert (Enrol), Update (Mark Completed), Delete (Unenrol) -->
                        <asp:Panel ID="pnlActions" runat="server" Visible="false">
                            <asp:Button ID="btnEnrol" runat="server" CssClass="btn btn-sm btn-primary"
                                        Text="Enrol" CommandName="Enrol"
                                        CommandArgument='<%# Eval("CertID") %>' />
                            <asp:Button ID="btnComplete" runat="server" CssClass="btn btn-sm btn-outline-success"
                                        Text="Mark Completed" CommandName="Complete"
                                        CommandArgument='<%# Eval("CertID") %>' />
                            <asp:Button ID="btnUnenrol" runat="server" CssClass="btn btn-sm btn-outline-danger"
                                        Text="Unenrol" CommandName="Unenrol"
                                        CommandArgument='<%# Eval("CertID") %>' />
                        </asp:Panel>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Label ID="lblNoCerts" runat="server" CssClass="text-muted" Visible="false"
                   Text="This path does not have any certifications mapped yet." />

        <!-- Multimedia section: certification overview videos pulled from the Resources table -->
        <asp:Panel ID="pnlMedia" runat="server" Visible="false">
            <h3 class="mt-4 mb-3">Overview Videos</h3>
            <asp:Repeater ID="rptMedia" runat="server">
                <ItemTemplate>
                    <div class="mb-4">
                        <h6><%# Server.HtmlEncode(Eval("Title").ToString()) %>
                            <small class="text-muted">(<%# Eval("CertName") %>)</small></h6>
                        <div class="ratio ratio-16x9" style="max-width:640px;">
                            <iframe src='<%# Eval("Url") %>' title='<%# Server.HtmlEncode(Eval("Title").ToString()) %>'
                                    allowfullscreen></iframe>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

    </main>

</asp:Content>
