<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:sbf="http://transpect.io/schematron-batch-fix"
  xmlns:stssbf="http://niso-sts.org/sbf-lib/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  version="3.1" name="zip-graphic-names"
  type="stssbf:zip-graphic-names">
  <p:import href="../../../sbf/find-files/enrich-archive-manifest.xpl"/>
  <p:input port="manifest" content-types="xml" primary="true">
    <p:documentation>A ZIP manifest (c:archive) where each c:entry of XML files is enriched with a namespace-uri attribute
      that contains the top-level element’s namespace URI (that may be the string '#none' for no namespace).</p:documentation>
  </p:input>
  <p:input port="zip-contents" content-types="any" sequence="true"/>
  <p:output port="result-manifest" content-types="xml" primary="true" pipe="result@fix-manifest"/>
<!--  <p:output port="result-zip-contents" content-types="any" sequence="true" pipe="zip-contents@zip-graphic-names"/>-->
  <p:output port="result-zip-contents" content-types="any" sequence="true" pipe="result@fix-base-uris-and-xmls"/>
  <p:option name="parameters" as="map(*)"/>
  
  <p:variable name="xslts" as="map(*)" select="map:get($parameters, 'xslts')">
    <p:documentation>A map with namespace URIs as key and another map as each value. This map has the keys 'href' 
      (xs:string), 'mode' (xs:string), and 'parameters' (map(xs:QName, item()*))</p:documentation>
  </p:variable>
  <p:identity message="$xslts('http://www.w3.org/ns/xproc-step'):
    {serialize(map:get($xslts, 'http://www.w3.org/ns/xproc-step'), map{'method': 'adaptive'})}"></p:identity>
  <p:xslt name="fix-manifest" initial-mode="adjust-manifest-href">
    <p:documentation>If the base uri (href) changes in the manifest, the corresponding document should get this new
    base uri as a document property. In order to change the base uri, the following p:for-each needs to see both the 
    old and the new c:entry/@href. If the href is changed, the XSLT needs to copy the old attribute to
    c:entry/@name-old.</p:documentation>
    <p:with-input port="stylesheet">
      <p:document href="{$xslts('http://www.w3.org/ns/xproc-step')('href')}"/>
    </p:with-input>
  </p:xslt>
  <p:sink name="sink0"/>
  <p:for-each name="fix-base-uris-and-xmls">
    <p:output port="result"/>
    <p:with-input pipe="zip-contents@zip-graphic-names"/>
    <p:variable name="base-uri" as="xs:string" select="p:document-property(., 'base-uri')"/>
    <p:variable name="namespace-uri" as="xs:string?" select="//c:entry[@href = $base-uri]/@namespace-uri" 
      pipe="result@fix-manifest"/>
    <p:identity name="current-doc" message="base URI: {p:document-properties(.)('base-uri')}, $namespace-uri: {$namespace-uri}, map:get($xslts, $namespace-uri):
      {if ($namespace-uri) then serialize(map:get($xslts, $namespace-uri), map{'method': 'adaptive'}) 
       else 'no XSLT for non-XML input'}"/>
    <p:choose name="for-xml-input">
      <p:when test="exists($namespace-uri) and exists(map:get($xslts, $namespace-uri))">
        <p:load name="load-xslt" href="{$xslts($namespace-uri)('href')}" message="{'LOAD ' ||
          $xslts($namespace-uri)('href')}"/>
        <p:sink name="sink2"/>
        <p:xslt name="fix-xml">
          <p:with-input port="stylesheet" pipe="result@load-xslt"/>
          <p:with-input port="source">
            <p:pipe port="result" step="current-doc"/>
          </p:with-input>
          <p:with-option name="parameters" select="map{xs:QName('manifest'): .}" pipe="result@fix-manifest"/>
          <p:with-option name="output-base-uri" select="$base-uri"/>
          <p:with-option name="initial-mode" select="$xslts($namespace-uri)('mode')"/>
        </p:xslt>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>
  </p:for-each>
  <p:sink name="sink1"/>
</p:declare-step>
