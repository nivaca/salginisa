<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:my="local functions"
    xmlns:_="localisation">

  <!-- Variables from XML teiHeader -->
  <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
  <xsl:variable name="shorttitle"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title/@rend"/></xsl:variable>
  <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
  <xsl:variable name="shortauthor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author/@rend"/></xsl:variable>
  <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>

  <!-- get versioning numbers -->
  <xsl:param name="sourceversion"><xsl:value-of select="/TEI/teiHeader/fileDesc/editionStmt/edition/@n"/></xsl:param>

  <!-- this xsltconvnumber should be the same as the git tag, and for any commit past the tag should be the tag name plus '-dev' -->
  <xsl:param name="conversionversion">dev</xsl:param>

  <!-- combined version number should have mirror syntax of an equation x+y source+conversion -->
  <xsl:variable name="combinedversionnumber"><xsl:value-of select="$sourceversion"/>+<xsl:value-of select="$conversionversion"/></xsl:variable>
  <!-- end versioning numbers -->

  <!-- BEGIN: Document configuration -->
  <!-- Variables -->
  <xsl:variable name="starts_on" select="/TEI/text/front/div/pb"/>

  <!-- Command line parameters -->
  <xsl:param name="name-list-file">../prosopography.xml</xsl:param>
  <xsl:param name="work-list-file">../bibliography.xml</xsl:param>
  <xsl:param name="localisation-file">../localisation.xml</xsl:param>
  <xsl:param name="app-entry-separator">;</xsl:param>
  <xsl:param name="font-size">12</xsl:param>
  <xsl:param name="ignore-spelling-variants">no</xsl:param>
  <xsl:param name="positive-apparatus">no</xsl:param>
  <xsl:param name="create-critical-apparatus">yes</xsl:param>
  <xsl:param name="apparatus-numbering">no</xsl:param>
  <xsl:param name="parallel-translation">no</xsl:param>
  <xsl:param name="app-fontium-quote">no</xsl:param>
  <xsl:param name="include-app-notes">yes</xsl:param>
  <xsl:param name="app-notes-in-separate-apparatus">no</xsl:param>
  <xsl:param name="standalone-document">yes</xsl:param>
  <xsl:param name="create-structure-numbers">yes</xsl:param>
  <xsl:param name="title-heading-level">section</xsl:param>

  <xsl:variable name="use-positive-apparatus">
    <xsl:choose>
      <xsl:when test="my:istrue($positive-apparatus)">
        <xsl:value-of select="true()"/>
        <xsl:message>Using externally defined positive apparatus for conversion.</xsl:message>
      </xsl:when>
      <xsl:when test="//TEI/text[@ana='#positive-apparatus']">
        <xsl:value-of select="true()"/>
        <xsl:message>Using locally defined positive apparatus for conversion.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="localisations">
    <xsl:copy-of select="document($localisation-file)"/>
  </xsl:variable>

  <!--
      Boolean check lists.
      To make command line parameters more robust, we check whether the value
      passed is one of the possible true or false values defined in these two
      lists with the test "parameter-name = boolean-true/*" (or boolean-false)
      if we test for false value.
  -->
  <xsl:variable name="boolean-true">
    <n>yes</n>
    <n>true</n>
    <n>1</n>
  </xsl:variable>

  <xsl:variable name="boolean-false">
    <n>no</n>
    <n>true</n>
    <n>0</n>
  </xsl:variable>

  <xsl:function name="my:istrue">
    <xsl:param name="parameter-name"/>
    <xsl:if test="lower-case($parameter-name) = $boolean-true/*">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="my:isfalse">
    <xsl:param name="parameter-name"/>
    <xsl:if test="lower-case($parameter-name) = $boolean-false/*">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="my:format-lemma">
    <xsl:param name="text"/>
    <xsl:value-of select="normalize-space(lower-case($text))"/>
  </xsl:function>


  <!-- END: Document configuration -->

  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="div"/>
  <xsl:template match="text()">
    <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>

  <xsl:variable name="text_language">
    <xsl:choose>
      <xsl:when test="//text[@xml:lang='la']">latin</xsl:when>
      <xsl:otherwise>english</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="body">
    <xsl:choose>
      <xsl:when test="my:istrue($parallel-translation)">
        \begin{pages}
        \begin{Leftside}
        <xsl:call-template name="documentDiv">
          <xsl:with-param name="content" select="//body/div" />
          <xsl:with-param name="inParallelText" select="false()"/>
        </xsl:call-template>
        \end{Leftside}

        \begin{Rightside}
        <xsl:call-template name="documentDiv">
          <xsl:with-param name="content" select="document($translationFile)//body/div" />
          <xsl:with-param name="inParallelText" select="true()"/>
        </xsl:call-template>
        \end{Rightside}
        \end{pages}
        \Pages
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="//body/div"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Create endnotes (`<note>`s within `<app>`). -->
    <xsl:if test="my:istrue($include-app-notes) and
                  my:istrue($app-notes-in-separate-apparatus)">
      <xsl:text>
        \clearpage
        \section*{Critical apparatus notes}
        Format: \verb+n[-nn].x[-y]+ where \verb+n+ and \verb+nn+ = pagenumbers and verb+x+ and \verb+y+ =
        linenumbers. Content of brackets is optional.

        \doendnotes{A}
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- TRANSLATION STUFF -->
  <xsl:template name="documentDiv">
    <xsl:param name="content"/>
    <xsl:param name="inParallelText"/>
    <xsl:apply-templates select="$content">
      <xsl:with-param name="inParallelText" select="$inParallelText"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:variable name="translationFile">
    <xsl:variable name="absolute-path" select="base-uri(.)"/>
    <xsl:variable name="base-filename" select="tokenize($absolute-path, '/')[last()]"/>
    <xsl:variable name="parent" select="string-join(tokenize($absolute-path,'/')[position() &lt; last()], '/')" />
    <xsl:variable name="translation-file" select="concat($parent, '/translation-', $base-filename)"/>
    <xsl:choose>
      <xsl:when test="$translation-file">
        <xsl:value-of select="$translation-file"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          The translation file $translation-file cannot be found!
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="front/div">
    <xsl:apply-templates/>
  </xsl:template>


