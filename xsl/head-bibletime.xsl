<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
<xsl:import href="head.xsl"/>

<xsl:output method="xml"/>

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
