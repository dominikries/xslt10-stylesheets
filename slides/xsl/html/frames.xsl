<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:import href="slides-common.xsl"/>

<xsl:param name="titlefoil.html" select="concat('titlepg', $html.ext)"/>

<xsl:param name="css.stylesheet" select="'slides-frames.css'"/>

<!-- ====================================================================== -->

<xsl:template match="slides">
  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="(slidesinfo/titleabbrev|titleabbrev)">
        <xsl:value-of select="(slidesinfo/titleabbrev|titleabbrev)[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="(slidesinfo/title|title)[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="toc.rows" select="1+count(//foilgroup)+count(//foil)"/>
  <xsl:variable name="toc.height" select="$toc.rows * $toc.row.height"/>

  <xsl:if test="$overlay != 0 and $multiframe != 0">
    <xsl:message terminate='yes'>
      <xsl:text>Multiframe and overlay are mutually exclusive.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'frames', $html.ext)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title><xsl:value-of select="$title"/></title>
        </head>
        <frameset border="1" cols="{$toc.width},*" name="topframe" framespacing="0">
          <frame src="{concat('toc', $html.ext)}" name="toc" frameborder="1"/>
          <frame src="{$titlefoil.html}" name="foil"/>
          <noframes>
            <body class="frameset">
              <xsl:call-template name="body.attributes"/>
              <a href="{concat('titleframe', $html.ext)}">
                <xsl:text>Your browser doesn't support frames.</xsl:text>
              </a>
            </body>
          </noframes>
        </frameset>
      </html>
    </xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'toc',$html.ext)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>TOC - <xsl:value-of select="$title"/></title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0
                        or $overlay.logo != ''">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0' or $overlay.logo != ''">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$dynamic.toc != 0">
            <script language="JavaScript" type="text/javascript"><xsl:text>
function init() {
  var width = </xsl:text>
<xsl:value-of select="$toc.width"/>
<xsl:text>, height = </xsl:text>
<xsl:value-of select="$toc.row.height"/>
<xsl:text>;
  myList = new List(true, width, height, "</xsl:text>
<xsl:value-of select="$toc.bg.color"/>
<xsl:text>","</xsl:text>
<xsl:call-template name="plus.image"/>
<xsl:text>","</xsl:text>
<xsl:call-template name="minus.image"/>
<xsl:text>");
</xsl:text>
<xsl:apply-templates mode="ns-toc"/>
<xsl:text>
  myList.build(0,0);
}
</xsl:text>
            </script>
            <style type="text/css"><xsl:text>
  #spacer { position: absolute; height: </xsl:text>
                <xsl:value-of select="$toc.height"/>
  <xsl:text>; }
</xsl:text>
            </style>
          </xsl:if>
        </head>
        <body class="toc">
          <xsl:call-template name="body.attributes"/>

          <xsl:if test="$overlay.logo != ''">
            <xsl:attribute name="onload">
              <xsl:text>overlaySetup('ll');</xsl:text>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$dynamic.toc != 0">
            <xsl:attribute name="onload">
              <xsl:text>init(</xsl:text>
              <xsl:value-of select="$overlay"/>
              <xsl:text>);</xsl:text>
              <xsl:if test="$overlay.logo != ''">
                <xsl:text>overlaySetup('ll');</xsl:text>
              </xsl:if>
            </xsl:attribute>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="$dynamic.toc = 0">
              <div class="toc">
                <xsl:apply-templates mode="toc"/>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div id="spacer"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="$overlay.logo != ''">
            <div style="position: absolute; visibility: visible;" id="overlayDiv">
              <img src="{$overlay.logo}" alt="logo" vspace="20"/>
            </div>
          </xsl:if>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>

  <xsl:apply-templates/>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="slidesinfo">
  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename"
                    select="concat($base.dir,$titlefoil.html)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title><xsl:value-of select="title"/></title>

          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:call-template name="links">
            <xsl:with-param name="next" select="$next"/>
          </xsl:call-template>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <xsl:choose>
          <xsl:when test="$multiframe != 0">
            <xsl:apply-templates select="." mode="multiframe"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="singleframe"/>
          </xsl:otherwise>
        </xsl:choose>
      </html>
    </xsl:with-param>
  </xsl:call-template>

  <xsl:if test="$multiframe != 0">
    <xsl:apply-templates select="." mode="multiframe-top"/>
    <xsl:apply-templates select="." mode="multiframe-body"/>
    <xsl:apply-templates select="." mode="multiframe-bottom"/>
  </xsl:if>