<!--=================== begin main template ==================-->
<xsl:template match="/">
% this tex file was auto produced from TEI by lbp_print on <xsl:value-of select="current-dateTime()"/>
\documentclass[letterpaper, <xsl:value-of select="$font-size"/>pt]{book}

\usepackage{libertine}
\usepackage{csquotes}

\usepackage{geometry}
\geometry{left=4cm, right=4cm, top=3cm, bottom=3cm}

\usepackage{fancyhdr}
\pagestyle{fancy}
\setlength{\headheight}{15pt}

\usepackage{polyglossia}
\setmainlanguage{english}
\setotherlanguage{latin}

% a critical mark
\usepackage{amssymb}

% git package
\usepackage{gitinfo2}

% indices 
\usepackage{imakeidx}  % before reledmac


% reledmac settings -------------------------------------------
\usepackage[final]{reledmac}

\Xinplaceoflemmaseparator{0pt} % Don't add space after nolemma notes.
\Xlemmadisablefontselection[A] % In fontium lemmata, don't copy font formatting.
\Xarrangement{paragraph}
\linenummargin{outer}
\sidenotemargin{inner}
\lineation{page}

\Xendbeforepagenumber{}
\Xendafterpagenumber{.}
\Xendlineprefixsingle{}
\Xendlineprefixmore{}

\Xnumberonlyfirstinline[]
\Xnumberonlyfirstintwolines[]
\Xbeforenotes{\baselineskip}

% This should prevent overfull vboxes
\AtBeginDocument{\Xmaxhnotes{0.5\textheight}}
\AtBeginDocument{\maxhnotesX{0.5\textheight}}

\Xprenotes{\baselineskip}

\let\Afootnoterule=\relax
\let\Bfootnoterule=\relax
% ---------------------------------------------------------


\makeindex[name=persons, title={Index nominum}, columns=2]
\makeindex[name=works, title={Index operum}, columns=2]


% other settings
<!--\linespread{1.1}-->



