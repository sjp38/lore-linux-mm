Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 828A66B295A
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:02:17 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x21-v6so5523503pln.10
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:02:17 -0800 (PST)
Received: from esa8.dell-outbound.iphmx.com (esa8.dell-outbound.iphmx.com. [68.232.149.218])
        by mx.google.com with ESMTPS id b26si19460651pgl.539.2018.11.21.20.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 20:02:16 -0800 (PST)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAM3wegK169135
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:02:15 -0500
Received: from esa4.dell-outbound2.iphmx.com (esa4.dell-outbound2.iphmx.com [68.232.154.98])
	by mx0a-00154901.pphosted.com with ESMTP id 2nw8vxuqy5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:02:14 -0500
From: "Wang, Matt" <Matt.Wang@Dell.com>
Subject: Make  __memblock_free_early a wrapper of memblock_free rather dup it
Date: Thu, 22 Nov 2018 04:01:53 +0000
Message-ID: <C8ECE1B7A767434691FEEFA3A01765D72AFB8E78@MX203CL03.corp.emc.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_004_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_004_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_
Content-Type: multipart/alternative;
	boundary="_000_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_"

--_000_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

I noticed that __memblock_free_early and memblock_free has the same code. A=
t first I think we can delete __memblock_free_early till __memblock_free_la=
te remind me __memblock_free_early is meaningful. It's a note to call this =
before struct page was initialized.

So I choose to make __memblock_free_early a wrapper of memblock_free. Here =
is the patch (see attachment file):

>From 5f21fb0409e91b42373832627e44cd0a8275c820 Mon Sep 17 00:00:00 2001
From: Wentao Wang <witallwang@gmail.com>
Date: Thu, 22 Nov 2018 11:35:59 +0800
Subject: [PATCH] Make __memblock_free_early a wrapper of memblock_free rath=
er
than dup it

