<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:sbf="http://transpect.io/schematron-batch-fix"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  version="3.1" name="test-image-rename">
  <p:import href="../../../sbf/find-files/enrich-archive-manifest.xpl"/>
  <p:output port="result" primary="true" content-types="application/zip">
    <p:pipe port="result" step="repackage"/>
  </p:output>
  <p:output port="manifest" pipe="result@delete-unsupported-manifest-attributes"/>
  <p:option name="zip-file" as="xs:string"/>
  <sbf:enrich-archive-manifest name="enrich-archive-manifest">
    <p:with-option name="zip-file" select="$zip-file"/>
  </sbf:enrich-archive-manifest>
  <p:variable name="params" as="map(*)" 
    select="map{'xslts': 
              map{'http://www.w3.org/ns/xproc-step': 
                map{'href': '/mnt/c/Users/gerrit/DIN/sbf-frontend/nisosts-sbf-lib/schematron/xproc-fixes/adjust-manifest-hrefs.xsl',
                    'mode': xs:QName('adjust-manifest-href')},
                  '#none': 
                map{'href': '/mnt/c/Users/gerrit/DIN/sbf-frontend/nisosts-sbf-lib/schematron/xproc-fixes/adjust-graphic-hrefs.xsl',
                    'mode': xs:QName('adjust-graphic-href')}}}"/>
<!--  <p:identity message="{serialize($params, map{'method': 'adaptive'})}"></p:identity>-->
  <p:run name="run-fix">
    <p:with-input href="/mnt/c/Users/gerrit/DIN/sbf-frontend/nisosts-sbf-lib/schematron/xproc-fixes/zip-graphic-names.xpl"/>
    <p:run-input port="manifest" pipe="result@enrich-archive-manifest" primary="true"/>
    <p:run-input port="zip-contents" pipe="contents@enrich-archive-manifest"/>
    <p:run-option name="parameters" select="$params" />
    <p:output port="result-manifest" primary="true"/>
    <p:output port="result-zip-contents" sequence="true"/>
  </p:run>
  <p:delete match="@name-old | @cx:*" message="{serialize(., map{'method': 'adaptive'})}"
    name="delete-unsupported-manifest-attributes"/>
  <p:sink name="sink0"/>
  <p:archive name="repackage">
    <p:with-input port="source" pipe="result-zip-contents@run-fix"/>
    <p:with-input port="manifest" pipe="result@delete-unsupported-manifest-attributes"/>
  </p:archive>
</p:declare-step>