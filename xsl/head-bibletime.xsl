<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
<xsl:import href="head.xsl"/>

<xsl:output method="xml"
            indent="no"
	    encoding="UTF-8"
/>

<xsl:template match="head" mode="head.mode">
  <xsl:variable name="nodes" select="*"/>
  <head>
    <meta name="generator" content="Website XSL Stylesheet V{$VERSION}"/>
    
    <meta http-equiv="content-language">
	<xsl:attribute name="content">
		<xsl:value-of select="$l10n.gentext.language"/>
	</xsl:attribute>
    </meta>
    <meta name="DC.Language">
	<xsl:attribute name="content">
		<xsl:value-of select="$l10n.gentext.language"/>
	</xsl:attribute>    
    </meta>
        
    <xsl:if test="$html.stylesheet != ''">
      <link rel="stylesheet" href="{$html.stylesheet}" type="text/css">
	<xsl:if test="$html.stylesheet.type != ''">
	  <xsl:attribute name="type">
	    <xsl:value-of select="$html.stylesheet.type"/>
	  </xsl:attribute>
	</xsl:if>
      </link>
    </xsl:if>

    <xsl:variable name="thisid" select="ancestor-or-self::webpage/@id"/>
    <xsl:variable name="thisrelpath">
      <xsl:apply-templates select="$autolayout//*[@id=$thisid]" mode="toc-rel-path"/>
    </xsl:variable>

    <xsl:variable name="topid">
      <xsl:call-template name="top.page"/>
    </xsl:variable>

    <xsl:if test="$topid != ''">
      <link rel="home">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$topid]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$topid]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:variable name="upid">
      <xsl:call-template name="up.page"/>
    </xsl:variable>

    <xsl:if test="$upid != ''">
      <link rel="up">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$upid]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$upid]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:variable name="previd">
      <xsl:call-template name="prev.page"/>
    </xsl:variable>

    <xsl:if test="$previd != ''">
      <link rel="previous">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$previd]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$previd]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:variable name="nextid">
      <xsl:call-template name="next.page"/>
    </xsl:variable>

    <xsl:if test="$nextid != ''">
      <link rel="next">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$nextid]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$nextid]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:variable name="firstid">
      <xsl:call-template name="first.page"/>
    </xsl:variable>

    <xsl:if test="$firstid != ''">
      <link rel="first">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$firstid]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$firstid]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:variable name="lastid">
      <xsl:call-template name="last.page"/>
    </xsl:variable>

    <xsl:if test="$lastid != ''">
      <link rel="last">
        <xsl:attribute name="href">
          <xsl:call-template name="page.uri">
            <xsl:with-param name="page" select="$autolayout//*[@id=$lastid]"/>
            <xsl:with-param name="relpath" select="$thisrelpath"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$autolayout//*[@id=$lastid]/title"/>
        </xsl:attribute>
      </link>
    </xsl:if>

    <xsl:apply-templates select="$autolayout/autolayout/style
                                 |$autolayout/autolayout/script
                                 |$autolayout/autolayout/headlink"
                         mode="head.mode">
      <xsl:with-param name="webpage" select="ancestor::webpage"/>
    </xsl:apply-templates>
    <xsl:apply-templates mode="head.mode"/>
    <xsl:call-template name="user.head.content">
      <xsl:with-param name="node" select="ancestor::webpage"/>
    </xsl:call-template>
  </head>
</xsl:template>



<xsl:template match="style" mode="head.mode">
  <style>
    <xsl:if test="@type">
      <xsl:attribute name="type">
				<xsl:value-of select="@type"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@title">
      <xsl:attribute name="title">
				<xsl:value-of select="@title"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates/>

  </style>
</xsl:template>


<xsl:template match="style[@src]" mode="head.mode" priority="2">
  <xsl:param name="webpage" select="ancestor::webpage"/>
  <xsl:variable name="relpath">
    <xsl:call-template name="root-rel-path">
      <xsl:with-param name="webpage" select="$webpage"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="starts-with(@src, '/')">
      <link rel="stylesheet" href="{@src}">
        <xsl:if test="@type">
          <xsl:attribute name="type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:if>
      </link>
    </xsl:when>
    <xsl:otherwise>
      <link rel="stylesheet" href="{$relpath}{@src}">
        <xsl:if test="@type">
          <xsl:attribute name="type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@title">
          <xsl:attribute name="title">
            <xsl:value-of select="@title"/>
          </xsl:attribute>
        </xsl:if>
      </link>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="title" mode="head.mode">
  <title>www.bibletime.info: <xsl:value-of select="."/></title>
</xsl:template>


</xsl:stylesheet>
