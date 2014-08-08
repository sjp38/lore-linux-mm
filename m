Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 60BA66B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 05:16:11 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so6780715pdj.1
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 02:16:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id az2si2024158pdb.198.2014.08.08.02.16.09
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 02:16:10 -0700 (PDT)
From: "Sha, Ruibin" <ruibin.sha@intel.com>
Subject: [PATCH]  export the function kmap_flush_unused.
Date: Fri, 8 Aug 2014 09:16:03 +0000
Message-ID: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_3C85A229999D6B4A89FA64D4680BA6142C7DFASHSMSX101ccrcorpi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "mgorman@suse.de" <mgorman@suse.de>, "mingo@redhat.com" <mingo@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "He, Bo" <bo.he@intel.com>

--_000_3C85A229999D6B4A89FA64D4680BA6142C7DFASHSMSX101ccrcorpi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

export the function kmap_flush_unused.

Scenario:  When graphic driver need high memory spece, we use alloc_pages()
         to allocate. But if the allocated page has just been
         mapped in the KMAP space(like first kmap then kunmap) and
         no flush page happened on PKMAP, the page virtual address is
         not NULL.Then when we get that page and set page attribute like
         set_memory_uc and set_memory_wc, we hit error.

fix:       For that scenario,when we get the allocated page and its virtual
           address is not NULL, we would like first flush that page.
         So need export that function kmap_flush_unused.

Signed-off-by: sha, ruibin <ruibin.sha@intel.com>

---
 mm/highmem.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/highmem.c b/mm/highmem.c
index b32b70c..511299b 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -156,6 +156,7 @@ void kmap_flush_unused(void)
      flush_all_zero_pkmaps();
      unlock_kmap();
 }
+EXPORT_SYMBOL(kmap_flush_unused);

 static inline unsigned long map_new_virtual(struct page *page)
 {
--
1.7.9.5




Best Regards
---------------------------------------------------------------
Sha, Rui bin ( Robin )
+86 13817890945
Android System Integration Shanghai


--_000_3C85A229999D6B4A89FA64D4680BA6142C7DFASHSMSX101ccrcorpi_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Consolas;
	panose-1:2 11 6 9 2 2 4 3 2 4;}
@font-face
	{font-family:"\@SimSun";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
p.MsoPlainText, li.MsoPlainText, div.MsoPlainText
	{mso-style-priority:99;
	mso-style-link:"Plain Text Char";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:10.5pt;
	font-family:Consolas;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.PlainTextChar
	{mso-style-name:"Plain Text Char";
	mso-style-priority:99;
	mso-style-link:"Plain Text";
	font-family:Consolas;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 72.0pt 72.0pt 72.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoPlainText"><span style=3D"font-family:&quot;Courier New&quot=
;">export the function kmap_flush_unused.<br>
<br>
Scenario:&nbsp; When graphic driver need high memory spece, we use alloc_pa=
ges()<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; to allocate. But if the allocat=
ed page has just been <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; mapped in the KMAP space(like f=
irst kmap then kunmap) and<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; no flush page happened on PKMAP=
, the page virtual address is <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; not NULL.Then when we get that =
page and set page attribute like<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; set_memory_uc and set_memory_wc=
, we hit error.<br>
<br>
fix:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; For that scenario,when we get the =
allocated page and its virtual<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; address is not=
 NULL, we would like first flush that page.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; So need export that function km=
ap_flush_unused.<br>
<br>
Signed-off-by: sha, ruibin &lt;ruibin.sha@intel.com&gt;<br>
<br>
---<br>
&nbsp;mm/highmem.c |&nbsp;&nbsp;&nbsp; 1 &#43;<br>
&nbsp;1 file changed, 1 insertion(&#43;)<br>
<br>
diff --git a/mm/highmem.c b/mm/highmem.c<br>
index b32b70c..511299b 100644<br>
--- a/mm/highmem.c<br>
&#43;&#43;&#43; b/mm/highmem.c<br>
@@ -156,6 &#43;156,7 @@ void kmap_flush_unused(void)<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; flush_all_zero_pkmaps();<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unlock_kmap();<br>
&nbsp;}<br>
&#43;EXPORT_SYMBOL(kmap_flush_unused);<br>
&nbsp;<br>
&nbsp;static inline unsigned long map_new_virtual(struct page *page)<br>
&nbsp;{<br>
-- <br>
1.7.9.5<br>
<br>
<o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal" style=3D"text-align:justify;text-justify:inter-ideog=
raph"><span lang=3D"EN-GB" style=3D"font-size:10.5pt;color:#1F497D;mso-fare=
ast-language:EN-GB">Best Regards<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"text-align:justify;text-justify:inter-ideog=
raph"><span lang=3D"EN-GB" style=3D"font-size:10.5pt;color:#1F497D;mso-fare=
ast-language:EN-GB">-------------------------------------------------------=
--------<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"text-align:justify;text-justify:inter-ideog=
raph"><span lang=3D"EN-GB" style=3D"font-size:10.5pt;color:#1F497D">Sha, Ru=
i bin ( Robin )<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"text-align:justify;text-justify:inter-ideog=
raph"><span lang=3D"EN-GB" style=3D"font-size:10.5pt;color:#1F497D">&#43;86=
 13817890945<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"text-align:justify;text-justify:inter-ideog=
raph"><span lang=3D"EN-GB" style=3D"font-size:10.5pt;color:#1F497D">Android=
 System Integration Shanghai<o:p></o:p></span></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_3C85A229999D6B4A89FA64D4680BA6142C7DFASHSMSX101ccrcorpi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
