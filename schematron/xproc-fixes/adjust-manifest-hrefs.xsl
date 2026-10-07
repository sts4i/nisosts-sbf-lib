<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="xs c saxon"
  version="3.0">
  
  <xsl:mode name="adjust-manifest-href" on-no-match="shallow-copy"/>
  
  <xsl:template match="c:entry[@content-type = 'image/png']/@name" mode="adjust-manifest-href">
    <xsl:attribute name="{name()}" select="'media/' || replace(., '^.+/', '')"/>
    <xsl:attribute name="{name()}-old" select="."/>
  </xsl:template>
  
</xsl:stylesheet>