<%@ Page Title="Career Paths" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="SKAO.web.Roadmaps.Index" %>

<asp:Content ID="RoadmapsIndexContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- External CSS: the module's own stylesheet (works without the shared Bootstrap bundle) --%>
    <link rel="stylesheet" href="../Assets/roadmaps.css" />

    <main class="rm-wrap" aria-labelledby="pageTitle">

        <!-- Hero header -->
        <section class="rm-hero">
            <div class="rm-container">
                <p class="rm-eyebrow">S.K.A.O &bull; Cybersecurity Roadmaps</p>
                <h1 id="pageTitle">Cybersecurity Career Paths</h1>
                <p>Choose a path to see the certifications you need to earn &mdash; in the right order &mdash;
                   to break into that cybersecurity career.</p>
            </div>
        </section>

        <div class="rm-container">

            <!-- One card per career path, generated from the CareerPaths table -->
            <asp:Repeater ID="rptPaths" runat="server">
                <HeaderTemplate>
                    <div class="rm-grid">
                </HeaderTemplate>
                <ItemTemplate>
                    <div class="rm-card">
                        <img class="rm-card__img" src='<%# ImgSrc(Eval("ImageUrl")) %>'
                             alt='<%# Server.HtmlEncode(Eval("PathName").ToString()) %> banner' />
                        <div class="rm-card__body">
                            <h3 class="rm-card__title"><%# Server.HtmlEncode(Eval("PathName").ToString()) %></h3>
                            <p class="rm-card__text"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                            <a class="rm-btn rm-btn--primary" style="align-self:flex-start;"
                               href='<%# "Detail.aspx?id=" + Eval("PathID") %>'>View Roadmap &rarr;</a>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    </div>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Label ID="lblEmpty" runat="server" CssClass="rm-empty"
                       Text="No career paths are available yet." Visible="false" />

        </div>

    </main>

</asp:Content>
