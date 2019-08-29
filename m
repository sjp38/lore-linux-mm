Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	FROM_EXCESS_BASE64,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ABB5C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 04:33:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A490F22CED
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 04:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A490F22CED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tencent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E4336B0006; Thu, 29 Aug 2019 00:33:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26EDB6B000C; Thu, 29 Aug 2019 00:33:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10F056B000D; Thu, 29 Aug 2019 00:33:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id DBDE56B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 00:33:02 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7AA18180AD7C3
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 04:33:02 +0000 (UTC)
X-FDA: 75874195404.05.wool57_1a651ab75e74a
X-HE-Tag: wool57_1a651ab75e74a
X-Filterd-Recvd-Size: 11049
Received: from mail2.tencent.com (mail2.tencent.com [163.177.67.195])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 04:33:01 +0000 (UTC)
Received: from EXHUB-SZMail05.tencent.com (unknown [10.14.6.11])
	by mail2.tencent.com (Postfix) with ESMTP id 82D488EBCD;
	Thu, 29 Aug 2019 12:32:58 +0800 (CST)
Received: from EX-SZ008.tencent.com (10.28.6.32) by EXHUB-SZMail05.tencent.com
 (10.14.6.11) with Microsoft SMTP Server (TLS) id 14.3.408.0; Thu, 29 Aug 2019
 12:32:58 +0800
Received: from EX-SZ013.tencent.com (10.28.6.37) by EX-SZ008.tencent.com
 (10.28.6.32) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5; Thu, 29 Aug
 2019 12:32:57 +0800
Received: from EX-SZ013.tencent.com ([fe80::ad97:241e:365:d21a]) by
 EX-SZ013.tencent.com ([fe80::ad97:241e:365:d21a%8]) with mapi id
 15.01.1713.004; Thu, 29 Aug 2019 12:32:57 +0800
From: =?gb2312?B?dG9ubnlsdSjCvda+uNUp?= <tonnylu@tencent.com>
To: "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: =?gb2312?B?aHpob25nemhhbmco1cXqu9bQKQ==?= <hzhongzhang@tencent.com>,
	=?gb2312?B?a25pZ2h0emhhbmco1cXX2sP3KQ==?= <knightzhang@tencent.com>,
	=?gb2312?B?dG9ubnlsdSjCvda+uNUp?= <tonnylu@tencent.com>
Subject: [PATCH] mm/hugetlb: avoid looping to the same hugepage if !pages and
Thread-Topic: [PATCH] mm/hugetlb: avoid looping to the same hugepage if !pages
 and
Thread-Index: AdVeIlIp/t5ytMS8R0OfBKN8EzcwDg==
Date: Thu, 29 Aug 2019 04:32:57 +0000
Message-ID: <92ec02283213415ebde233679373b0b3@tencent.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.14.87.252]
Content-Type: multipart/alternative;
	boundary="_000_92ec02283213415ebde233679373b0b3tencentcom_"
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_92ec02283213415ebde233679373b0b3tencentcom_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