Signed-off-by: Wentao Wang <witallwang@gmail.com>
---
mm/memblock.c | 7 +------
1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9a2d5ae..08bf136 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1546,12 +1546,7 @@ void * __init memblock_alloc_try_nid(
  */
void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
{
-       phys_addr_t end =3D base + size - 1;
-
-       memblock_dbg("%s: [%pa-%pa] %pF\n",
-                    __func__, &base, &end, (void *)_RET_IP_);
-       kmemleak_free_part_phys(base, size);
-       memblock_remove_range(&memblock.reserved, base, size);
+       memblock_free(base, size);
}

/**
--
1.8.3.1

Testing:
Build with memblock, system bootup normally and works well.

Regards,
Wentao


--_000_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_
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
	{font-family:"\@SimSun";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
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
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
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
<p class=3D"MsoNormal">Hi Andrew,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I noticed that __memblock_free_early and memblock_fr=
ee has the same code. At first I think we can delete __memblock_free_early =
till __memblock_free_late remind me __memblock_free_early is meaningful. It=
&#8217;s a note to call this before struct
 page was initialized.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">So I choose to make __memblock_free_early a wrapper =
of memblock_free. Here is the patch (see attachment file):<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">From 5f21fb0409e91b42373832627e44cd0a8275c820 Mon Se=
p 17 00:00:00 2001<o:p></o:p></p>
<p class=3D"MsoNormal">From: Wentao Wang &lt;witallwang@gmail.com&gt;<o:p><=
/o:p></p>
<p class=3D"MsoNormal">Date: Thu, 22 Nov 2018 11:35:59 &#43;0800<o:p></o:p>=
</p>
<p class=3D"MsoNormal">Subject: [PATCH] Make __memblock_free_early a wrappe=
r of memblock_free rather<o:p></o:p></p>
<p class=3D"MsoNormal">than dup it<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Signed-off-by: Wentao Wang &lt;witallwang@gmail.com&=
gt;<o:p></o:p></p>
<p class=3D"MsoNormal">---<o:p></o:p></p>
<p class=3D"MsoNormal">mm/memblock.c | 7 &#43;------<o:p></o:p></p>
<p class=3D"MsoNormal">1 file changed, 1 insertion(&#43;), 6 deletions(-)<o=
:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">diff --git a/mm/memblock.c b/mm/memblock.c<o:p></o:p=
></p>
<p class=3D"MsoNormal">index 9a2d5ae..08bf136 100644<o:p></o:p></p>
<p class=3D"MsoNormal">--- a/mm/memblock.c<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&#43;&#43; b/mm/memblock.c<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -1546,12 &#43;1546,7 @@ void * __init memblock_al=
loc_try_nid(<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp; */<o:p></o:p></p>
<p class=3D"MsoNormal">void __init __memblock_free_early(phys_addr_t base, =
phys_addr_t size)<o:p></o:p></p>
<p class=3D"MsoNormal">{<o:p></o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; phys_addr_t en=
d =3D base &#43; size - 1;<o:p></o:p></p>
<p class=3D"MsoNormal">-<o:p></o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memblock_dbg(&=
quot;%s: [%pa-%pa] %pF\n&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; __func__, &=
amp;base, &amp;end, (void *)_RET_IP_);<o:p></o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kmemleak_free_=
part_phys(base, size);<o:p></o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memblock_remov=
e_range(&amp;memblock.reserved, base, size);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memblock_f=
ree(base, size);<o:p></o:p></p>
<p class=3D"MsoNormal">}<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">/**<o:p></o:p></p>
<p class=3D"MsoNormal">--<o:p></o:p></p>
<p class=3D"MsoNormal">1.8.3.1<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Testing:<o:p></o:p></p>
<p class=3D"MsoNormal">Build with memblock, system bootup normally and work=
s well.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Regards,<o:p></o:p></p>
<p class=3D"MsoNormal">Wentao<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_--

--_004_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_
Content-Type: application/octet-stream;
	name="0001-Make-__memblock_free_early-a-wrapper-of-memblock_fre.patch"
Content-Description: 0001-Make-__memblock_free_early-a-wrapper-of-memblock_fre.patch
Content-Disposition: attachment;
	filename="0001-Make-__memblock_free_early-a-wrapper-of-memblock_fre.patch";
	size=900; creation-date="Thu, 22 Nov 2018 03:51:59 GMT";
	modification-date="Thu, 22 Nov 2018 03:51:59 GMT"
Content-Transfer-Encoding: base64

RnJvbSA1ZjIxZmIwNDA5ZTkxYjQyMzczODMyNjI3ZTQ0Y2QwYTgyNzVjODIwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBXZW50YW8gV2FuZyA8d2l0YWxsd2FuZ0BnbWFpbC5jb20+CkRh
dGU6IFRodSwgMjIgTm92IDIwMTggMTE6MzU6NTkgKzA4MDAKU3ViamVjdDogW1BBVENIXSBNYWtl
IF9fbWVtYmxvY2tfZnJlZV9lYXJseSBhIHdyYXBwZXIgb2YgbWVtYmxvY2tfZnJlZSByYXRoZXIK
IHRoYW4gZHVwIGl0CgpTaWduZWQtb2ZmLWJ5OiBXZW50YW8gV2FuZyA8d2l0YWxsd2FuZ0BnbWFp
bC5jb20+Ci0tLQogbW0vbWVtYmxvY2suYyB8IDcgKy0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDEg
aW5zZXJ0aW9uKCspLCA2IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL21lbWJsb2NrLmMg
Yi9tbS9tZW1ibG9jay5jCmluZGV4IDlhMmQ1YWUuLjA4YmYxMzYgMTAwNjQ0Ci0tLSBhL21tL21l
bWJsb2NrLmMKKysrIGIvbW0vbWVtYmxvY2suYwpAQCAtMTU0NiwxMiArMTU0Niw3IEBAIHZvaWQg
KiBfX2luaXQgbWVtYmxvY2tfYWxsb2NfdHJ5X25pZCgKICAqLwogdm9pZCBfX2luaXQgX19tZW1i
bG9ja19mcmVlX2Vhcmx5KHBoeXNfYWRkcl90IGJhc2UsIHBoeXNfYWRkcl90IHNpemUpCiB7Ci0J
cGh5c19hZGRyX3QgZW5kID0gYmFzZSArIHNpemUgLSAxOwotCi0JbWVtYmxvY2tfZGJnKCIlczog
WyVwYS0lcGFdICVwRlxuIiwKLQkJICAgICBfX2Z1bmNfXywgJmJhc2UsICZlbmQsICh2b2lkICop
X1JFVF9JUF8pOwotCWttZW1sZWFrX2ZyZWVfcGFydF9waHlzKGJhc2UsIHNpemUpOwotCW1lbWJs
b2NrX3JlbW92ZV9yYW5nZSgmbWVtYmxvY2sucmVzZXJ2ZWQsIGJhc2UsIHNpemUpOworCW1lbWJs
b2NrX2ZyZWUoYmFzZSwgc2l6ZSk7CiB9CiAKIC8qKgotLSAKMS44LjMuMQoK

--_004_C8ECE1B7A767434691FEEFA3A01765D72AFB8E78MX203CL03corpem_--
