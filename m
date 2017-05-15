Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFCBD6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 03:25:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so105797915pgc.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 00:25:34 -0700 (PDT)
Received: from tyimss.htc.com (tyimss.htc.com. [220.128.71.150])
        by mx.google.com with ESMTPS id x3si9687104pls.24.2017.05.15.00.25.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 00:25:33 -0700 (PDT)
From: <zhiyuan_zhu@htc.com>
Subject: RE: Low memory killer problem
Date: Mon, 15 May 2017 07:25:20 +0000
Message-ID: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06CNMBX03HTCCOMTW_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, gregkh@linuxfoundation.org
Cc: torvalds@linux-foundation.org

--_000_AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06CNMBX03HTCCOMTW_
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

Loop MM maintainers,

Dear All,

Who can talk about this problem? Thanks.
Maybe this is lowmemory killer=1B$B!G=1B(Bs bug ?
ION memory is complex now, we need to have a breakdown for them, I think.

Thanks a lot
Zhiyuan zhu
From: Zhiyuan Zhu(=1B$B<k;V1s=1B(B)
Sent: Friday, May 12, 2017 4:56 PM
To: vinmenon@codeaurora.org
Cc: Kyle Lin(=1B$BNS><3.=1B(B); Zhiyuan Zhu(=1B$B<k;V1s=1B(B)
Subject: Low memory killer problem

Dear Vinmenon,

I found a part of ION memory will be return to system in android platform,
But these memorys  can=1B$B!G=1B(Bt accounted in low-memory-killer strategy=
.
=1B$B!D=1B(B
And I also found ION memory comes from, kmalloc/vmalloc/alloc pages/reserve=
d memory.
What affect if account these memorys for free?
Many thanks.

=1B$B!D=1B(B
Lowmemory killer strategy
af6c02b83 (Vinayak Menon      2015-08-27 16:29:37 +0530 418)            glo=
bal_page_state(NR_FILE_PAGES) + zcache_pages())
af6c02b83 (Vinayak Menon      2015-08-27 16:29:37 +0530 419)            oth=
er_file =3D global_page_state(NR_FILE_PAGES) + zcache_pages() -
058dbde92 (Vinayak Menon      2014-02-27 00:36:22 +0530 420)               =
                             global_page_state(NR_SHMEM) -
5c4698e38 (kyle_lin           2015-04-16 16:04:22 +0800 421)               =
                             global_page_state(NR_MLOCK) -
058dbde92 (Vinayak Menon      2014-02-27 00:36:22 +0530 422)               =
                             total_swapcache_pages();



Meminfo example
$ adb shell cat /proc/meminfo
MemTotal:        3805312 kB
MemFree:         1446220 kB
MemAvailable:    2388384 kB
Buffers:           16796 kB
Cached:          1190868 kB
=1B$B!D=1B(B
IonTotal:         224252 kB
IonInUse:         199108 kB



Thanks
BR
Zhiyuan zhu

--_000_AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06CNMBX03HTCCOMTW_
Content-Type: text/html; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-2022-=
jp">
<meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
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
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:"MS PGothic";
	panose-1:2 11 6 0 7 2 5 8 2 4;}
@font-face
	{font-family:"\@MS PGothic";
	panose-1:2 11 6 0 7 2 5 8 2 4;}
@font-face
	{font-family:"\@SimSun";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Microsoft YaHei";
	panose-1:2 11 5 3 2 2 4 2 2 4;}
@font-face
	{font-family:"\@Microsoft YaHei";
	panose-1:2 11 5 3 2 2 4 2 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-fareast-language:JA;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Loop MM maintainers,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Dear All,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Who can talk about this problem? Thanks.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Maybe this is lowmemory killer=1B$B!G=1B(Bs bug ?<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">ION memory is complex now, we need to have a breakdown for them, I thi=
nk.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Thanks a lot<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN">Zhiyuan zhu<o:p></o:p></span></p>
<div>
<div style=3D"border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0pt 0in =
0in 0in">
<p class=3D"MsoNormal"><b><span style=3D"font-size:10.0pt;font-family:&quot=
;Tahoma&quot;,&quot;sans-serif&quot;">From:</span></b><span style=3D"font-s=
ize:10.0pt;font-family:&quot;Tahoma&quot;,&quot;sans-serif&quot;"> Zhiyuan =
Zhu(</span><span lang=3D"JA" style=3D"font-size:10.0pt;font-family:&quot;MS=
 PGothic&quot;,&quot;sans-serif&quot;">=1B$B<k;V1s=1B(B</span><span style=
=3D"font-size:10.0pt;font-family:&quot;Tahoma&quot;,&quot;sans-serif&quot;"=
>)
<br>
<b>Sent:</b> Friday, May 12, 2017 4:56 PM<br>
<b>To:</b> vinmenon@codeaurora.org<br>
<b>Cc:</b> Kyle Lin(</span><span lang=3D"JA" style=3D"font-size:10.0pt;font=
-family:&quot;MS PGothic&quot;,&quot;sans-serif&quot;">=1B$BNS><3.=1B(B</sp=
an><span style=3D"font-size:10.0pt;font-family:&quot;Tahoma&quot;,&quot;san=
s-serif&quot;">); Zhiyuan Zhu(</span><span lang=3D"JA" style=3D"font-size:1=
0.0pt;font-family:&quot;MS PGothic&quot;,&quot;sans-serif&quot;">=1B$B<k;V1=
s=1B(B</span><span style=3D"font-size:10.0pt;font-family:&quot;Tahoma&quot;=
,&quot;sans-serif&quot;">)<br>
<b>Subject:</b> Low memory killer problem<o:p></o:p></span></p>
</div>
</div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Dear Vinmenon,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I found a part of ION memory will be return to syste=
m in android platform,<o:p></o:p></p>
<p class=3D"MsoNormal">But these memorys &nbsp;can=1B$B!G=1B(Bt accounted i=
n low-memory-killer strategy.<o:p></o:p></p>
<p class=3D"MsoNormal">=1B$B!D=1B(B<o:p></o:p></p>
<p class=3D"MsoNormal">And I also found ION memory comes from, kmalloc/vmal=
loc/alloc pages/reserved memory.<o:p></o:p></p>
<p class=3D"MsoNormal">What affect if account these memorys for free?<o:p><=
/o:p></p>
<p class=3D"MsoNormal">Many thanks.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">=1B$B!D=1B(B<o:p></o:p></p>
<p class=3D"MsoNormal"><b>Lowmemory killer </b><b><span style=3D"font-size:=
10.0pt;font-family:&quot;Microsoft YaHei&quot;,&quot;sans-serif&quot;;color=
:black">strategy</span><o:p></o:p></b></p>
<table class=3D"MsoNormalTable" border=3D"0" cellspacing=3D"0" cellpadding=
=3D"0" style=3D"border-collapse:collapse">
<tbody>
<tr style=3D"height:77.65pt">
<td width=3D"963" valign=3D"top" style=3D"width:722.4pt;border:solid window=
text 1.0pt;padding:0in 5.4pt 0in 5.4pt;height:77.65pt">
<p class=3D"MsoNormal">af6c02b83 (Vinayak Menon&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 2015-08-27 16:29:37 &#43;0530 418)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; global_page_state(NR_FILE_PAGES) &#43; zcache_=
pages())<o:p></o:p></p>
<p class=3D"MsoNormal">af6c02b83 (Vinayak Menon&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 2015-08-27 16:29:37 &#43;0530 419)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; other_file =3D global_page_state(NR_FILE_PAGES=
) &#43; zcache_pages() -<o:p></o:p></p>
<p class=3D"MsoNormal">058dbde92 (Vinayak Menon&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 2014-02-27 00:36:22 &#43;0530 420)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; glob=
al_page_state(NR_SHMEM) -<o:p></o:p></p>
<p class=3D"MsoNormal">5c4698e38 (kyle_lin&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; 2015-04-16 16:04:22 &#43;0800 421)&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; global_page_state(NR_MLOCK) -<o:p></o:p></p>
<p class=3D"MsoNormal">058dbde92 (Vinayak Menon&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; 2014-02-27 00:36:22 &#43;0530 422)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; tota=
l_swapcache_pages();<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</td>
</tr>
</tbody>
</table>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><b>Meminfo example<o:p></o:p></b></p>
<table class=3D"MsoNormalTable" border=3D"0" cellspacing=3D"0" cellpadding=
=3D"0" style=3D"border-collapse:collapse">
<tbody>
<tr style=3D"height:129.7pt">
<td width=3D"649" valign=3D"top" style=3D"width:487.05pt;border:solid windo=
wtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;height:129.7pt">
<p class=3D"MsoNormal">$ adb shell cat /proc/meminfo<o:p></o:p></p>
<p class=3D"MsoNormal">MemTotal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
3805312 kB<o:p></o:p></p>
<p class=3D"MsoNormal">MemFree:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; 1446220 kB<o:p></o:p></p>
<p class=3D"MsoNormal">MemAvailable:&nbsp;&nbsp;&nbsp; 2388384 kB<o:p></o:p=
></p>
<p class=3D"MsoNormal">Buffers:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 16796 kB<o:p></o:p></p>
<p class=3D"MsoNormal">Cached:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 1190868 kB<o:p></o:p></p>
<p class=3D"MsoNormal">=1B$B!D=1B(B<o:p></o:p></p>
<p class=3D"MsoNormal">IonTotal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 224252 kB<o:p></o:p></p>
<p class=3D"MsoNormal">IonInUse:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 199108 kB<o:p></o:p></p>
</td>
</tr>
</tbody>
</table>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Thanks<o:p></o:p></p>
<p class=3D"MsoNormal">BR<o:p></o:p></p>
<p class=3D"MsoNormal">Zhiyuan zhu<o:p></o:p></p>
</div>
</body>
</html>

--_000_AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06CNMBX03HTCCOMTW_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
