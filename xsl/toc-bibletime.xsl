<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:output method="xml"
	indent="no"
	encoding="UTF-8"
/>

<xsl:param name="nav.pointer" select="0"/>
<xsl:param name="nav.revisionflag" select="0"/>

<xsl:param name="toc.spacer.text">&#160;&#160;&#160;</xsl:param>
<xsl:param name="toc.spacer.image">/images/blank.gif</xsl:param>

<xsl:param name="nav.icon.path">/images/navicons/</xsl:param>
<xsl:param name="nav.icon.extension">.gif</xsl:param>

<!-- styles: folder, folder16, plusminus, triangle, arrow -->
<xsl:param name="nav.icon.style">bibletime</xsl:param>

<xsl:param name="nav.text.spacer"></xsl:param>
<xsl:param name="nav.text.current.open"></xsl:param>
<xsl:param name="nav.text.current.page"></xsl:param>
<xsl:param name="nav.text.other.open"></xsl:param>
<xsl:param name="nav.text.other.closed"></xsl:param>
<xsl:param name="nav.text.other.page"></xsl:param>
<xsl:param name="nav.text.revisionflag.added">New</xsl:param>
<xsl:param name="nav.text.revisionflag.changed">Changed</xsl:param>
<xsl:param name="nav.text.revisionflag.deleted"></xsl:param>
<xsl:param name="nav.text.revisionflag.off"></xsl:param>

<xsl:param name="nav.text.pointer">&lt;-</xsl:param>

<xsl:param name="toc.expand.depth" select="1"/>

<!-- ==================================================================== -->

<xsl:template match="toc/title|tocentry/title|titleabbrev">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="toc">
  <xsl:param name="pageid" select="@id"/>

  <xsl:variable name="relpath">
    <xsl:call-template name="toc-rel-path">
      <xsl:with-param name="pageid" select="$pageid"/>
    </xsl:call-template>
  </xsl:variable>

  <ul>
	<xsl:apply-templates select="tocentry">
		<xsl:with-param name="pageid" select="$pageid"/>
		<xsl:with-param name="relpath" select="$relpath"/>
	</xsl:apply-templates>
  </ul>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="tocentry">
  <xsl:param name="pageid" select="@id"/>
  <xsl:param name="toclevel" select="count(ancestor::*)"/>
  <xsl:param name="relpath" select="''"/>

  <xsl:variable name="page" select="."/>
  <xsl:variable name="target"
                select="($page/descendant-or-self::tocentry[@tocskip = '0']
                       |$page/following::tocentry[@tocskip='0'])[1]"/>

  <xsl:variable name="depth" select="count(ancestor::*)-1"/>

  <xsl:variable name="isdescendant">
    <xsl:choose>
      <xsl:when test="ancestor::*[@id=$pageid]">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="hasdescendant">
    <xsl:choose>
      <xsl:when test="descendant::tocentry != ''">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="isancestor">
    <xsl:choose>
      <xsl:when test="descendant::*[@id=$pageid]">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="use.toc.expand.depth">
    <xsl:variable name="config-param" select="ancestor::autolayout/config[@param='toc.expand.depth']/@value"/>
    <xsl:choose>
      <!-- toc.expand.depth attribute is not in DTD -->
      <xsl:when test="ancestor::toc/@toc.expand.depth">
        <xsl:value-of select="ancestor::toc/@toc.expand.depth"/>
      </xsl:when>
      <xsl:when test="floor($config-param) > 0">
        <xsl:value-of select="$config-param"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$toc.expand.depth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="is.open">
    <xsl:choose>
      <xsl:when test="$pageid = @id
                      or $isancestor='1'
                      or $depth &lt; $use.toc.expand.depth">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- For any entry in the TOC:
       1. It is the current page
          a. it is a leaf             current/leaf
          b. it is an open page       current/open
       2. It is not the current page
          a. it is a leaf             other/leaf
          b. it is an open page       other/open
          c. it is a closed page      other/closed
  -->

  <li>
   <xsl:choose>	
       <xsl:when test="$pageid = @id">
	<xsl:attribute name="class">current</xsl:attribute>
	
	<span>    
	    <xsl:choose>
            <xsl:when test="titleabbrev">
              <xsl:apply-templates select="titleabbrev"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="title"/>
            </xsl:otherwise>
          </xsl:choose>
	</span>
	
      </xsl:when>
      <xsl:otherwise>
          <xsl:call-template name="link.to.page">
            <xsl:with-param name="href" select="@href"/>
            <xsl:with-param name="page" select="$target"/>
            <xsl:with-param name="relpath" select="$relpath"/>
            <xsl:with-param name="linktext">
              <xsl:choose>
                <xsl:when test="titleabbrev">
                  <xsl:apply-templates select="titleabbrev"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="title"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

        <xsl:choose>
		<xsl:when test="$hasdescendant != 0">
			<ul>
				<xsl:apply-templates select="tocentry">
					<xsl:with-param name="pageid" select="$pageid"/>
					<xsl:with-param name="relpath" select="$relpath"/>
				</xsl:apply-templates>
			</ul>
		</xsl:when>
      		<xsl:otherwise></xsl:otherwise>
    	</xsl:choose>
 	
  </li>

</xsl:template>

<xsl:template name="insert.spacers">
  <xsl:param name="count" select="0"/>
  <xsl:param name="relpath"/>
  <xsl:if test="$count>0">
    <xsl:choose>
      <xsl:when test="$nav.graphics != 0">
        <img src="{$relpath}{$toc.spacer.image}" alt="{$toc.spacer.text}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$toc.spacer.text"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="insert.spacers">
      <xsl:with-param name="count" select="$count - 1"/>
      <xsl:with-param name="relpath" select="$relpath"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="toc|tocentry|notoc" mode="toc-rel-path">
  <xsl:call-template name="toc-rel-path"/>
</xsl:template>

<xsl:template name="toc-rel-path">
  <xsl:param name="pageid" select="@id"/>
  <xsl:variable name="entry" select="$autolayout//*[@id=$pageid]"/>
  <xsl:variable name="filename" select="concat($entry/@dir,$entry/@filename)"/>

  <xsl:variable name="slash-count">
    <xsl:call-template name="toc-directory-depth">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="depth">
    <xsl:choose>
      <xsl:when test="starts-with($filename, '/')">
        <xsl:value-of select="$slash-count - 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$slash-count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<!--
  <xsl:message>
    <xsl:value-of select="$filename"/>
    <xsl:text> depth=</xsl:text>
    <xsl:value-of select="$depth"/>
  </xsl:message>
-->

  <xsl:if test="$depth > 0">
    <xsl:call-template name="copy-string">
      <xsl:with-param name="string">../</xsl:with-param>
      <xsl:with-param name="count" select="$depth"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="toc-directory-depth">
  <xsl:param name="filename"></xsl:param>
  <xsl:param name="count" select="0"/>

  <xsl:choose>
    <xsl:when test='contains($filename,"/")'>
      <xsl:call-template name="toc-directory-depth">
        <xsl:with-param name="filename"
                        select="substring-after($filename,'/')"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$count"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
