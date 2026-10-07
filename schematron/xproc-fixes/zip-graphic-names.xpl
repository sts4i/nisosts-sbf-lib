<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:sbf="http://transpect.io/schematron-batch-fix"
  xmlns:stssbf="http://niso-sts.org/sbf-lib/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="3.1" name="zip-graphic-names"
  type="stssbf:zip-graphic-names">

  <p:import href="http://transpect.io/sbf/helper/merge-into-archive-manifest.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:pipeinfo>
    <sbf:operates-on>expanded-archive-manifest-and-contents</sbf:operates-on>
  </p:pipeinfo>
  
  
  <p:input port="source" content-types="xml" primary="true">
    <p:documentation>A ZIP manifest (c:archive) where each c:entry of XML files is enriched with a namespace-uri attribute
      that contains the top-level element’s namespace URI (that may be the string '#none' for no namespace).</p:documentation>
  </p:input>
  <p:input port="contents" content-types="any" sequence="true"/>
  <p:input port="this-fix-from-svrl">
    <p:documentation>An sbf:xproc-fix document with sbf:xsl-uri children that specify the URIs and modes of the XSLTs
      to apply to each document in the given namespace.</p:documentation>
  </p:input>
  
  <p:output port="result" content-types="xml" primary="true" pipe="result@merge-into-manifest"/>
  <p:output port="result-contents" content-types="any" sequence="true" pipe="result@fix-xmls"/>
  
  <p:variable name="xsl-for-manifest" as="element(sbf:xsl-uri)?" pipe="this-fix-from-svrl"
    select="/sbf:xproc-fix/sbf:xsl-uri[@namespace-uri = 'http://www.w3.org/ns/xproc-step'][1]"/>
  
  <p:if test="exists($xsl-for-manifest/@href)" name="transform-manifest">
    <p:output port="result" primary="true"/>
    <p:xslt name="fix-manifest" initial-mode="{xs:QName($xsl-for-manifest/@mode)}">
      <p:with-input port="stylesheet">
        <p:document href="{$xsl-for-manifest/@href}"/>
      </p:with-input>
    </p:xslt>
  </p:if>

  <p:sink name="sink0"/>
  <p:for-each name="fix-xmls">
    <p:output port="result" primary="true"/>
    <p:with-input pipe="contents@zip-graphic-names"/>
    <p:variable name="base-uri" as="xs:string" select="p:document-property(., 'base-uri')"/>
    <p:variable name="namespace-uri" as="xs:string?" select="//c:entry[@href = $base-uri]/@namespace-uri" 
      pipe="result@transform-manifest"/>
    <p:variable name="xsl-for-namespace" as="element(sbf:xsl-uri)?" pipe="this-fix-from-svrl@zip-graphic-names"
      select="/sbf:xproc-fix/sbf:xsl-uri[@namespace-uri = $namespace-uri][1]"/>
    <p:identity name="current-doc"/>
    <p:choose name="for-xml-input">
      <p:when test="exists($namespace-uri) and exists($xsl-for-namespace/@href)">
        <p:load name="load-xslt" href="{$xsl-for-namespace/@href}"/>
        <p:sink name="sink2"/>
        <p:xslt name="fix-xml">
          <p:with-input port="stylesheet" pipe="result@load-xslt"/>
          <p:with-input port="source">
            <p:pipe port="result" step="current-doc"/>
          </p:with-input>
          <p:with-option name="parameters" select="map{xs:QName('manifest'): .}" pipe="result@transform-manifest"/>
          <p:with-option name="output-base-uri" select="$base-uri"/>
          <p:with-option name="initial-mode" select="xs:QName($xsl-for-namespace/@mode)"/>
        </p:xslt>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>
  </p:for-each>
  
  <sbf:merge-into-archive-manifest name="merge-into-manifest">
    <p:with-input port="source" pipe="result@transform-manifest"/>
    <p:with-input port="insertions" pipe="result@fix-xmls"/>
  </sbf:merge-into-archive-manifest>
  <!--<tr:store-debug name="store-updated-manifest" active="yes" base-uri="file:/mnt/c/Users/gerrit/DIN/sbf-frontend/debug/"
    pipeline-step="apply-fixes/zip-graphic-names/updated-manifest/{p:document-property(., 'base-uri') => replace('^.+/', '')}.manifest.xml"/>-->
  <p:sink name="sink1"/>
</p:declare-step>
