<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://niso-sts.org/sbf-lib/schema/sbf/sbf.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sbf="http://transpect.io/schematron-batch-fix"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <sch:ns uri="urn:iso:std:iso:30042:ed-1" prefix="tbx"/>
  <sch:ns uri="http://www.iso.org/ns/isosts" prefix="isosts"/>
  <sch:ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  
  <sbf:extends href="http://niso-sts.org/sbf-lib/schematron/NISOSTS_lib.sch">
    <sbf:pattern deselect="NISOSTS_iso-like-ids"/>
    <sbf:pattern selected-alternative="remove-dtd-version-att"/>
    <sbf:pattern selected-alternative="add_dimension_p_to_caption"/>
  </sbf:extends>
  
  <sch:pattern id="para-interruptors">
    <sch:rule id="para-interruptors_rule1" context="p | th | td (:notes, examples and other stuff must be allowed in table cells :)">
      <sch:report test="exists(*[isosts:is-para-interruptor(.)])" id="para-interruptors_r1" role="warning">Block-level elements should not nest.
        Context: <sch:name/>, interruptor: <sch:value-of select="*[isosts:is-para-interruptor(.)]/name()"/>
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/osd-flatten-paras.xsl" mode="split-paras"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="sec-type">
    <sch:rule id="sec-type_rule1" context="sec[matches(@sec-type, '^foreword\..+$')]">
      <!--https://jira.din.de/browse/DMPRODTECH-148-->
      <sch:report test="true()" id="sec-type_r1" role="warning">sec-type '<sch:value-of select="@sec-type"/>' 
        should be '<sch:value-of select="replace(@sec-type, '^(.+)\..+$', '$1')"/>' 
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/sec-type.xsl" mode="sec-type-strip-suffix"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="graphic-in-p">
    <sch:rule id="graphic-in-p_rule1" context="p[graphic][every $node in (text()[normalize-space()] | *) satisfies ($node/self::graphic)]">
      <sch:report test="true()" id="graphic-in-p_r1" role="warning">Using an unknown internal DTD for validation, Fonto complains about p/graphic. 
        Dissolving the p if graphic is the only content.
        <sbf:xsl-fix href="xslt-fixes/graphic.xsl" mode="unwrap-p-around-graphic"/>
      </sch:report>
    </sch:rule>
    <sch:rule id="graphic-in-p_rule2" context="p[graphic]" role="error">
      <sch:report test="true()" id="graphic-in-p_r2">Using an unknown internal DTD for validation, Fonto complains about p/graphic. 
        Cannot dissolve the p here since there is other content, too.
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="remove-dtd-version-att" sbf:alternative-for="dtd-version">
    <sch:rule id="remove-dtd-version-att_rule1" context="*[@dtd-version]">
      <sch:report test="true()" id="remove-dtd-version-att_r1" role="warning">The OSD web editor does not like the dtd-version attribute.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/dtd-version.xsl" mode="remove-dtd-version"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="add_dimension_p_to_caption" sbf:alternative-for="dimensions_not_in_fig_caption">
    <sch:rule id="add_dimension_p_to_caption_rule1" 
              context="p[empty(isosts:lang(.))]
                        [matches(., isosts:i18n-strings-no-lang('dimension-heading'))]
                        [following-sibling::*[1]/self::fig]">
      <sch:report test="true()" id="add_dimension_p_to_caption_r1" role="warning">
        This <name/> should have an @content-type="dimension" and be put in the caption of the following fig.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/caption.xsl" mode="add_dimension_p_to_caption"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="units-content-type">
    <sch:rule id="units-content-type_rule1" context="*[@content-type=('Units','units')]">
      <sch:report test="true()" id="units-content-type_r1" role="warning">Dimensions in OSD should have the content-type "dimension"
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/caption.xsl" mode="units-content-type"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="unwrap-fn-group">
    <sch:rule id="unwrap-fn-group_rule1" context="fn-group">
      <sch:report test="true()" id="unwrap-fn-group_r1" role="warning">Footnote should not be part of fn-group.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/fn-group.xsl" mode="unwrap-fn-group"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>

  <sch:pattern id="unwrap-app-around-ref-list">
    <sch:rule  id="unwrap-app-around-ref-list_rule1" context="app[ref-list[@content-type = 'bibl']]">
      <sch:report test="true()" id="unwrap-app-around-ref-list_r1" role="warning">Bibliography ref-lists need to be pulled out of surrounding app and app-group elements.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/ref-list.xsl" mode="unwrap-app-around-ref-list"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="add-empty-bibl">
    <sch:rule id="add-empty-bibl_rule1" context="back">
      <sch:report test="not(descendant::ref-list)" role="warning" id="add-empty-bibl_r1">For the OSD import a bibliography must exist.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/ref-list.xsl" mode="add-empty-bibl"/>
      </sch:report>
    </sch:rule>
    <sch:rule id="add-empty-bibl_rule2" context="*[body][not(back)]/body">
      <sch:report test="true()" role="warning" id="add-empty-bibl_r2">
        For the OSD import a backmatter with a bibliography must exist.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/ref-list.xsl" mode="add-empty-bibl"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="rm-orientation-pi">
    <sch:rule id="rm-orientation-pi_rule1" context="*[processing-instruction('orientation')]">
      <sch:report test="true()" id="rm-orientation-pi_r1" role="warning">Processing-instruction "orientation" is not allowed.
        <sbf:xsl-fix href="xslt-fixes/pi.xsl" mode="rm-orientation-pi"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="named-content">
    <sch:rule id="named-content_rule1" context="tbx:*/named-content[@content-type=('label')]">
      <sch:report test="true()" id="named-content_r1" role="warning">Labels in TBX are redundant. Removing.
        <sbf:xsl-fix href="xslt-fixes/named-content.xsl" mode="named-content" depends-on="unnumbered-tbx-note_r1"/>
      </sch:report>
    </sch:rule>
    <sch:rule id="named-content_rule2" context="named-content[@content-type=('standard.designation','ordering.details','label')]">
      <sch:report test="not(parent::tbx:* and @content-type='label')" id="named-content_r2" role="warning">OSD does not display named-content.
        Converting content-type '<sch:value-of select="@content-type"/>' to bold.
        <sbf:xsl-fix href="xslt-fixes/named-content.xsl" mode="named-content"/>
      </sch:report>
    </sch:rule>
    <sch:rule id="named-content_rule3" context="named-content[not(@content-type=('standard.designation','ordering.details','label'))]">
      <sch:report test="true()" id="named-content_r3" role="warning">OSD does not display named-content.
        named-content for unknown content-type <sch:value-of select="@content-type"/> removed.
        <sbf:xsl-fix href="xslt-fixes/named-content.xsl" mode="named-content" depends-on="named-content_dke_variable_r1"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="named-content_dke">
    <sch:rule id="named-content_dke_variable" context="named-content[@content-type = 'variable']">
      <sch:report test="true()" role="warning" id="named-content_dke_variable_r1">OSD does not display named-content.
        Converting content-type 'variable' to italic.
      <sbf:xsl-fix href="xslt-fixes/named-content.xsl" mode="named-content_dke"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="code-in-preformat">
    <sch:rule id="code-in-preformat_rule1" context="preformat">
      <sch:report id="code-in-preformat_r1" test="true()" role="warning">
        Instead of '<sch:name/>', 'code' should be used.
        <sbf:xsl-fix href="xslt-fixes/code.xsl" mode="preformat-to-code"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="no-foreword-sub-sec">
    <sch:rule id="no-foreword-sub-sec_rule1" context="*[self::front or self::adoption-front]/sec[matches(@sec-type,'foreword') or matches(@specific-use,'foreword')][sec[not(label) or label[not(node())]]]">
      <sch:report test="true()" id="no-foreword-sub-sec_r1" role="error">
        No unnumbered subsections allowed in forewords.
        <sbf:xsl-fix href="xslt-fixes/sec.xsl" mode="no-foreword-sub-sec"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="remove-tbx-labels">
    <sch:rule id="remove-tbx-labels_rule1" context="tbx:*/bold[@specific-use='label']">
      <sch:report test="true()" id="remove-tbx-labels_r1" role="warning">
        Labels in TBX are redundant. Removing.
        <sbf:xsl-fix href="xslt-fixes/label.xsl" mode="remove-tbx-labels"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="remove-source-label">
    <sch:rule id="remove-source-label_rule1" context="tbx:source[matches(.,'^\[?(QUELLE|SOURCE):?')]">
      <sch:report test="true()" id="remove-source-label_r1" role="warning">
        "QUELLE:" is redundant in TBX. Removing.
        <sbf:xsl-fix href="xslt-fixes/label.xsl" mode="remove-source-label"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="p-section-type">
    <sch:rule id="p-section-type_rule1" context="sec[@sec-type='clause']
                                                    [label[matches(.,'^[NZ]?[A-Z]*[0-9]+(\.[0-9]+)*$')]]
                                                    [title[not(child::node())]]
                                                    [every $sec in following-sibling::sec satisfies $sec[label[matches(.,'^[NZ]?[A-Z]*[0-9]+(\.[0-9]+)*$')]]
                                                    [title[not(child::node())]]]">
      <sch:report test="true()" id="p-section-type_r1" role="warning">
        p-section should have @sec-type numbered-paragraph
        <sbf:xsl-fix href="xslt-fixes/sec.xsl" mode="p-section-type"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="remove-xref-text">
    <sch:rule id="remove-xref-text_rule1" context="xref[text()[normalize-space()]]">
      <sch:report test="not(@ref-type='other')" id="remove-xref-text_r1" role="warning">
        xref should be empty 
        <sbf:xsl-fix href="xslt-fixes/ref.xsl" mode="remove-xref-text"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="annex-type">
    <sch:rule id="annex-type_rule1" context="app">
      <sch:report test="annex-type" id="annex-type_r1" role="warning">
        The annex-type-element should not be used in OSD. It needs to be derived from @content-type on rendering.
        <sbf:xsl-fix href="xslt-fixes/app.xsl" mode="annex-type"/>
      </sch:report>
      <sch:report test="@content-type[not(matches(.,'^(inf|n)ormative$'))] or not(@content-type)" id="annex-type_r2" role="warning">
        @content-type should be “informative” or “normative”.
        <sbf:xsl-fix href="xslt-fixes/app.xsl" mode="annex-type" depends-on="unwrap-app-around-ref-list_r1"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="mixed-citation-with-std">
    <sch:rule id="mixed-citation_with-std_rule1" context="ref/mixed-citation[std[std-ref][following-sibling::italic]][italic]">
      <sch:report test="true()" id="mixed-citation-with-std_r1" role="warning">
        A mixed-citation containing std and italic should be std with std-ref and title
        <sbf:xsl-fix href="xslt-fixes/ref.xsl" mode="std-in-mixed-citation"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="remove-specific-use">
    <sch:rule id="remove-specific-use_rule1" context="title[@specific-use]">
      <sch:report test="matches(@specific-use,'^([NZ]?[A-Z][A-Z]?|[NZ]?[A-Z]?[A-Z]?[0-9.]+[a-z]?)$')" id="remove-specific-use_r1" role="info">
        specific-use for numbering purposes on title will be removed
        <sbf:xsl-fix href="xslt-fixes/label.xsl" mode="remove-specific-use"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="relative-table-widths">
    <sch:rule id="relative-table-widths_rule1" context="table/descendant-or-self::*[not(parent::*[namespace-uri()='http://www.w3.org/1998/Math/MathML'])]
                                                                                   [@width][not(matches(@width,'%$'))]">
      <sch:report test="matches(@width,'^[0-9]+(\.[0-9]+)?([^0-9]*)$')" id="relative-table-widths_r1" role="warning">
        Table widths should not be absolute but relative
        <sbf:xsl-fix href="xslt-fixes/tables.xsl" mode="relative-table-widths"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="pt-to-px">
    <sch:rule id="pt-to-px_rule1" 
              context="*[self::td or self::th]/descendant-or-self::*[not(parent::*[namespace-uri()='http://www.w3.org/1998/Math/MathML'])]
                                                                    [@style]">
      <sch:report test="matches(@style,'[0-9]pt') or matches(@style,'border\-(bottom|top|left|right)\-(style|width)')" id="pt-to-px_r1" role="warning">
        Table widths should be specified in px
        <sbf:xsl-fix href="xslt-fixes/tables.xsl" mode="pt-to-px"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="unnumbered-tbx-note">
    <sch:rule id="unnumbered-tbx-note_rule1" context="tbx:note[not(named-content[@content-type='label'])]">
      <sch:report id="unnumbered-tbx-note_r1" test="preceding-sibling::*[not(self::tbx:note[not(named-content[@content-type='label'])])][1]
                                                                        [self::tbx:note[named-content[@content-type='label']]]" role="warning">
        An unnumbered tbx:note should be part of a preceding numbered tbx:note
        <sbf:xsl-fix href="xslt-fixes/named-content.xsl" mode="unnumbered-tbx-note"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="xref-keyword">
    <sch:rule id="xref-keyword_rule1" 
              context="xref[@ref-type='sec'][matches(string-join(preceding-sibling::node()/descendant-or-self::text()),'Abschnitt[\s&#160;]$')]">
      <sch:report id="xref-keyword_r1" role="warning" test="true()">
        There should not exist keywords before an xref
        <sbf:xsl-fix href="xslt-fixes/sec.xsl" mode="xref-keyword"/>
      </sch:report>
    </sch:rule>
    <sch:rule id="xref-keyword_rule2" 
              context="xref[@ref-type='disp-formula'][matches(string-join(preceding-sibling::node()/descendant-or-self::text()),'Gleichung[\s&#160;]$')]">
      <sch:report id="xref-keyword_r2" role="warning" test="true()">
        There should not exist keywords before an xref
        <sbf:xsl-fix href="xslt-fixes/sec.xsl" mode="xref-keyword"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="fig-group-dimension">
    <sch:rule id="fig-group-dimension_rule1" context="fig-group/fig/caption/p[@content-type=('dimension','units','Units')]">
      <sch:report test="true()" role="warning" id="fig-group-dimension_r1">
        Dimensions can only be represented in the major figure-element. It is not possible to express dimensions in subfigures.
        <sbf:xsl-fix href="http://niso-sts.org/sbf-lib/schematron/xslt-fixes/caption.xsl" mode="fig-group-dimension" depends-on="units-content-type_r1"/>
      </sch:report>
    </sch:rule>
  </sch:pattern>

</sch:schema>