VGhpcyBjaGFuZ2UgZ3JlYXRseSBkZWNyZWFzZSB0aGUgdGltZSBvZiBtbWFwaW5nIGEgZmlsZSBp
biBodWdldGxiZnMuDQpXaXRoIE1BUF9QT1BVTEFURSBmbGFnLCBpdCB0YWtlcyBhYm91dCA1MCBt
aWxsaXNlY29uZHMgdG8gbW1hcCBhbg0KZXhpc3RpbmcgMTI4R0IgZmlsZSBpbiBodWdldGxiZnMu
IFdpdGggdGhpcyBjaGFuZ2UsIGl0IHRha2VzIGxlc3MNCnRoZW4gMSBtaWxsaXNlY29uZC4NCg0K
U2lnbmVkLW9mZi1ieTogWmhpZ2FuZyBMdSA8dG9ubnlsdUB0ZW5jZW50LmNvbT4NClJldmlld2Vk
LWJ5OiBIYW96aG9uZyBaaGFuZyA8aHpob25nemhhbmdAdGVuY2VudC5jb20+DQpSZXZpZXdlZC1i
eTogWm9uZ21pbmcgWmhhbmcgPGtuaWdodHpoYW5nQHRlbmNlbnQuY29tPg0KLS0tDQptbS9odWdl
dGxiLmMgfCAxMSArKysrKysrKysrKw0KMSBmaWxlIGNoYW5nZWQsIDExIGluc2VydGlvbnMoKykN
Cg0KZGlmZiAtLWdpdCBhL21tL2h1Z2V0bGIuYyBiL21tL2h1Z2V0bGIuYw0KaW5kZXggNmQ3Mjk2
ZC4uMmRmOTQxYSAxMDA2NDQNCi0tLSBhL21tL2h1Z2V0bGIuYw0KKysrIGIvbW0vaHVnZXRsYi5j
DQpAQCAtNDM5MSw2ICs0MzkxLDE3IEBAIGxvbmcgZm9sbG93X2h1Z2V0bGJfcGFnZShzdHJ1Y3Qg
bW1fc3RydWN0ICptbSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsDQogICAgICAgICAgICAg
ICAgICAgICAgICAgIGJyZWFrOw0KICAgICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgIH0N
CisNCisgICAgICAgICAgICBpZiAoIXBhZ2VzICYmICF2bWFzICYmICFwZm5fb2Zmc2V0ICYmDQor
ICAgICAgICAgICAgICAgICh2YWRkciArIGh1Z2VfcGFnZV9zaXplKGgpIDwgdm1hLT52bV9lbmQp
ICYmDQorICAgICAgICAgICAgICAgIChyZW1haW5kZXIgPj0gcGFnZXNfcGVyX2h1Z2VfcGFnZSho
KSkpIHsNCisgICAgICAgICAgICAgICAgICAgdmFkZHIgKz0gaHVnZV9wYWdlX3NpemUoaCk7DQor
ICAgICAgICAgICAgICAgICAgIHJlbWFpbmRlciAtPSBwYWdlc19wZXJfaHVnZV9wYWdlKGgpOw0K
KyAgICAgICAgICAgICAgICAgICBpICs9IHBhZ2VzX3Blcl9odWdlX3BhZ2UoaCk7DQorICAgICAg
ICAgICAgICAgICAgIHNwaW5fdW5sb2NrKHB0bCk7DQorICAgICAgICAgICAgICAgICAgIGNvbnRp
bnVlOw0KKyAgICAgICAgICAgIH0NCisNCnNhbWVfcGFnZToNCiAgICAgICAgICAgIGlmIChwYWdl
cykgew0KICAgICAgICAgICAgICAgICAgIHBhZ2VzW2ldID0gbWVtX21hcF9vZmZzZXQocGFnZSwg
cGZuX29mZnNldCk7DQotLQ0KMS44LjMuMQ0KDQo=

--_000_92ec02283213415ebde233679373b0b3tencentcom_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:0 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:=B5=C8=CF=DF;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"\@=B5=C8=CF=DF";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:=B5=C8=CF=DF;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:=B5=C8=CF=DF;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:=B5=C8=CF=DF;}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"ZH-CN" link=3D"#0563C1" vlink=3D"#954F72" style=3D"text-justi=
fy-trim:punctuation">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">This change greatly decrease th=
e time of mmaping a file in hugetlbfs.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">With MAP_POPULATE flag, it take=
s about 50 milliseconds to mmap an<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">existing 128GB file in hugetlbf=
s. With this change, it takes less<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">then 1 millisecond.<o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Signed-off-by: Zhigang Lu &lt;t=
onnylu@tencent.com&gt;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Reviewed-by: Haozhong Zhang &lt=
;hzhongzhang@tencent.com&gt;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Reviewed-by: Zongming Zhang &lt=
;knightzhang@tencent.com&gt;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">---<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">mm/hugetlb.c | 11 &#43;&#43;&#4=
3;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">1 file changed, 11 insertions(&=
#43;)<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">diff --git a/mm/hugetlb.c b/mm/=
hugetlb.c<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">index 6d7296d..2df941a 100644<o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">--- a/mm/hugetlb.c<o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&#43;&#43; b/mm/hugetlb.c<=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">@@ -4391,6 &#43;4391,17 @@ long=
 follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,<o:p>=
</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; break;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; }<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!pages &amp;&amp; !vmas &amp;&=
amp; !pfn_offset &amp;&amp;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; (vaddr &#43; hu=
ge_page_size(h) &lt; vma-&gt;vm_end) &amp;&amp;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; (remainder &gt;=
=3D pages_per_huge_page(h))) {<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; vaddr &#43;=3D huge_page_size(h);<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; remainder -=3D pages_per_huge_page(h);<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; i &#43;=3D pages_per_huge_page(h);<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; spin_unlock(ptl);<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; continue;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">same_page:<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (pages) {<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; pages[i] =3D mem_map_offset(page, pfn_offset);<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">-- <o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">1.8.3.1<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
</div>
</body>
</html>

--_000_92ec02283213415ebde233679373b0b3tencentcom_--

