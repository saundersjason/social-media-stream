<%@ Page Language="C#" AutoEventWireup="true" CodeFile="social_stream.aspx.cs" Inherits="social_stream" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="form.css" type="text/css" rel="stylesheet" />
        <style>
            /* -- you can use isotope for development. Please http://isotope.metafizzy.co/ for licensing information --*/
            * {
              -webkit-box-sizing: border-box;
                 -moz-box-sizing: border-box;
                      box-sizing: border-box;
            }



            /* ---- isotope ---- */

            #container {
  
              max-width: 1200px;
              margin-top:15px;
            }

            /* clear fix */
            #container:after {
              content: '';
              display: block;
              clear: both;
            }

            /* ---- .item ---- */

            .item {
              float: left;
              width: 320px;
              overflow:hidden;
              border:solid 4px #e7e7e7;
 
              padding:0px;
              background-color:#fff;
            }

            

            .item .posttime {
                font-style:italic;
                clear:both;
                font-size: 0.8em;
            }


            .item .item-content-wrapper {
                padding:10px;
            }

            .item img {
                margin-top:1em;
                width:290px;
            }

            .item .post-btn {
                background-color:#fd893d;
                color:white;
                text-decoration:none;
                padding:5px 7px;
                text-align:center;
            }

            .item .post-btn-wrapper {
                text-align:center;
            }

            .postlogo {
                background-repeat:no-repeat;
                background-position:5px 5px;
                height: 40px;
                width:100%;
                display: block;
                clear:both;
                padding-top:7px;
                
            }

            .postlogo a {
                color:#fff;
                }

            .logo-facebook {
            background-color:#3b579d;
            background-image: url("../source/FB-f-Logo-white.png");
            padding-left:40px;
            }

                

            .logo-twitter {
                background-color:#55ACEE;
                background-image: url("../source/Twitter_logo_white.png");
                padding-left:45px;
            }

            .logo-instagram {
                background-color: tan;
                background-image: url("../source/instagram-logo.png");
                padding-left: 40px;
            }

        </style>
</head>
<body>
    <form id="form1" runat="server">
    <div id="btn-facebook">
            Facebook
        </div>
        <div id="btn-instagram">
            Instagram
        </div>
        <div id="btn-twitter">
            Twitter
        </div>
        <div id="container">
            <asp:Literal Id="litStream" runat="server" />
            <div class="clearfix"></div>
        </div>
    </form>
    <!-- you can use isotope for development. Please http://isotope.metafizzy.co/ for licensing information -->
    <script src="../source/isotope.pkgd.min.js"></script>
    <!-- http://imagesloaded.desandro.com/ -->
        <script src="../source/imagesloaded.pkgd.min.js"></script>
        <script>
            var $container;
            $(function () {
                $container = $('#container').isotope({
                    masonry: {
                        columnWidth: 320
                    }
                });

                // layout Isotope again after all images have loaded
                $container.imagesLoaded(function () {
                    $container.isotope('layout');
                });
            });

            $("#btn-facebook").click(function () {
                $(".facebook").css("display", "none");
                // layout Isotope again after all images have loaded
                $container.imagesLoaded(function () {
                    $container.isotope('layout');
                });
            });
            $("#btn-twitter").click(function () {
                $(".twitter").css("display", "none");
                // layout Isotope again after all images have loaded
                $container.imagesLoaded(function () {
                    $container.isotope('layout');
                });
            });
            $("#btn-instagram").click(function () {
                $(".instagram").css("display", "none");
                // layout Isotope again after all images have loaded
                $container.imagesLoaded(function () {
                    $container.isotope('layout');
                });
            });
        </script>
</body>
</html>
