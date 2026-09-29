<%@ Page Title="Career Paths" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="SKAO.web.Roadmaps.Index" %>

<asp:Content ID="RoadmapsIndexContent" ContentPlaceHolderID="MainContent" runat="server">

    <main aria-labelledby="pageTitle">

        <!-- Page header -->
        <div class="p-4 mb-4 bg-light rounded-3">
            <h2 id="pageTitle">Cybersecurity Career Paths</h2>
            <p class="lead mb-0">
                Choose a path to see the certifications you need to earn, in the right order,
                to break into that cybersecurity career.
            </p>
        </div>

        <!-- One card per career path, generated from the CareerPaths table -->
        <asp:Repeater ID="rptPaths" runat="server">
            <HeaderTemplate>
                <div class="row">
            </HeaderTemplate>
            <ItemTemplate>
                <div class="col-sm-6 col-lg-3 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body d-flex flex-column">
                            <h4 class="card-title"><%# Server.HtmlEncode(Eval("PathName").ToString()) %></h4>
                            <p class="card-text flex-grow-1"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                            <a class="btn btn-primary mt-2"
                               href='<%# "Detail.aspx?id=" + Eval("PathID") %>'>View Roadmap</a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>

        <!-- Shown only if the table returns no rows -->
        <asp:Label ID="lblEmpty" runat="server" CssClass="text-muted"
                   Text="No career paths are available yet." Visible="false" />

    </main>

</asp:Content>