</xsl:template>

<xsl:template match="slidesinfo" mode="multiframe">
  <xsl:variable name="thisfoil">
    <xsl:value-of select="$titlefoil.html"/>
  </xsl:variable>

  <frameset rows="{$multiframe.navigation.height},*,{$multiframe.navigation.height}" border="0" name="foil" framespacing="0">
    <xsl:attribute name="onkeypress">
      <xsl:text>navigate(event)</xsl:text>
    </xsl:attribute>
    <frame src="top-{$thisfoil}" name="top" marginheight="0" scrolling="no" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <frame src="body-{$thisfoil}" name="body" marginheight="0" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <frame src="bot-{$thisfoil}" name="bottom" marginheight="0" scrolling="no" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <noframes>
      <body class="frameset">
        <xsl:call-template name="body.attributes"/>
        <p>
          <xsl:text>Your browser doesn't support frames.</xsl:text>
        </p>
      </body>
    </noframes>
  </frameset>
</xsl:template>

<xsl:template match="slidesinfo" mode="multiframe-top">
  <xsl:variable name="thisfoil">
    <xsl:value-of select="$titlefoil.html"/>
  </xsl:variable>

  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'top-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="topnavigation" bgcolor="{$multiframe.top.bgcolor}">
          <xsl:call-template name="foil-top-nav">
            <xsl:with-param name="next" select="$next"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="slidesinfo" mode="multiframe-body">
  <xsl:variable name="thisfoil">
    <xsl:value-of select="$titlefoil.html"/>
  </xsl:variable>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'body-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Body</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <xsl:apply-templates select="." mode="singleframe"/>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="slidesinfo" mode="multiframe-bottom">
  <xsl:variable name="thisfoil">
    <xsl:value-of select="$titlefoil.html"/>
  </xsl:variable>

  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'bot-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="botnavigation" bgcolor="{$multiframe.bottom.bgcolor}">
          <xsl:call-template name="foil-bottom-nav">
            <xsl:with-param name="next" select="$next"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="slidesinfo" mode="singleframe">
  <xsl:param name="thisfoil">
    <xsl:value-of select="$titlefoil.html"/>
  </xsl:param>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>

  <body class="titlepage">
    <xsl:call-template name="body.attributes"/>
    <xsl:choose>
      <xsl:when test="$active.toc != 0">
        <xsl:attribute name="onload">
          <xsl:text>newPage('</xsl:text>
          <xsl:value-of select="$titlefoil.html"/>
          <xsl:text>',</xsl:text>
          <xsl:value-of select="$overlay"/>
          <xsl:text>);</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$overlay != 0">
        <xsl:attribute name="onload">
          <xsl:text>overlaySetup('lc');</xsl:text>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="$keyboard.nav != 0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </xsl:if>

    <div class="{name(.)}">
      <xsl:apply-templates mode="titlepage.mode"/>
    </div>

    <xsl:if test="$multiframe=0">
      <div id="overlayDiv" class="navfoot">
        <xsl:choose>
          <xsl:when test="$overlay != 0">
            <xsl:attribute name="style">
              <xsl:text>position:absolute;visibility:visible;</xsl:text>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="style">
              <xsl:text>padding-top: 2in;</xsl:text>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <table width="100%" border="0"
               cellspacing="0" cellpadding="0"
               summary="Navigation">
          <tr>
            <td align="left" width="80%" valign="top">
              <span class="navfooter">
                <!-- suppress copyright here; it's probably already on the titlepage
                <xsl:apply-templates select="/slides/slidesinfo/copyright"
                                     mode="slide.footer.mode"/>
                -->
                <xsl:text>&#160;</xsl:text>
              </span>
            </td>
            <td align="right" width="20%" valign="top">
              <a href="{concat('foil01', $html.ext)}">
                <img alt="{$text.next}" border="0">
                  <xsl:attribute name="src">
                    <xsl:call-template name="next.image"/>
                  </xsl:attribute>
                </img>
              </a>
            </td>
          </tr>
        </table>
      </div>
    </xsl:if>
  </body>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="top-nav">
  <xsl:param name="home"/>
  <xsl:param name="up"/>
  <xsl:param name="next"/>
  <xsl:param name="prev"/>
  <xsl:param name="tocfile" select="$toc.html"/>

  <div class="navhead">
    <table border="0" width="100%" cellspacing="0" cellpadding="0"
           summary="Navigation table">
      <tr>
        <td align="left" valign="bottom" width="10%">
          <xsl:choose>
            <xsl:when test="$prev">
              <span class="link-text">
                <a>
                  <xsl:attribute name="href">
                    <xsl:apply-templates select="$prev" mode="filename"/>
                  </xsl:attribute>
                  <xsl:if test="$multiframe != 0">
                    <xsl:attribute name="target">foil</xsl:attribute>
                  </xsl:if>
                  <img alt="{$text.prev}" border="0">
                    <xsl:attribute name="src">
                      <xsl:call-template name="prev.image"/>
                    </xsl:attribute>
                  </img>
                </a>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="no-link-text">&#160;</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;</xsl:text>
        </td>
        <td width="80%">&#160;</td>
        <td align="right" valign="bottom" width="10%">
          <xsl:choose>
            <xsl:when test="$next">
              <span class="link-text">
                <a>
                  <xsl:attribute name="href">
                    <xsl:apply-templates select="$next" mode="filename"/>
                  </xsl:attribute>
                  <xsl:if test="$multiframe != 0">
                    <xsl:attribute name="target">foil</xsl:attribute>
                  </xsl:if>
                  <img alt="{$text.next}" border="0">
                    <xsl:attribute name="src">
                      <xsl:call-template name="next.image"/>
                    </xsl:attribute>
                  </img>
                </a>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="no-link-text">&#160;</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </table>
    <hr class="top-nav-sep"/>
  </div>
