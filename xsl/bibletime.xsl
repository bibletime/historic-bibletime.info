<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:html='http://www.w3.org/1999/xhtml'
			xmlns='http://www.w3.org/1999/xhtml'
               xmlns:doc="http://docbook.sourceforge.net/release/xsl/current/doc/"
               exclude-result-prefixes="doc html"
			version="1.0">

<xsl:import href="website-common.xsl"/>
<xsl:include href="toc-bibletime.xsl"/>
<xsl:include href="head-bibletime.xsl"/>

<xsl:output method="xml"
            indent="no"
		  omit-xml-declaration="yes"
	       encoding="UTF-8"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
/>

<xsl:param name="page-language" select="'.'"/>

<xsl:variable name="l10n.gentext.language"><xsl:value-of select="$page-language"/></xsl:variable>
<xsl:variable name="l10n.gentext.default.language">en</xsl:variable>

<xsl:param name="autolayout" select="document($autolayout-file, /*)"/>
<xsl:param name="devotional" select="document('devotional.xml', /*)"/>
<xsl:param name="tips" select="document('sidebar_tips.xml', /*)"/>

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
<xsl:param name="make.single.year.ranges">0</xsl:param>
<xsl:param name="make.year.ranges">1</xsl:param>
<xsl:param name="nav.graphics">1</xsl:param>


<!-- ==================================================================== -->
<xsl:param name="html.base">http://www.bibletime.info/</xsl:param>
<xsl:param name="generate.id.attributes" select="0"/>
<!-- ==================================================================== -->

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
					<xsl:when test="$exec != ''">
							<xsl:comment>#exec cmd="<xsl:value-of select="$exec"/>"</xsl:comment>
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
				<xsl:apply-templates mode="footer.mode" select="$autolayout/autolayout/copyright"/>
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>


<xsl:template name="print-flag">
	<xsl:param name="lang" />
	<xsl:param name="htmlfilename" />
	
	<a>
		<xsl:attribute name="title">
			<xsl:value-of select="$lang"/>
		</xsl:attribute>
		
		<xsl:attribute name="href">				
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$lang"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$htmlfilename"/>
		</xsl:attribute>
	
		<img>
			<xsl:attribute name="alt">
				<xsl:value-of select="$lang"/>
			</xsl:attribute>			
			
			<xsl:attribute name="src">
				<xsl:text>/images/flags/</xsl:text>
				<xsl:value-of select="$lang"/>
				<xsl:text>.png</xsl:text>
			</xsl:attribute>			
			
		</img>
	</a>
</xsl:template>

<xsl:template name="output-flags">
   	<xsl:param name="langs" /> 
   	<xsl:param name="htmlfilename" />
	   
	<xsl:choose>
		<xsl:when test="string-length(normalize-space( substring-before($langs, ' ') )) &gt; 0" > 
			<xsl:call-template name="print-flag">
		   		<xsl:with-param name="lang" select="substring-before(normalize-space($langs), ' ')" />
				<xsl:with-param name="htmlfilename" select="$htmlfilename" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="string-length(normalize-space($langs)) &gt; 0" > 
			<xsl:call-template name="print-flag">
				<xsl:with-param name="lang" select="normalize-space($langs)" />
				<xsl:with-param name="htmlfilename" select="$htmlfilename" />
			</xsl:call-template>
		</xsl:when>
		
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
	
     <xsl:if test="string-length(normalize-space(substring-after($langs, ' '))) &gt; 0" >
		<xsl:call-template name="output-flags">
			<xsl:with-param name="langs" select="substring-after($langs, ' ')" />
			<xsl:with-param name="htmlfilename" select="$htmlfilename" />
		</xsl:call-template>
	</xsl:if>
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

  <xsl:variable name="entry" select="$autolayout//*[@id=$id]"/>
  <xsl:variable name="htmlfilename" select="concat($entry/@dir,$entry/@filename)"/>

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
      			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
      			</xsl:attribute>

			<div id="pagetop">
				<img height="99" class="left" alt="pagetop logo" src="/images/pagetop-left.png"/>
				<div id="flags">
					<xsl:call-template name="output-flags">
						<xsl:with-param name="langs"><xsl:text>en de fi fr nn pt-br ko ru</xsl:text></xsl:with-param>
						<xsl:with-param name="htmlfilename" select="$htmlfilename" />
					</xsl:call-template>
				</div>
			</div>

			<table id="page">
				<tr><td>
				<div id="navigation">
					<xsl:choose>
						<xsl:when test="$toc">
							<xsl:apply-templates select="$toc">
								<xsl:with-param name="pageid" select="@id"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>

					<div id="logos">
						<a href="http://www.sf.net/projects/bibletime/"><img src="http://sourceforge.net/sflogo.php?group_id=954&amp;type=1" alt="sf logo" width="88" height="31"/></a>
						<br/>
						<a href="http://validator.w3.org/check/referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0" height="31" width="88" /></a>
						<br/>
						<a href="http://jigsaw.w3.org/css-validator/check/referer"><img src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS"/></a>
						<br/>
<!-- 						<img alt="counter" src="http://cgicounter.puretec.de/cgi-bin/cnt?clsid=6bfe60d8ff2e9c56d7db8be538c054421"/> -->
						<img alt="counter" src="http://www.bibletime.info/cgi-sys/Count.cgi?df=bibletime.dat|display=Counter|ft=0|md=6|frgb=100;139;216|dd=B"/>
					</div>
					
					<div id="copyright">
						<xsl:call-template name="webpage.footer"/>
					</div>

				</div>

				<div id="content">
					<xsl:apply-templates select="child::*[name(.) != 'webpage']"/>
					<xsl:call-template name="process.footnotes"/>
				</div>
				
				<div id="rightpanel">
					<xsl:apply-templates select="$devotional" mode="intro"/>
					<xsl:apply-templates select="$tips" mode="tips"/>
				</div>

			</td></tr></table>
<a style="display:none;color:transparent;background:transparent;" href="http://leakage.joachim-ansorg.de/" > </a>
		</body>
	</html>
</xsl:template>

<!-- Called with the devotional file to display the short intro on the right -->
<xsl:template match="id('devotional')" mode="intro">
	<div id="devotional">
		<h3><xsl:value-of select="./child::section[position()=1]/title"/></h3>
		
		<xsl:apply-templates select="./child::section[position()=1]/para[position()=1]" />	
		
		<xsl:if test="count(./child::section[position()=1]/para) &gt; 1">
			<p>[ <a href="devotional.html">Read more...</a> ]</p>
		</xsl:if>		
	

	</div>
</xsl:template>

<!-- Called with the sidebar_tips file to display the short intro on the right -->
<xsl:template match="id('sidebar_tips')" mode="tips">
	<div class="tip">
		<xsl:for-each select="./child::section">
			<h3><xsl:value-of select="./title"/></h3>
		
			<xsl:apply-templates select="./para" />
		</xsl:for-each>
	

	</div>
</xsl:template>


<xsl:template match="config[@param='filename']" mode="head.mode">
</xsl:template>

<xsl:template match="webtoc">
  <!-- nop -->
</xsl:template>

</xsl:stylesheet>