% custom macros
\newcommand{\name}[1]{#1}
\newcommand{\lemmaQuote}[1]{\emph{#1}}
\newcommand{\worktitle}[1]{\textit{#1}}
\newcommand{\supplied}[1]{⟨#1⟩}
\newcommand{\suppliedInVacuo}[1]{$\ulcorner$#1$\urcorner$} <!-- Text added where witnes(es) preserve a space -->
\newcommand{\secluded}[1]{{[}#1{]}}
\newcommand{\metatext}[1]{\{#1\}}
\newcommand{\hand}[1]{\textsuperscript{#1}}
\newcommand{\del}[1]{\textlbrackdbl{}#1\textrbrackdbl{}}
\newcommand{\no}[1]{\emph{#1}\quad}
\newcommand{\added}[1]{$\backslash{}$#1$/$}
\newcommand{\corruption}[1]{\textdagger#1\textdagger}
\newcommand{\fenestra}[1]{$\ulcorner$#1$\urcorner$}
\newcommand{\lacuna}{\supplied{\textasteriskcentered\textasteriskcentered\textasteriskcentered}}
\newcommand{\missingContent}[1]{$\stackrel{\mbox{\normalfont\small\kern-2pt #1}}{\dots{}}$}


<xsl:if test="/TEI/teiHeader/revisionDesc/@status = 'draft'">
\usepackage{draftwatermark}
\SetWatermarkText{DRAFT}
\SetWatermarkFontSize{3.5cm}
\SetWatermarkColor[gray]{0.9}
</xsl:if>


% --------------------------------------------
\begin{document}


\thispagestyle{empty}

\begin{center}
\LARGE
\MakeUppercase{<xsl:value-of select="$author"/>}

\vfill

\Large
\MakeUppercase{<xsl:value-of select="$title"/>}

\bigskip

\normalsize
<xsl:value-of select="//tei:sourceDesc/tei:listWit/tei:witness"/>

\vfill

\small
\textsc{editado por}

\bigskip

\Large

\MakeUppercase{<xsl:value-of select="$editor"/>}
  
\vfill

\normalsize
<xsl:value-of select="//tei:publicationStmt/tei:authority"/> \\

<xsl:value-of select="//tei:editionStmt/tei:edition/tei:placeName"/> \\
  
<xsl:value-of select="//tei:editionStmt/tei:edition/tei:date"/> \\
 
\scriptsize

(v. <xsl:value-of select="//tei:editionStmt/tei:edition/@n"/>)
  
\end{center}


\newpage

\fancyhead{}
\fancyfoot[C]{\thepage}
\fancyhead[L]{Index generalis}  
\renewcommand*{\contentsname}{Index generalis}
\tableofcontents


\newpage

\fancyhead{}
\fancyfoot[C]{\thepage}
<xsl:text>\fancyhead[L]{</xsl:text>
<xsl:value-of select="$shortauthor"/>
<xsl:text>: </xsl:text>
<xsl:value-of select="$shorttitle"/>
<xsl:text>}</xsl:text>  


<xsl:apply-templates select="//body"/>


% Indices -------------------------------------------
\printindex[persons]
\printindex[works]
  
\end{document}
</xsl:template>
<!--=================== end main template ==================-->
  



  <xsl:template match="head">
    <xsl:choose>
      <xsl:when test="@type='caput'">
        \addcontentsline{toc}{chapter}{<xsl:value-of select="."/>}
        \pstart
        \eledchapter*{<xsl:apply-templates/>}
        \pend
      </xsl:when>
      <xsl:otherwise>
        \addcontentsline{toc}{section}{<xsl:value-of select="."/>}
        \pstart
        \eledsection*{<xsl:apply-templates/>}
        \pend
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
<!--  
    <xsl:template match="head[parent::div[type='caput']]" priority="1">
    \addcontentsline{toc}{chapter}{XXXX <xsl:value-of select="."/>}
    \pstart
    \eledchapter*{<xsl:apply-templates/>}
    \pend
  </xsl:template>

  <xsl:template match="head">
    \addcontentsline{toc}{section}{<xsl:value-of select="."/>}
    \pstart
    \eledsection*{<xsl:apply-templates/>}
    \pend
  </xsl:template>
  -->



  <xsl:template match="/TEI/teiHeader/fileDesc/titleStmt/title">
    \addcontentsline{toc}{part}{<xsl:value-of select="."/>}
    \pstart
    \eledchapter*{<xsl:apply-templates/>}
    \pend
  </xsl:template>




  <xsl:template match="body/div">
    <!--
        Handle the first div inside the body. This will wrap the whole item text
        and should thus contain the `\beginnumbering` and `\endnumbering`
        commands, and the title of the item.
    -->
    <xsl:text>&#xa;\label{</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>}</xsl:text>
    <xsl:text>&#xa;\begin{</xsl:text>
    <xsl:value-of select="$text_language"/>
    <xsl:text>}</xsl:text>

    <xsl:text>&#xa;\beginnumbering
    </xsl:text>

    <xsl:apply-templates select="/TEI/teiHeader/fileDesc/titleStmt/title" />
    <xsl:apply-templates />

    <xsl:text>&#xa;&#xa;\endnumbering</xsl:text>
    <xsl:text>&#xa;\end{</xsl:text>
    <xsl:value-of select="$text_language"/>
    <xsl:text>}</xsl:text>
  </xsl:template>





  <xsl:template name="paragraphs" match="p">
    <xsl:param name="inParallelText"/>
    <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:variable name="p_count" select="count(//body/div/descendant::p)"/>
    <xsl:variable name="position_in_div">
      <xsl:number count="p" />
    </xsl:variable>
    <xsl:variable name="parent_div_id">
      <xsl:value-of select="parent::div[1]/@xml:id"/>
    </xsl:variable>
    <xsl:variable name="p_id" select="@xml:id"/>

    <!-- Opening pstart -->
    <xsl:text>&#xa;\pstart</xsl:text>

    <!-- No indent after headings -->
    <xsl:if test="preceding-sibling::*[1][self::head] or $pn='1'">
      <xsl:text>&#xa;\noindent%</xsl:text>
    </xsl:if>

    <!-- If first p in div, create div id -->
    <xsl:if test="$position_in_div = 1 and $parent_div_id != ''">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">start</xsl:with-param>
        <xsl:with-param name="labelId" select="$parent_div_id"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Paragraph labels -->
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">start</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>

    <!-- Print folio info on first paragraph. -->
    <xsl:if test="$pn='1'">
      <xsl:call-template name="createPageColumnBreak">
        <xsl:with-param name="withIndicator" select="false()"/>
        <xsl:with-param name="context" select="$starts_on"/>
        <xsl:with-param name="inParallelText" select="$inParallelText"/>
      </xsl:call-template>
      <xsl:text>%&#xa;</xsl:text>
    </xsl:if>

    <!-- Structure numbering -->
    <xsl:if test="my:istrue($create-structure-numbers)">
      <xsl:call-template name="create_structure_number"/>
    </xsl:if>

    <!-- The content of the paragraph proper -->
    <xsl:apply-templates/>

    <!-- Closing labels -->
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">end</xsl:with-param>
    </xsl:call-template>

    <!-- If last p in div, create div id -->
    <xsl:if test="$position_in_div = count(parent::div/p) and $parent_div_id != ''">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">end</xsl:with-param>
        <xsl:with-param name="labelId" select="$parent_div_id"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Close the paragraph with \pend -->
    <xsl:text>&#xa;\pend&#xa;</xsl:text>
  </xsl:template>


  <xsl:template name="createLabelFromId">
    <xsl:param name="labelType" />
    <xsl:param name="labelId">
      <xsl:value-of select="@xml:id"/>
    </xsl:param>
    <xsl:if test="not($labelId = '')">
      <xsl:choose>
        <xsl:when test="$labelType='start'">
          <xsl:text>&#xa;</xsl:text>
          <xsl:text>\edlabelS{</xsl:text>
          <xsl:value-of select="$labelId"/>
          <xsl:text>}%</xsl:text>
        </xsl:when>
        <xsl:when test="$labelType='end'">
          <xsl:text>%&#xa;</xsl:text>
          <xsl:text>\edlabelE{</xsl:text>
          <xsl:value-of select="$labelId"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\edlabel{</xsl:text>
          <xsl:value-of select="$labelId"/>
          <xsl:text>}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>



  <xsl:template match="div[translate(@ana, '#', '') = $structure-types/* and not(@n)]">
    <xsl:if test="my:isfalse($parallel-translation)">
      <!-- The parallel typesetting does not work well with manually added space
           because of syncronization -->
      <xsl:text>&#xa;\medbreak&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>



  <xsl:param name="structure-types">
    <n>rationes-principales</n>
    <n>rationes-principales-pro</n>
    <n>rationes-principales-contra</n>
    <n>determinatio</n>
    <n>ad-rationes</n>
  </xsl:param>

  <xsl:function name="my:struct-elem">
    <xsl:param name="ana-value"/>
    <xsl:if test="translate($ana-value[last()], '#', '') = $structure-types/*">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>

  <xsl:template name="create_structure_sub">
    <xsl:param name="anchor" />
    <xsl:param name="base_number"/>

      <!-- Then insert the base level number.
        Either take it from the passed parameter (would be in non-referenced ad-rationes)
        In a way the loop is superflous, but we need it to get the proper context
        of the number when the $anchor is not just the current p. -->
      <xsl:choose>
        <xsl:when test="$base_number != ''">
          <xsl:value-of select="$base_number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$anchor/ancestor::div[my:struct-elem(@ana)]">
            <xsl:number count="div|p[not(@ana = '#structure-head') and ancestor::div[my:struct-elem(@ana)] ]"/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Now, for each div or p below the top level structure element div, print its number -->
      <xsl:for-each select="$anchor/ancestor::div[my:struct-elem(ancestor::div/@ana)]|$anchor[my:struct-elem(ancestor::div/@ana)]">
        <!-- Exclude p's marked as structure-head -->
        <xsl:if test="not(@ana = '#structure-head')">
          <!-- Honestly, this it is not clear why I need this test right now... :/ -->
          <xsl:if test="(preceding-sibling::div | following-sibling::div) or (position() = 1) or (parent::div[@type='number-all'])">
            <xsl:text>.</xsl:text>
            <xsl:number count="div|p[not(@ana = '#structure-head')]"/>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>

  </xsl:template>

  <xsl:template name="create_structure_number">
    <xsl:variable name="in_answers">
      <xsl:choose>
        <xsl:when test="ancestor::div[@ana='#ad-rationes']">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="prefix_value">
      <xsl:choose>
        <xsl:when test="$in_answers = 1">Ad </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="p_in_div"><xsl:number count="p"/></xsl:variable>

    <!--
      Create number if
       * there is an ancestor with structure element in @ana AND one of:
       * first p in div
       * the parent div is a structural div element and there are no sibling divs (singular p's)
       * there are sibling divs (branch p with subordinate divs)
       * the parent div has the type "number-all"
    -->
    <xsl:if test="
      ancestor::div[my:struct-elem(@ana)] and
      (
        $p_in_div = 1
        or (
              parent::div[my:struct-elem(@ana)]
              and not(following-sibling::div | preceding-sibling::div)
            )
        or (following-sibling::div or preceding-sibling::div)
        or parent::div[@type='number-all']
      )
      ">

      <!-- First insert the number text and possible prefix -->
      <xsl:text>\no{</xsl:text>
      <xsl:value-of select="$prefix_value"/>

      <!-- Select the numbering procedure -->
      <xsl:variable name="root" select="/"/>

      <xsl:choose>
        <xsl:when test="@corresp">
          <xsl:for-each select="tokenize(@corresp, ' ')">
            <xsl:variable name="corresp_id" select="translate(., '#', '')"/>
            <xsl:if test="position() > 1">, </xsl:if>
            <xsl:call-template name="create_structure_sub">
              <xsl:with-param name="anchor" select="$root//*[@xml:id=$corresp_id]"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="parent::div[@corresp] and position() = 1">
          <xsl:for-each select="tokenize(parent::div/@corresp, ' ')">
            <xsl:variable name="corresp_id" select="translate(., '#', '')"/>
            <xsl:if test="position() > 1">, </xsl:if>
            <xsl:call-template name="create_structure_sub">
              <xsl:with-param name="anchor" select="$root//*[@xml:id=$corresp_id]"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="create_structure_sub">
            <xsl:with-param name="anchor" select="."/>
            <xsl:with-param name="base_number">
              <xsl:if test="$in_answers = 1">1</xsl:if>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Close up -->
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- INLINE ELEMENTS -->
  <!-- Wrap supplied, secluded, notes, and unclear in appropriate tex macros -->
  <xsl:template match="supplied">
    <xsl:choose>
      <xsl:when test="@ana='#meta-text'">
        <xsl:text>\metatext{</xsl:text>
      </xsl:when>
      <xsl:when test="@ana='#in-vacuo'">
        <xsl:text>\suppliedInVacuo{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\supplied{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="surplus">\secluded{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="desc">\emph{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="abbr">\textsuperscript{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="mentioned">`<xsl:apply-templates/>'</xsl:template>
  <xsl:template match="add">\added{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="del">\del{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="rdg/add | lem/add"><xsl:apply-templates/></xsl:template>
  <xsl:template match="rdg/del | lem/del"><xsl:apply-templates/></xsl:template>
  <xsl:template match="app//subst/del | app//subst/add"><xsl:apply-templates/></xsl:template>
  <xsl:template match="rdg//unclear"><xsl:apply-templates/></xsl:template>
  <xsl:template match="lem//unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="app//note"><xsl:apply-templates/></xsl:template>


  <xsl:template match="sic[@ana='#crux']">\corruption{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="note">\footnote{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="rdg/gap">\emph{illegibilis}</xsl:template>
  <xsl:template match="c[@type='variable']">\emph{<xsl:apply-templates/>}</xsl:template>
  
  <xsl:template match="gap">
    <xsl:choose>
      <xsl:when test="@type='lacuna'">\lacuna{}</xsl:when>
      <xsl:when test="@type='fenestra'">
        <xsl:text>\fenestra{\emph{</xsl:text>
        <xsl:call-template name="getExtent" />
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="@reason='editorial'">
        <xsl:text> </xsl:text>
        <xsl:call-template name="getMissingContent" />
        <xsl:text>(ed.) </xsl:text>
      </xsl:when>
      <xsl:when test="@reason='reproduction'">
        <xsl:text> </xsl:text>
        <xsl:call-template name="getMissingContent" />
        <xsl:text>(rep.) </xsl:text>
      </xsl:when>
      <xsl:when test="@reason='damage'">
        <xsl:text> </xsl:text>
        <xsl:call-template name="getMissingContent" />
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="not(@reason) or @reason='difficult'" />
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="rdg/cb | rdg/pb">
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="pb | cb" name="createPageColumnBreak">
    <xsl:param name="context" select="."/>
    <xsl:param name="withIndicator" select="true()"/>
    <xsl:param name="inParallelText" />
    <xsl:param name="with-siglum" select="true()"/>
    <xsl:if test="not($inParallelText)">
      <xsl:for-each select="$context">
        <xsl:choose>
          <xsl:when test="self::pb">
            <xsl:if test="$withIndicator">
              <xsl:text>\textnormal{|}</xsl:text>
            </xsl:if>
            <xsl:if test="not(parent::rdg)">
              <xsl:text>\ledsidenote{</xsl:text>
            </xsl:if>
            <xsl:if test="$with-siglum">
              <xsl:value-of select="translate(./@ed, '#', '')"/>
            </xsl:if>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(./@n, '-', '')"/>
            <xsl:if test="following-sibling::*[1][self::cb]">
              <xsl:value-of select="following-sibling::cb[1]/@n"/>
            </xsl:if>
            <xsl:if test="not(parent::rdg)">
              <xsl:text>}</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(preceding-sibling::*[1][self::pb])">
              <xsl:if test="$withIndicator">
                <xsl:text>\textnormal{|}</xsl:text>
              </xsl:if>
              <xsl:if test="not(parent::rdg)">
                <xsl:text>\ledsidenote{</xsl:text>
              </xsl:if>
              <xsl:if test="$with-siglum">
                <xsl:value-of select="translate(./@ed, '#', '')"/>
              </xsl:if>
              <xsl:text> </xsl:text>
              <xsl:value-of select="translate(preceding::pb[./@ed = $context/@ed][1]/@n, '-', '')"/>
              <xsl:value-of select="./@n"/>
              <xsl:if test="not(parent::rdg)">
                <xsl:text>}</xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- THE APPARATUS HANDLING -->
  <xsl:template match="app">
    <!-- First, check if we even need an apparatus entry: If the critical
         apparatus is disabled altogether or it's a spelling or insubstantial
         entry that is disabled, just print the content of the lem -->
    <xsl:choose>
      <xsl:when test="my:isfalse($create-critical-apparatus)">
        <xsl:apply-templates select="lem"/>
      </xsl:when>
      <xsl:when test="@type='variation-spelling'">
        <xsl:if test="my:istrue($ignore-spelling-variants)">
          <xsl:apply-templates select="lem"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>


        <!-- Two initial variables -->
        <!-- Store lemma text if it exists? -->
        <xsl:variable name="lemma_text">
          <xsl:choose>
            <xsl:when test="lem = ''"/>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="lem[@n]">
                  <xsl:value-of select="my:format-lemma(lem/@n)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="my:format-lemma(lem)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Register a possible text anchor (for empty lemmas) -->
        <xsl:variable name="preceding_word" select="lem/@n"/>


        <!-- The entry proper -->
        <!-- The critical text -->
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}{</xsl:text>

        <!-- The app lemma. Given in abbreviated or full length. -->
        <xsl:choose>
          <xsl:when test="count(tokenize($lemma_text, ' ')) &gt; 4">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize($lemma_text, ' ')[1]"/>
            <xsl:text> \dots{} </xsl:text>
            <xsl:value-of select="tokenize($lemma_text, ' ')[last()]"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="$lemma_text"/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Make an applabel if the app note has an xml:id -->
        <xsl:if test="@xml:id">
          <xsl:text>\applabel{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:if>

        <!-- The critical note itself. If lemma is empty, use the [nosep] option -->
        <xsl:choose>
          <xsl:when test="lem = ''">
            <xsl:text>\Bfootnote[nosep]{</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\Bfootnote{</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <!--
            This is the trick part. If we are actually in a <lem>-element instead of
            a <rdg>-element, it entails some changes in the handling of the
            apparatus note.
            TODO: This should check that it is one of the used reading types.
            TODO: Should all reading types be possible in the lemma? Any? It is
            implied by the possibility of having @wit in lemma.
        -->
        <xsl:for-each select="lem">
          <!-- If wit contains a whitespace there is more than one witness. -->
          <xsl:if test="my:istrue($use-positive-apparatus)
                        or parent::app[@type='positive']
                        or unclear
                        or @type='conjecture-supplied'
                        or @type='conjecture-removed'
                        or @type='conjecture-corrected'">
            <xsl:call-template name="varianttype">
              <xsl:with-param name="context" select="."/>
              <xsl:with-param name="lemma_text" select="$lemma_text" />
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="rdg">
          <xsl:if test="not($lemma_text = my:format-lemma(.))
                        or my:istrue($use-positive-apparatus)
                        or parent::app[@type='positive']
                        or unclear
                        or @type='correction-addition'">
            <!-- Check for preceding siblings that we need to put separator before -->
            <xsl:call-template name="varianttype">
              <xsl:with-param name="context" select="."/>
              <xsl:with-param name="lemma_text" select="$lemma_text" />
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <!-- Handling of apparatus notes. -->
        <!-- Test: If notes as included, and there is a note in the apparatus:
             either make a separate app entry (Cfootnote), if
             $app-notes-in-separate-apparatus is true, otherwise, just include it in
             the current app (Bfootnote).
             If there is no note, or they have been excluded, just close the app.
        -->
        <xsl:choose>
          <!-- First: is there any notes, and they are not excluded -->
          <xsl:when test="./note and my:istrue($include-app-notes)">

            <xsl:choose>
              <!-- Create separate note apparatus with Cfootnote -->
              <xsl:when test="my:istrue($app-notes-in-separate-apparatus)">
                <!-- Close current entry and create new. -->
                <xsl:text>}}</xsl:text>

                <!-- The critical text, which is always empty as we have already
                     made the text entry -->
                <xsl:text>\edtext{}{</xsl:text>

                <!-- The app lemma. Given in abbreviated or full length. -->
                <xsl:choose>
                  <xsl:when test="count(tokenize($lemma_text, ' ')) &gt; 4">
                    <xsl:text>\lemma{</xsl:text>
                    <xsl:value-of select="tokenize($lemma_text, ' ')[1]"/>
                    <xsl:text> \dots{} </xsl:text>
                    <xsl:value-of select="tokenize($lemma_text, ' ')[last()]"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\lemma{</xsl:text>
                    <xsl:value-of select="$lemma_text"/>
                    <xsl:text>}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- Notes in the apparatus are put as endnotes. If lemma is
                     empty, use the [nosep] option -->
                <xsl:choose>
                  <xsl:when test="lem = ''">
                    <xsl:text>\Aendnote[nosep]{</xsl:text>
                    <xsl:text> \emph{after} </xsl:text>
                    <xsl:value-of select="lem/@n"/>
                    <xsl:text>: </xsl:text>
                    <xsl:apply-templates select="note"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\Aendnote{</xsl:text>
                    <xsl:apply-templates select="note"/>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- Close the Aendnote -->
                <xsl:text>}}</xsl:text>
              </xsl:when>

              <!-- Don't make a separate apparatus -->
              <xsl:otherwise>
                <xsl:apply-templates select="note"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <!-- There is not note, or it is excluded, so we just close the Bfootnote -->
        <xsl:text>}}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="varianttype">
    <xsl:param name="lemma_text" />
    <xsl:param name="preceding_word" />
    <xsl:param name="context"/>

    <xsl:choose>

      <!-- VARIATION READINGS -->
      <!-- variation-substance -->
      <xsl:when test="@type = 'variation-substance' or not(@type)">
        <xsl:if test="not($lemma_text = my:format-lemma($context))">
          <xsl:apply-templates select="$context"/>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-orthography -->
      <xsl:when test="@type = 'variation-orthography'">
        <xsl:if test="my:isfalse($ignore-spelling-variants)">
          <xsl:apply-templates select="$context"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- variation-inversion -->
      <xsl:when test="@type = 'variation-inversion'">
        <xsl:choose>
          <xsl:when test="$context/seg">
            <xsl:apply-templates select="$context/seg[1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:apply-templates select="$context/seg[2]"/>
            <xsl:text> \emph{scr.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\emph{inv.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-present -->
      <xsl:when test="@type = 'variation-present'">
        <xsl:choose>
          <xsl:when test="@cause = 'repetition'">
            <xsl:if test="not($lemma_text)">
              <!--
                  If there is no lemma (I think both might be intuitive to
                  different people), use the reading, which will be identical to
                  the preceding word, as it is an iteration
              -->
              <xsl:value-of select="$context"/>
            </xsl:if>
            <xsl:text> \emph{iter.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="$context"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-absent -->
      <!-- TODO: Expand further in accordance with documentation -->
      <xsl:when test="@type = 'variation-absent'">
        <xsl:text>\emph{om.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-choice -->
      <!--
          TODO: This also needs implementation of hands, location and segment
          order. I thinks it better to start with a bare bones implementation
          and go from there
      -->
      <xsl:when test="@type = 'variation-choice'">
        <xsl:variable name="seg_count" select="count(choice/seg)"/>
        <xsl:for-each select="choice/seg">
          <xsl:choose>
            <xsl:when test="position() &lt; $seg_count">
              <xsl:choose>
                <xsl:when test="position() = ($seg_count - 1)">
                  <xsl:apply-templates select="."/>
                  <xsl:text> \emph{et} </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="$context"/>
                  <xsl:text>, </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$context"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CORRECTIONS -->
      <!-- correction-addition -->
      <xsl:when test="@type = 'correction-addition'">
        <xsl:choose>
          <!-- addition made in <lem> element -->
          <xsl:when test="name($context) = lem">
            <xsl:if test="not($lemma_text = my:format-lemma($context))">
              <xsl:apply-templates select="$context"/>
            </xsl:if>
          </xsl:when>
          <!-- addition not in lemma element -->
          <xsl:otherwise>
            <xsl:choose>
              <!-- empty lemma text handling -->
              <xsl:when test="$lemma_text = ''">
                <xsl:call-template name="process_empty_lemma_reading">
                  <xsl:with-param name="reading_content" select="add"/>
                  <xsl:with-param name="preceding_word" select="$preceding_word"/>
                </xsl:call-template>
              </xsl:when>
              <!-- reading ≠ lemma -->
              <xsl:when test="not($lemma_text = my:format-lemma(add))">
                <xsl:apply-templates select="add"/>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="getLocation" />
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- manual -->
      <xsl:when test="@type = 'manual'">
        <xsl:apply-templates select="$context"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>


      <!-- correction-deletion -->
      <!-- TODO: Implement handling of del@rend attribute -->
      <xsl:when test="@type = 'correction-deletion'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-substitution -->
      <!-- TODO: Take @rend and @place into considerations -->
      <xsl:when test="@type = 'correction-substitution'">
        <xsl:choose>
          <!-- Wit is corrected to something identical to the lemma. -->
          <xsl:when test="$lemma_text = my:format-lemma(subst/add)">
            <xsl:apply-templates select="subst/del"/>
            <xsl:text> \emph{a.c.} </xsl:text>
          </xsl:when>
          <!-- Wit differs from lemma -->
          <xsl:otherwise>
            <xsl:choose>
              <!-- empty lemma text handling -->
              <xsl:when test="$lemma_text = ''">
                <xsl:call-template name="process_empty_lemma_reading">
                  <xsl:with-param name="reading_content" select="subst/add"/>
                  <xsl:with-param name="preceding_word" select="$preceding_word"/>
                </xsl:call-template>
              </xsl:when>
              <!-- lemma has content -->
              <xsl:otherwise>
                <xsl:apply-templates select="subst/add"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> \emph{corr. ex} </xsl:text>
            <xsl:apply-templates select="subst/del"/>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-transposition -->
      <xsl:when test="@type = 'correction-transposition'">
        <xsl:choose>
          <xsl:when test="subst/del/seg[@n]">
            <xsl:apply-templates select="subst/del/seg[@n = 1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:apply-templates select="subst/del/seg[@n = 2]"/>
            <xsl:text> \emph{transp.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$lemma_text = my:format-lemma(subst/add)">
                <xsl:text> \emph{inv. a.c.} </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="del/subst/add"/>
                <xsl:text> \emph{corr. ex} </xsl:text>
                <xsl:apply-templates select="del/subst/del"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-cancellation subtypes -->
      <!-- TODO: They need to handle hands too -->

      <!-- deletion-of-addition -->
      <xsl:when test="@type = 'deletion-of-addition'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del/add"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{add. et del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deleton-of-deletion -->
      <xsl:when test="@type = 'deletion-of-deletion'">
        <xsl:apply-templates select="del/del"/>
        <xsl:text> \emph{del. et scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deletion-of-substitution -->
      <xsl:when test="@type = 'deletion-of-substitution'">
        <xsl:apply-templates select="del/subst/add"/>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:apply-templates select="del/subst/del"/>
        <xsl:text> \emph{et deinde correctionem revertavit} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- substitution-of-addition -->
      <xsl:when test="@type = 'substitution-of-addition'">
        <xsl:apply-templates select="subst/del/add"/>
        <xsl:text> \emph{add. et del. et deinde} </xsl:text>
        <xsl:apply-templates select="subst/add"/>
        <xsl:text> \emph{scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CONJECTURES -->
      <!-- conjecture-supplied -->
      <xsl:when test="@type = 'conjecture-supplied'">
        <xsl:choose>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="name($context) = 'lem'"/>
          <!-- Otherwise, just print -->
          <xsl:otherwise>
            <xsl:apply-templates select="supplied/text()"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{suppl.}</xsl:text>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-removed -->
      <xsl:when test="@type = 'conjecture-removed'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="surplus/node()"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:when>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="name($context) = 'lem'"/>
          <xsl:otherwise>
            <xsl:apply-templates select="supplied"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{secl.}</xsl:text>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-corrected -->
      <xsl:when test="@type = 'conjecture-corrected'">
        <xsl:choose>
          <!-- If we come from lemma element, don't repeat the content -->
          <xsl:when test="name($context) = 'lem'"/>
          <xsl:otherwise>
            <xsl:apply-templates select="corr"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{coni.}</xsl:text>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- fallback: If no type matches, print the content and the siglum. -->
      <xsl:otherwise>
        <xsl:apply-templates select="$context"/><xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="cb|pb">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="createPageColumnBreak">
        <xsl:with-param name="withIndicator" select="false()"/>
        <xsl:with-param name="context" select="cb|pb"/>
        <xsl:with-param name="with-siglum" select="false()"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>

    <xsl:if test="note">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="note"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- READING TEMPLATES -->
  <!-- Erasures in readings -->
  <!-- <xsl:template match="rdg/space[@reason = 'erasure']"> -->
  <!--   <xsl:text>\emph{ras.</xsl:text> -->
  <!--   <xsl:if test="@extent"> -->
  <!--     <xsl:text> </xsl:text> -->
  <!--     <xsl:call-template name="getExtent"/> -->
  <!--   </xsl:if> -->
  <!--   <xsl:text>}</xsl:text> -->
  <!-- </xsl:template> -->

  <!-- APPARATUS HELPER TEMPLATES -->
  <xsl:template name="process_empty_lemma_reading">
    <xsl:param name="reading_content"/>
    <xsl:param name="preceding_word"/>
    <xsl:value-of select="$reading_content"/>
    <xsl:text> \emph{post} </xsl:text>
    <xsl:value-of select="$preceding_word"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="get_witness_siglum">
    <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <!-- First fill in witness references -->
    <xsl:variable name="witness-id" select="translate(@wit, '#', '')"/>
    <!-- Then note if the reading is uncertain -->
    <xsl:if test=".//unclear">
      <xsl:text> \emph{ut vid.} </xsl:text>
    </xsl:if>
    <!-- Does the rdg have any certainty indication? -->
    <xsl:if test="@cert">
      <xsl:choose>
        <xsl:when test="@cert = 'low'">
          <xsl:text> \emph{ut vid.} </xsl:text>
        </xsl:when>
        <xsl:when test="@cert = 'medium'">
          <xsl:text> \emph{probabiliter} </xsl:text>
        </xsl:when>
        <xsl:when test="@cert = 'high'">
          <xsl:text> \emph{certe} </xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <!-- Check for sibling witDetail elements and insert content -->
    <xsl:if test="following-sibling::witDetail[translate(@wit, '#', '')=$witness-id]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates select="following-sibling::witDetail[translate(@wit, '#', '')=$witness-id]"/>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <xsl:value-of select="translate(@wit, '#', '')"/>
    <!-- Any hand attributes? -->
    <xsl:if test=".//@hand">
      <xsl:text>\hand{</xsl:text>
      <xsl:for-each select=".//@hand">
        <xsl:value-of select="translate(., '#', '')"/>
        <xsl:if test="not(position() = last())">, </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <!-- Then fill in other sources -->
    <xsl:variable name="source-id" select="translate(@source, '#', '')"/>
    <xsl:choose>
      <xsl:when test="//tei:bibl[@xml:id=$source-id]/@rend">
        <xsl:value-of select="//tei:bibl[@xml:id=$source-id]/@rend"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source-id"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="my:istrue($apparatus-numbering)">
      <xsl:text> n</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of>
    </xsl:if>
    <xsl:if test="following-sibling::*[self::rdg] or following-sibling::*[self::note]">
      <xsl:value-of select="$app-entry-separator"/>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getExtent">
    <xsl:param name="language">la</xsl:param>
    <xsl:variable name="unit" select=".//@unit"/>
    <xsl:variable name="extent" select=".//@extent"/>
    <xsl:variable name="number">
      <xsl:choose>
        <xsl:when test="$extent &gt; 1">plural</xsl:when>
        <xsl:otherwise>singular</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$extent"/>
    <xsl:text> </xsl:text>
    <xsl:variable name="extent-localisation">
      <xsl:value-of select="$localisations//_:map[@xml:lang=$language]/_:map[@name='extents']/_:gloss[@key=$unit and @number=$number]"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not($extent-localisation = '')">
        <xsl:value-of select="$extent-localisation"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>No localisation in localisation file (<xsl:value-of select="$localisation-file"/>) for following element: <xsl:copy-of select="." /></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="getMissingContent">
    <xsl:variable name="unit" select=".//@unit"/>
    <xsl:variable name="extent" select=".//@extent"/>
    <xsl:text>\missingContent{</xsl:text>
    <xsl:choose>
      <xsl:when test="$unit = 'lines'">/</xsl:when>
      <xsl:when test="$unit = 'columns'">||</xsl:when>
    </xsl:choose>
    <xsl:value-of select="$extent"/>
    <xsl:choose>
      <xsl:when test="$unit = 'lines'">/</xsl:when>
      <xsl:when test="$unit = 'columns'">||</xsl:when>
    </xsl:choose>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="serialize" name="serialize">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="serialize" />
    <xsl:choose>
      <xsl:when test="node()">
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="serialize" />
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> /&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="locations-above">
    <n>above</n>
    <n>above-line</n>
  </xsl:variable>

  <xsl:variable name="locations-margin">
    <n>margin</n>
    <n>right-margin</n>
    <n>left-margin</n>
    <n>top-margin</n>
    <n>bottom-margin</n>
    <n>inner-margin</n>
    <n>outer-margin</n>
    <n>margin-left</n>
    <n>margin-right</n>
    <n>margin-top</n>
    <n>margin-bottom</n>
    <n>margin-inner</n>
    <n>margin-outer</n>
  </xsl:variable>

  <xsl:template name="getLocation">
    <xsl:choose>
      <xsl:when test="add/@place = $locations-above/*">
        <xsl:text> \emph{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="add/@place = $locations-margin/*">
        <xsl:text> \emph{in marg.}</xsl:text>
      </xsl:when>
      <xsl:when test="add/@place = 'in-fenestra'">
        <xsl:text> \emph{in fenestra}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- REFERENCES -->
  <xsl:template match="cit">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="ref|quote"/>
    <xsl:text>}</xsl:text>
    <xsl:text>{\lemma{</xsl:text>
    <xsl:if test="my:istrue($app-fontium-quote)">
      <xsl:choose>
        <xsl:when test="count(tokenize(normalize-space(quote), ' ')) &gt; 4">
          <xsl:value-of select="tokenize(normalize-space(quote), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(quote), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(quote)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="my:istrue($app-fontium-quote)">
        <xsl:text>\Afootnote{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\Afootnote[nosep]{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="bibl"/>
    <xsl:apply-templates select="note"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <xsl:template match="cit/bibl">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="note/bibl">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="cit/note">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="quote">
    <xsl:choose>
      <xsl:when test="seg">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@type='lemma'">
            <xsl:text>\lemmaQuote{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="@type='paraphrase'">
            <xsl:apply-templates />
          </xsl:when>
          <xsl:when test="@type='direct' or not(@type)">
            <xsl:text>\enquote{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\enquote{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="seg[@type='qs']">
    <xsl:choose>
      <xsl:when test="ancestor::quote[1][@type='lemma']">
        <xsl:text>\lemmaQuote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::quote[1][@type='paraphrase']">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="ancestor::quote[1][@type='direct'] or ancestor::quote[1][not(@type)]">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ref/name">
    <xsl:text>\name{</xsl:text>
    <xsl:call-template name="name"/>
    <xsl:text>}</xsl:text>
  </xsl:template>



  <xsl:template name="name" match="name">
    <xsl:variable name="nameid" select="substring-after(./@ref, '#')"/>
    <xsl:text>\textsc{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:text>\index[persons]{</xsl:text>
    <xsl:value-of select="document($name-list-file)//tei:person[@xml:id=$nameid]/tei:persName[@ xml:lang='lat']"/>
    <xsl:text>}</xsl:text>
  </xsl:template>



  <xsl:template match="title">
    <xsl:text>\worktitle{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="./@ref">
        <xsl:variable name="workid" select="substring-after(./@ref, '#')"/>
        <xsl:variable name="canonical-title" select="document($work-list-file)//tei:bibl[@xml:id=$workid]/tei:title[1]"/>
        <xsl:text>\index[works]{</xsl:text>
        <xsl:choose>
          <xsl:when test="$canonical-title">
            <xsl:value-of select="$canonical-title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>No work with the id <xsl:value-of select="$workid"/> in workslist file (<xsl:value-of select="$work-list-file"/>)</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">No reference given for title/<xsl:value-of select="."/>.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<xsl:template match="choice">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="orig[parent::choice]">
  <!-- do nothing! --> 
</xsl:template>

<xsl:template match="reg[parent::choice]">
  <xsl:apply-templates/>
</xsl:template>



</xsl:stylesheet>