</xsl:template>

<xsl:template name="bottom-nav">
  <xsl:param name="home"/>
  <xsl:param name="up"/>
  <xsl:param name="next"/>
  <xsl:param name="prev"/>
  <xsl:param name="tocfile" select="$toc.html"/>

  <div class="navfoot">
    <hr class="bottom-nav-sep"/>
    <table border="0" width="100%" cellspacing="0" cellpadding="0"
           summary="Navigation table">
      <tr>
        <td align="left" valign="top">
          <xsl:apply-templates select="/slides/slidesinfo/copyright"
                               mode="slide.footer.mode"/>
          <xsl:text>&#160;</xsl:text>
        </td>

        <td align="right" valign="top">
          <xsl:choose>
            <xsl:when test="$prev">
              <span class="link-text">
                <a>
                  <xsl:attribute name="href">
                    <xsl:apply-templates select="$prev" mode="filename"/>
                  </xsl:attribute>
                  <xsl:if test="$multiframe != 0">
                    <xsl:attribute name="target">foil</xsl:attribute>
                  </xsl:if>
                  <img alt="{$text.prev}" border="0">
                    <xsl:attribute name="src">
                      <xsl:call-template name="prev.image"/>
                    </xsl:attribute>
                  </img>
                </a>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="no-link-text">&#160;</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;</xsl:text>

          <xsl:choose>
            <xsl:when test="$next">
              <span class="link-text">
                <a>
                  <xsl:attribute name="href">
                    <xsl:apply-templates select="$next" mode="filename"/>
                  </xsl:attribute>
                  <xsl:if test="$multiframe != 0">
                    <xsl:attribute name="target">foil</xsl:attribute>
                  </xsl:if>
                  <img alt="{$text.next}" border="0">
                    <xsl:attribute name="src">
                      <xsl:call-template name="next.image"/>
                    </xsl:attribute>
                  </img>
                </a>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="no-link-text">&#160;</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="foilgroup">
  <xsl:param name="thisfoilgroup">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:param>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up" select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="foil[1]"/>
  <xsl:variable name="prev" select="(preceding::foil|parent::foilgroup|/slides)[last()]"/>
  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,$thisfoilgroup)"/>
    <xsl:with-param name="content">
      <head>
        <title><xsl:value-of select="title"/></title>
        <link type="text/css" rel="stylesheet">
          <xsl:attribute name="href">
            <xsl:call-template name="css.stylesheet"/>
          </xsl:attribute>
        </link>

        <xsl:call-template name="links">
          <xsl:with-param name="home" select="$home"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>

        <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                      or $dynamic.toc != 0 or $active.toc != 0">
          <script language="JavaScript1.2" type="text/javascript"/>
        </xsl:if>

        <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
          <xsl:call-template name="ua.js"/>
          <xsl:call-template name="xbDOM.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
          <xsl:call-template name="xbStyle.js"/>
          <xsl:call-template name="xbCollapsibleLists.js"/>
          <xsl:call-template name="slides.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="$overlay != '0'">
          <xsl:call-template name="overlay.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
        </xsl:if>
      </head>
      <xsl:choose>
        <xsl:when test="$multiframe != 0">
          <xsl:apply-templates select="." mode="multiframe"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="singleframe"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>

  <xsl:if test="$multiframe != 0">
    <xsl:apply-templates select="." mode="multiframe-top"/>
    <xsl:apply-templates select="." mode="multiframe-body"/>
    <xsl:apply-templates select="." mode="multiframe-bottom"/>
  </xsl:if>

  <xsl:apply-templates select="foil"/>
