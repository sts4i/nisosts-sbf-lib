<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xml:lang="en"
  xmlns:isosts="http://www.iso.org/ns/isosts" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sbf="http://transpect.io/schematron-batch-fix" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:tr="http://transpect.io">

  <!-- Copyright 2017–2024 ISO and contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. -->

  <!-- Set the allow-foreign parameter to 'true' when invoking the default ISO Schematron
    implementation -->

  <xsl:import href="http://transpect.io/xslt-util/num/xsl/num.xsl"/>
  <xsl:param name="target-niso-version"/>

  <ns prefix="isosts" uri="http://www.iso.org/ns/isosts"/>
  <ns prefix="tr" uri="http://transpect.io"/>
  <ns prefix="tbx" uri="urn:iso:std:iso:30042:ed-1"/>
  <ns prefix="c" uri="http://www.w3.org/ns/xproc-step"/>
  <ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <ns prefix="file" uri="http://expath.org/ns/file"/>
  <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
 
  <xsl:include href="NISOSTS_lib.xsl"/>
  
  <pattern id="image_file_names">
    <rule id="image_file_names_rule2" context="graphic[@xlink:href]">
      <assert test="@xlink:href = /c:archive/c:entry/@name" id="image_file_names_a1" role="warning"><name/> attribute
        xlink:href points to '<xsl:value-of select="@xlink:href"/>'. The archive does not contain an image file with this
        exact path/filename.
        <sbf:xproc-fix href="http://niso-sts.org/sbf-lib/schematron/xproc-fixes/zip-graphic-names.xpl" 
          operates-on="expanded-archive-manifest-and-contents">
          <sbf:xsl-uri namespace-uri="http://www.w3.org/ns/xproc-step" mode="adjust-manifest-href" 
            href="http://niso-sts.org/sbf-lib/schematron/xproc-fixes/adjust-manifest-hrefs.xsl"/>
          <sbf:xsl-uri namespace-uri="" mode="adjust-graphic-href" 
            href="http://niso-sts.org/sbf-lib/schematron/xproc-fixes/adjust-graphic-hrefs.xsl"/>
        </sbf:xproc-fix>
      </assert>
    </rule>
  </pattern>


</schema>
