<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html='http://www.w3.org/1999/xhtml'
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                exclude-result-prefixes="html doc"
                version="1.0">

<xsl:import href="website-common.xsl"/>
<xsl:include href="toc-bibletime.xsl"/>
<xsl:include href="head-bibletime.xsl"/>

<xsl:output method="xml"
            indent="yes"
			encoding="UTF-8"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
/>

<xsl:param name="autolayout" select="document($autolayout-file, /*)"/>

<!-- ==================================================================== -->

<!-- Netscape gets badly confused if it sees a CSS style... -->
<xsl:param name="admon.style" select="''"/>
<xsl:param name="admon.graphics" select="0"/>
<xsl:param name="admon.graphics.path">/images/</xsl:param>
<xsl:param name="admon.graphics.extension">.gif</xsl:param>

<!-- ==================================================================== -->

<xsl:param name="callout.graphics">0</xsl:param>

<xsl:param name="css.decoration">0</xsl:param>
<xsl:param name="use.viewport">0</xsl:param>
<xsl:param name="spacing.paras">0</xsl:param>
<xsl:param name="make.valid.html">1</xsl:param>
<xsl:param name="html.cleanup">1</xsl:param>
<xsl:param name="make.single.year.ranges">1</xsl:param>
<xsl:param name="make.year.ranges">1</xsl:param>
<xsl:param name="nav.graphics">1</xsl:param>

<xsl:template match="ssi">
	<xsl:variable name="page" select="."/>
	<xsl:variable name="mode" select="$page/@mode"/>

  <xsl:choose>
    <xsl:when test="$mode='exec'">
				<xsl:variable name="cgi" select="$page/@cgi"/>
				<xsl:variable name="exec" select="$page/@cmd"/>
			  <xsl:choose>
					<xsl:when test="$cgi != ''">
							<xsl:comment>#exec cgi="<xsl:value-of select="$cgi"/>"</xsl:comment>
					</xsl:when>
					<xsl:when test="$cmd != ''">
							<xsl:comment>#exec cmd="<xsl:value-of select="$cmd"/>"</xsl:comment>
					</xsl:when>
				</xsl:choose>
		</xsl:when>
    <xsl:when test="$mode='include'">
				<xsl:variable name="file" select="$page/@file"/>
				<xsl:variable name="virtual" select="$page/@virtual"/>
			  <xsl:choose>
					<xsl:when test="$file != ''">
							<xsl:comment>#virtual file="<xsl:value-of select="$file"/>"</xsl:comment>
					</xsl:when>
					<xsl:when test="$virtual != ''">
							<xsl:comment>#include virtual="<xsl:value-of select="$virtual"/>"</xsl:comment>
					</xsl:when>
				</xsl:choose>
		</xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>

</xsl:template>


<!-- ==================================================================== -->

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>



<xsl:template name="webpage.footer">
  <xsl:variable name="page" select="."/>
  <xsl:variable name="footers" select="$page/config[@param='footer']
                                       |$page/config[@param='footlink']
                                       |$autolayout/autolayout/config[@param='footer']
                                       |$autolayout/autolayout/config[@param='footlink']"/>

  <xsl:variable name="tocentry" select="$autolayout//*[@id=$page/@id]"/>
  <xsl:variable name="toc" select="($tocentry/ancestor-or-self::toc[1]
                                   | $autolayout//toc[1])[last()]"/>

	<span id="footcopy">
		<xsl:choose>
			<xsl:when test="head/copyright">
				<xsl:apply-templates select="head/copyright" mode="footer.mode"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="footer.mode"
					select="$autolayout/autolayout/copyright"/>
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:template match="webpage">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="relpath">
    <xsl:call-template name="root-rel-path">
      <xsl:with-param name="webpage" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:variable name="tocentry" select="$autolayout/autolayout//*[$id=@id]"/>
  <xsl:variable name="toc" select="($tocentry/ancestor-or-self::toc
                                   |$autolayout/autolayout/toc[1])[last()]"/>

	<html>
		<xsl:apply-templates select="head" mode="head.mode"/>
		<xsl:apply-templates select="config" mode="head.mode"/>

		<body>
			<div id="header">
				<img src="/images/pagetop-right.png"/>

				<div id="flags">
					<a title="en" href="/en/"><img src="/images/flags/en.png"/></a>

					<a title="de" href="/de/"><img src="/images/flags/de.png"/></a>
					<a title="pt-br" href="/pt-br/"><img src="/images/flags/pt-br.png"/></a>
					<a title="ro" href="/ro/"><img src="/images/flags/ro.png"/></a>
					<a title="ru" href="/ru/"><img src="/images/flags/ru.png"/></a>
					<a title="ua" href="/ua/"><img src="/images/flags/ua.png"/></a>

					<a href="/"><img src="/images/flags/new-lang.png"/></a>
				</div>
			</div>

			<table id="page">
				<tr><td>
				<div id="navigation">
					<xsl:choose>
						<xsl:when test="$toc">
							<div class="naventry">
								<xsl:apply-templates select="$toc">
									<xsl:with-param name="pageid" select="@id"/>
								</xsl:apply-templates>
							</div>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>

					<div id="logos">
						<a href="http://www.sf.net/projects/bibletime/" target="_blank"><img src="http://sourceforge.net/sflogo.php?group_id=954&amp;type=1" alt="sf logo" width="88" height="31" vspace="3" border="0"/></a>
						<br/>
						<img src="http://cgicounter.puretec.de/cgi-bin/cnt?clsid=6bfe60d8ff2e9c56d7db8be538c054421"/>
					</div>
				</div>

				<div id="rightpanel"></div>

				<div id="content">
					<xsl:apply-templates select="child::*[name(.) != 'webpage']"/>
					<xsl:call-template name="process.footnotes"/>
				</div>

			</td></tr></table>

			<div id="footer">
				<xsl:call-template name="webpage.footer"/>
			</div>

		</body>
	</html>
</xsl:template>

<xsl:template match="config[@param='filename']" mode="head.mode">
</xsl:template>

<xsl:template match="webtoc">
  <!-- nop -->
</xsl:template>

</xsl:stylesheet>