</xsl:template>

<xsl:template match="foilgroup" mode="multiframe">
  <xsl:variable name="thisfoilgroup">
    <xsl:text>foilgrp</xsl:text>
    <xsl:number count="foilgroup" level="any" format="01"/>
    <xsl:value-of select="$html.ext"/>
  </xsl:variable>

  <frameset rows="{$multiframe.navigation.height},*,{$multiframe.navigation.height}"
            border="0" name="foil" framespacing="0">
    <frame src="top-{$thisfoilgroup}" name="top" marginheight="0"
           scrolling="no" frameborder="0"/>
    <frame src="body-{$thisfoilgroup}" name="body" marginheight="0" frameborder="0"/>
    <frame src="bot-{$thisfoilgroup}" name="bottom" marginheight="0"
           scrolling="no" frameborder="0"/>
    <noframes>
      <body class="frameset">
        <xsl:call-template name="body.attributes"/>
        <p>
          <xsl:text>Your browser doesn't support frames.</xsl:text>
        </p>
      </body>
    </noframes>
  </frameset>
</xsl:template>

<xsl:template match="foilgroup" mode="multiframe-top">
  <xsl:variable name="foilgroup">
    <xsl:text>foilgrp</xsl:text>
    <xsl:number count="foilgroup" level="any" format="01"/>
    <xsl:value-of select="$html.ext"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up" select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="foil[1]"/>
  <xsl:variable name="prev" select="(preceding::foil|parent::foilgroup|/slides)[last()]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'top-',$foilgroup)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="topnavigation" bgcolor="{$multiframe.top.bgcolor}">
          <xsl:call-template name="foilgroup-top-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foilgroup" mode="multiframe-body">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="thisfoilgroup">
    <xsl:text>foilgrp</xsl:text>
    <xsl:number count="foilgroup" level="any" format="01"/>
    <xsl:value-of select="$html.ext"/>
  </xsl:variable>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'body-',$thisfoilgroup)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Body</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <xsl:apply-templates select="." mode="singleframe"/>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foilgroup" mode="multiframe-bottom">
  <xsl:variable name="thisfoilgroup">
    <xsl:text>foilgrp</xsl:text>
    <xsl:number count="foilgroup" level="any" format="01"/>
    <xsl:value-of select="$html.ext"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up" select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="foil[1]"/>
  <xsl:variable name="prev" select="(preceding::foil|parent::foilgroup|/slides)[last()]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'bot-',$thisfoilgroup)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="botnavigation" bgcolor="{$multiframe.bottom.bgcolor}">
          <xsl:call-template name="foilgroup-bottom-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foilgroup" mode="singleframe">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:param name="thisfoilgroup">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:param>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up" select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="foil[1]"/>
  <xsl:variable name="prev" select="(preceding::foil|parent::foilgroup|/slides)[last()]"/>
  <body class="foilgroup">
    <xsl:call-template name="body.attributes"/>
    <xsl:choose>
      <xsl:when test="$active.toc != 0">
        <xsl:attribute name="onload">
          <xsl:text>newPage('</xsl:text>
          <xsl:value-of select="$thisfoilgroup"/>
          <xsl:text>',</xsl:text>
          <xsl:value-of select="$overlay"/>
          <xsl:text>);</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$overlay != 0">
        <xsl:attribute name="onload">
          <xsl:text>overlaySetup('lc');</xsl:text>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="$keyboard.nav != 0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </xsl:if>
    <div class="{name(.)}" id="{$id}">
      <a name="{$id}"/>
      <xsl:if test="$multiframe=0">
        <xsl:call-template name="foilgroup-top-nav">
          <xsl:with-param name="home" select="$home"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>
      </xsl:if>

      <div class="{name(.)}" id="{$id}">
        <a name="{$id}"/>
        <xsl:call-template name="foilgroup-body">
          <xsl:with-param name="home" select="$home"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>
      </div>

      <xsl:if test="$multiframe=0">
        <div id="overlayDiv">
          <xsl:if test="$overlay != 0">
            <xsl:attribute name="style">
              <xsl:text>position:absolute;visibility:visible;</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="foilgroup-bottom-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </div>

    <xsl:call-template name="process.footnotes"/>
  </body>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="foil">
  <xsl:variable name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up"   select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>
  <xsl:variable name="prev" select="(preceding-sibling::foil[1]
                                    |parent::foilgroup[1]
                                    |/slides)[last()]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,$thisfoil)"/>
    <xsl:with-param name="content">
      <head>
        <title><xsl:value-of select="title"/></title>
        <link type="text/css" rel="stylesheet">
          <xsl:attribute name="href">
            <xsl:call-template name="css.stylesheet"/>
          </xsl:attribute>
        </link>

        <xsl:call-template name="links">
          <xsl:with-param name="home" select="$home"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>

        <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                      or $dynamic.toc != 0 or $active.toc != 0">
          <script language="JavaScript1.2" type="text/javascript"/>
        </xsl:if>

        <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
          <xsl:call-template name="ua.js"/>
          <xsl:call-template name="xbDOM.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
          <xsl:call-template name="xbStyle.js"/>
          <xsl:call-template name="xbCollapsibleLists.js"/>
          <xsl:call-template name="slides.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="$overlay != '0'">
          <xsl:call-template name="overlay.js">
            <xsl:with-param name="language" select="'JavaScript'"/>
          </xsl:call-template>
        </xsl:if>
      </head>
      <xsl:choose>
        <xsl:when test="$multiframe != 0">
          <xsl:apply-templates select="." mode="multiframe"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="singleframe"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>

  <xsl:if test="$multiframe != 0">
    <xsl:apply-templates select="." mode="multiframe-top"/>
    <xsl:apply-templates select="." mode="multiframe-body"/>
    <xsl:apply-templates select="." mode="multiframe-bottom"/>
  </xsl:if>
