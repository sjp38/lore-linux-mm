Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF86A6B0005
	for <linux-mm@kvack.org>; Sun, 12 Aug 2018 22:23:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so9023621pff.17
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 19:23:31 -0700 (PDT)
Received: from FZEX3.ruijie.com.cn (mxfz.ruijie.com.cn. [120.35.11.201])
        by mx.google.com with ESMTPS id y186-v6si17264726pgb.395.2018.08.12.19.23.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 12 Aug 2018 19:23:30 -0700 (PDT)
From: <yhb@ruijie.com.cn>
Subject: memblock:What is the difference between memory and physmem?
Date: Mon, 13 Aug 2018 02:23:26 +0000
Message-ID: <80B78A8B8FEE6145A87579E8435D78C3240515EF@FZEX4.ruijie.com.cn>
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_80B78A8B8FEE6145A87579E8435D78C3240515EFFZEX4ruijiecomc_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--_000_80B78A8B8FEE6145A87579E8435D78C3240515EFFZEX4ruijiecomc_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

c3RydWN0IG1lbWJsb2NrIHsNCmJvb2wgYm90dG9tX3VwOyAvKiBpcyBib3R0b20gdXAgZGlyZWN0
aW9uPyAqLw0KcGh5c19hZGRyX3QgY3VycmVudF9saW1pdDsNCnN0cnVjdCBtZW1ibG9ja190eXBl
IG1lbW9yeTsNCnN0cnVjdCBtZW1ibG9ja190eXBlIHJlc2VydmVkOw0KI2lmZGVmIENPTkZJR19I
QVZFX01FTUJMT0NLX1BIWVNfTUFQDQpzdHJ1Y3QgbWVtYmxvY2tfdHlwZSBwaHlzbWVtOw0KI2Vu
ZGlmDQp9Ow0KV2hhdCBpcyB0aGUgZGlmZmVyZW5jZSBiZXR3ZWVuIG1lbW9yeSBhbmQgcGh5c21l
bT8NCg==

--_000_80B78A8B8FEE6145A87579E8435D78C3240515EFFZEX4ruijiecomc_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:=CB=CE=CC=E5;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:=CB=CE=CC=E5;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"\@=CB=CE=CC=E5";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
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
<body lang=3D"ZH-CN" link=3D"blue" vlink=3D"purple" style=3D"text-justify-t=
rim:punctuation">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">struct memblock { <o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">bool bottom_up; /* is bottom up=
 direction? */
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">phys_addr_t current_limit; <o:p=
></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">struct memblock_type memory; <o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">struct memblock_type reserved; =
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">#ifdef CONFIG_HAVE_MEMBLOCK_PHY=
S_MAP <o:p>
</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">struct memblock_type physmem; <=
o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">#endif <o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">}; <o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">What is the difference between =
memory and physmem?<o:p></o:p></span></p>
</div>
</body>
</html>

--_000_80B78A8B8FEE6145A87579E8435D78C3240515EFFZEX4ruijiecomc_--
