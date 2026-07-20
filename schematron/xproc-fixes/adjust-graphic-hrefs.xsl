<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xs c"
  version="3.0">
  
  <xsl:mode name="adjust-graphic-href" on-no-match="shallow-copy"/>

  <xsl:param name="manifest" as="document-node(element(c:archive))?"/>

  <xsl:template match="graphic/@xlink:href" mode="adjust-graphic-href">
    <xsl:variable name="old-href" as="xs:string" select="string(.)"/>
    <xsl:variable name="corresponding-entry-candidates" as="element(c:entry)*" 
      select="$manifest/c:archive/c:entry[starts-with(@content-type, 'image/')]
                                         [replace(replace(@name-old, '^.+/', ''), '\..+$', '') = $old-href]"/>
    <xsl:attribute name="{name()}" select="$corresponding-entry-candidates[1]/@name"/>
  </xsl:template>

</xsl:stylesheet>