</xsl:template>

<xsl:template match="foil" mode="multiframe">
  <xsl:variable name="foilgroup" select="ancestor::foilgroup"/>

  <xsl:variable name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <frameset rows="{$multiframe.navigation.height},*,{$multiframe.navigation.height}" border="0" name="foil" framespacing="0">
    <xsl:attribute name="onkeypress">
      <xsl:text>navigate(event)</xsl:text>
    </xsl:attribute>
    <frame src="top-{$thisfoil}" name="top" marginheight="0" scrolling="no" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <frame src="body-{$thisfoil}" name="body" marginheight="0" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <frame src="bot-{$thisfoil}" name="bottom" marginheight="0" scrolling="no" frameborder="0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </frame>
    <noframes>
      <body class="frameset">
        <xsl:call-template name="body.attributes"/>
        <p>
          <xsl:text>Your browser doesn't support frames.</xsl:text>
        </p>
      </body>
    </noframes>
  </frameset>
</xsl:template>

<xsl:template match="foil" mode="multiframe-top">
  <xsl:variable name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up"   select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>
  <xsl:variable name="prev" select="(preceding-sibling::foil[1]
                                    |parent::foilgroup[1]
                                    |/slides)[last()]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'top-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="topnavigation" bgcolor="{$multiframe.top.bgcolor}">
          <xsl:call-template name="foil-top-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foil" mode="multiframe-body">
  <xsl:variable name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'body-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Body</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <xsl:apply-templates select="." mode="singleframe"/>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foil" mode="multiframe-bottom">
  <xsl:variable name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up"   select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>
  <xsl:variable name="prev" select="(preceding-sibling::foil[1]
                                    |parent::foilgroup[1]
                                    |/slides)[last()]"/>

  <xsl:call-template name="write.chunk">
    <xsl:with-param name="indent" select="$output.indent"/>
    <xsl:with-param name="filename" select="concat($base.dir,'bot-',$thisfoil)"/>
    <xsl:with-param name="content">
      <html>
        <head>
          <title>Navigation</title>
          <link type="text/css" rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:call-template name="css.stylesheet"/>
            </xsl:attribute>
          </link>

          <xsl:if test="$overlay != 0 or $keyboard.nav != 0
                        or $dynamic.toc != 0 or $active.toc != 0">
            <script language="JavaScript1.2" type="text/javascript"/>
          </xsl:if>

          <xsl:if test="$keyboard.nav != 0 or $dynamic.toc != 0 or $active.toc != 0">
            <xsl:call-template name="ua.js"/>
            <xsl:call-template name="xbDOM.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
            <xsl:call-template name="xbStyle.js"/>
            <xsl:call-template name="xbCollapsibleLists.js"/>
            <xsl:call-template name="slides.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$overlay != '0'">
            <xsl:call-template name="overlay.js">
              <xsl:with-param name="language" select="'JavaScript'"/>
            </xsl:call-template>
          </xsl:if>
        </head>
        <body class="botnavigation" bgcolor="{$multiframe.bottom.bgcolor}">
          <xsl:call-template name="foil-bottom-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </body>
      </html>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="foil" mode="singleframe">
  <xsl:param name="thisfoil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:param>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="home" select="/slides"/>
  <xsl:variable name="up"   select="(parent::slides|parent::foilgroup)[1]"/>
  <xsl:variable name="next" select="(following::foil
                                    |following::foilgroup)[1]"/>
  <xsl:variable name="prev" select="(preceding-sibling::foil[1]
                                    |parent::foilgroup[1]
                                    |/slides)[last()]"/>

  <body class="foil">
    <xsl:call-template name="body.attributes"/>
    <xsl:choose>
      <xsl:when test="$active.toc != 0">
        <xsl:attribute name="onload">
          <xsl:text>newPage('</xsl:text>
          <xsl:value-of select="$thisfoil"/>
          <xsl:text>',</xsl:text>
          <xsl:value-of select="$overlay"/>
          <xsl:text>);</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$overlay != 0">
        <xsl:attribute name="onload">
          <xsl:text>overlaySetup('lc');</xsl:text>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="$keyboard.nav != 0">
      <xsl:attribute name="onkeypress">
        <xsl:text>navigate(event)</xsl:text>
      </xsl:attribute>
    </xsl:if>

    <div class="{name(.)}" id="{$id}">
      <a name="{$id}"/>
      <xsl:if test="$multiframe=0">
        <xsl:call-template name="foil-top-nav">
          <xsl:with-param name="home" select="$home"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:apply-templates/>

      <xsl:if test="$multiframe=0">
        <div id="overlayDiv">
          <xsl:if test="$overlay != 0">
            <xsl:attribute name="style">
              <xsl:text>position:absolute;visibility:visible;</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="foil-bottom-nav">
            <xsl:with-param name="home" select="$home"/>
            <xsl:with-param name="up" select="$up"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </div>

    <xsl:call-template name="process.footnotes"/>
  </body>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="slidesinfo" mode="toc">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <DIV id="{$id}" class="toc-slidesinfo">
    <A href="{$titlefoil.html}" target="foil">
      <xsl:choose>
        <xsl:when test="titleabbrev">
          <xsl:apply-templates select="titleabbrev" mode="toc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title" mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </A>
    <hr/>
  </DIV>
