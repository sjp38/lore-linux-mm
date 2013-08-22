Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 34E086B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 23:38:45 -0400 (EDT)
From: "Leizhen (ThunderTown, Euler)" <thunder.leizhen@huawei.com>
Subject: [BUG] ARM64: Create 4K page size mmu memory map at init time will
 trigger exception.
Date: Thu, 22 Aug 2013 03:35:29 +0000
Message-ID: <BFAC7FA8F7636E45AB9ECBAC17346F3434557683@SZXEML508-MBS.china.huawei.com>
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_BFAC7FA8F7636E45AB9ECBAC17346F3434557683SZXEML508MBSchi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: Huxinwei <huxinwei@huawei.com>, "Liujiang (Gerry)" <jiang.liu@huawei.com>, Lizefan <lizefan@huawei.com>

--_000_BFAC7FA8F7636E45AB9ECBAC17346F3434557683SZXEML508MBSchi_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

VGhpcyBwcm9ibGVtIGlzIG9uIEFSTTY0LiBXaGVuIENPTkZJR19BUk02NF82NEtfUEFHRVMgaXMg
bm90IG9wZW5lZCwgdGhlIG1lbW9yeSBtYXAgc2l6ZSBjYW4gYmUgMk0oc2VjdGlvbikgYW5kIDRL
KFBBR0UpLiBGaXJzdCwgT1Mgd2lsbCBjcmVhdGUgbWFwIGZvciBwZ2QobGV2ZWwgMSB0YWJsZSkg
YW5kIGxldmVsIDIgdGFibGUgd2hpY2ggaW4gc3dhcHBlcl9wZ19kaXIuIFRoZW4sIE9TIHJlZ2lz
dGVyIG1lbSBibG9jayBpbnRvIG1lbWJsb2NrLm1lbW9yeSBhY2NvcmRpbmcgdG8gbWVtb3J5IG5v
ZGUgaW4gZmR0LCBsaWtlIG1lbW9yeUAwLCBhbmQgY3JlYXRlIG1hcCBpbiBzZXR1cF9hcmNoLS0+
cGFnaW5nX2luaXQuIElmIGFsbCBtZW0gYmxvY2sgc3RhcnQgYWRkcmVzcyBhbmQgc2l6ZSBpcyBp
bnRlZ3JhbCBtdWx0aXBsZSBvZiAyTSwgdGhlcmUgaXMgbm8gcHJvYmxlbSwgYmVjYXVzZSB3ZSB3
aWxsIGNyZWF0ZSAyTSBzZWN0aW9uIHNpemUgbWFwIHdob3NlIGVudHJpZXMgbG9jYXRlIGluIGxl
dmVsIDIgdGFibGUuIEJ1dCBpZiBpdCBpcyBub3QgaW50ZWdyYWwgbXVsdGlwbGUgb2YgMk0sIHdl
IHNob3VsZCBjcmVhdGUgbGV2ZWwgMyB0YWJsZSwgd2hpY2ggZ3JhbnVsZSBpcyA0Sy4gTm93LCBj
dXJyZW50IGltcGxlbWVudHRpb24gaXMgY2FsbCBlYXJseV9hbGxvYy0tPm1lbWJsb2NrX2FsbG9j
IHRvIGFsbG9jIG1lbW9yeSBmb3IgbGV2ZWwgMyB0YWJsZS4gVGhpcyBmdW5jdGlvbiB3aWxsIGZp
bmQgYSA0SyBmcmVlIG1lbW9yeSB3aGljaCBsb2NhdGUgaW4gbWVtYmxvY2subWVtb3J5IHRhaWwo
aGlnaCBhZGRyZXNzKSwgYnV0IHBhZ2luZ19pbml0IGlzIGNyZWF0ZSBtYXAgZnJvbSBsb3cgYWRk
cmVzcyB0byBoaWdoIGFkZHJlc3MsIHNvIG5ldyBhbGxvY2VkIG1lbW9yeSBpcyBub3QgbWFwcGVk
LCB3cml0ZSBwYWdlIHRhbGJlIGVudHJ5IHRvIGl0IHdpbGwgdHJpZ2dlciBleGNlcHRpb24uDQo=

--_000_BFAC7FA8F7636E45AB9ECBAC17346F3434557683SZXEML508MBSchi_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"Generator" content=3D"Microsoft Word 12 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:SimSun;
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
<p class=3D"MsoNormal"><span lang=3D"EN-US">This problem is on ARM64. When =
CONFIG_ARM64_64K_PAGES is not opened, the memory map size can be 2M(section=
) and 4K(PAGE). First, OS will create map for pgd(level 1 table) and level =
2 table which in swapper_pg_dir. Then,
 OS register mem block into memblock.memory according to memory node in fdt=
, like memory@0, and create map in setup_arch--&gt;paging_init. If all mem =
block start address and size is integral multiple of 2M, there is no proble=
m, because we will create 2M section
 size map whose entries locate in level 2 table. But if it is not integral =
multiple of 2M, we should create level 3 table, which granule is 4K. Now, c=
urrent implementtion is call early_alloc--&gt;memblock_alloc to alloc memor=
y for level 3 table. This function
 will find a 4K free memory which locate in memblock.memory tail(high addre=
ss), but paging_init is create map from low address to high address, so new=
 alloced memory is not mapped, write page talbe entry to it will trigger ex=
ception.<o:p></o:p></span></p>
</div>
</body>
</html>

--_000_BFAC7FA8F7636E45AB9ECBAC17346F3434557683SZXEML508MBSchi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