</xsl:template>

<xsl:template match="foilgroup" mode="toc">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="thisfoilgroup">
    <xsl:text>foilgrp</xsl:text>
    <xsl:number count="foilgroup" level="any" format="01"/>
    <xsl:value-of select="$html.ext"/>
  </xsl:variable>

  <DIV class="toc-foilgroup" id="{$id}">
    <img alt="-">
      <xsl:attribute name="src">
        <xsl:call-template name="minus.image"/>
      </xsl:attribute>
    </img>
    <A href="{$thisfoilgroup}" target="foil">
      <xsl:choose>
        <xsl:when test="titleabbrev">
          <xsl:apply-templates select="titleabbrev" mode="toc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title" mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </A>
    <xsl:apply-templates select="foil" mode="toc"/>
  </DIV>
</xsl:template>

<xsl:template match="foil" mode="toc">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
  <xsl:variable name="foil">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <DIV id="{$id}" class="toc-foil">
    <img alt="-">
      <xsl:attribute name="src">
        <xsl:call-template name="bullet.image"/>
      </xsl:attribute>
    </img>
    <A href="{$foil}" target="foil">
      <xsl:choose>
        <xsl:when test="titleabbrev">
          <xsl:apply-templates select="titleabbrev" mode="toc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title" mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </A>
  </DIV>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="slidesinfo" mode="ns-toc">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:text>myList.addItem('</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;DIV id="</xsl:text>
  <xsl:value-of select="$id"/>
  <xsl:text disable-output-escaping="yes">" class="toc-slidesinfo"&gt;</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;A href="</xsl:text>
  <xsl:value-of select="$titlefoil.html"/>
  <xsl:text disable-output-escaping="yes">" target="foil"&gt;</xsl:text>

  <xsl:call-template name="string.subst">
    <xsl:with-param name="string">
      <xsl:choose>
        <xsl:when test="titleabbrev">
          <xsl:value-of select="titleabbrev"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="target">'</xsl:with-param>
    <xsl:with-param name="replacement">\'</xsl:with-param>
  </xsl:call-template>

  <xsl:text disable-output-escaping="yes">&lt;/A&gt;&lt;/DIV&gt;</xsl:text>
  <xsl:text>');&#10;</xsl:text>
</xsl:template>

<xsl:template match="foilgroup" mode="ns-toc">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:text>subList = new List(false, width, height, "</xsl:text>
<xsl:value-of select="$toc.bg.color"/>
<xsl:text>");&#10;</xsl:text>
  <xsl:text>subList.setIndent(12);&#10;</xsl:text>
  <xsl:apply-templates select="foil" mode="ns-toc"/>

  <xsl:text>myList.addList(subList, '</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;DIV id="</xsl:text>
  <xsl:value-of select="$id"/>
  <xsl:text disable-output-escaping="yes">" class="toc-section"&gt;</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;A href="</xsl:text>
  <xsl:apply-templates select="." mode="filename"/>
  <xsl:text disable-output-escaping="yes">" target="foil"&gt;</xsl:text>

  <xsl:choose>
    <xsl:when test="titleabbrev">
      <xsl:value-of select="titleabbrev"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="title"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text disable-output-escaping="yes">&lt;/A&gt;&lt;/DIV&gt;</xsl:text>
  <xsl:text>');&#10;</xsl:text>
</xsl:template>

<xsl:template match="foil" mode="ns-toc">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:choose>
    <xsl:when test="ancestor::foilgroup">
      <xsl:text>subList.addItem('</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>myList.addItem('</xsl:text>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text disable-output-escaping="yes">&lt;DIV id="</xsl:text>
  <xsl:value-of select="$id"/>
  <xsl:text disable-output-escaping="yes">" class="toc-foil"&gt;</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;img alt="-" src="</xsl:text>
  <xsl:call-template name="bullet.image"/>
  <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>

  <xsl:text disable-output-escaping="yes">&lt;A href="</xsl:text>
  <xsl:apply-templates select="." mode="filename"/>
  <xsl:text disable-output-escaping="yes">" target="foil"&gt;</xsl:text>

  <xsl:choose>
    <xsl:when test="titleabbrev">
      <xsl:value-of select="titleabbrev"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="title"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text disable-output-escaping="yes">&lt;/A&gt;&lt;/DIV&gt;</xsl:text>
  <xsl:text>');&#10;</xsl:text>
</xsl:template>

<xsl:template match="speakernotes" mode="ns-toc">
  <!-- nop -->
</xsl:template>

<!-- ====================================================================== -->

</xsl:stylesheet>
