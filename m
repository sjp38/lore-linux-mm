Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 130D46B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 08:19:22 -0400 (EDT)
Received: from mail214-tx2 (localhost [127.0.0.1])	by
 mail214-tx2-R.bigfish.com (Postfix) with ESMTP id 052A5660191	for
 <linux-mm@kvack.org>; Tue,  3 Sep 2013 12:19:21 +0000 (UTC)
Received: from TX2EHSMHS025.bigfish.com (unknown [10.9.14.239])	by
 mail214-tx2.bigfish.com (Postfix) with ESMTP id E518E9C0041	for
 <linux-mm@kvack.org>; Tue,  3 Sep 2013 12:19:17 +0000 (UTC)
From: Manomugdha Biswas <MBiswas@ixiacom.com>
Subject: /proc/pid/maps
Date: Tue, 3 Sep 2013 12:19:16 +0000
Message-ID: <8F59616961A3BD458BB4F59E7102BA0467BEE307@CH1PRD0611MB444.namprd06.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_8F59616961A3BD458BB4F59E7102BA0467BEE307CH1PRD0611MB444_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_8F59616961A3BD458BB4F59E7102BA0467BEE307CH1PRD0611MB444_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,
I am running an application and observing a memory leak. I took two snapsho=
ts of "maps". One is before starting the action which is causing memory lea=
k and another is after memory leak.

Following are the snapshots:

Before:
=3D=3D=3D=3D=3D=3D=3D
# cat /proc/481/maps
0fba9000-0fcdf000 r-xp 00000000 00:0a 371        /lib/libc-2.3.3.so
0fcdf000-0fce9000 ---p 00136000 00:0a 371        /lib/libc-2.3.3.so
0fce9000-0fcf3000 rwxp 00130000 00:0a 371        /lib/libc-2.3.3.so
0fcf3000-0fcf6000 rwxp 0fcf3000 00:00 0
0fd06000-0fd19000 r-xp 00000000 00:0a 466        /lib/libgcc_s.so.1
0fd19000-0fd26000 ---p 00013000 00:0a 466        /lib/libgcc_s.so.1
0fd26000-0fd2a000 rwxp 00010000 00:0a 466        /lib/libgcc_s.so.1
0fd3a000-0fdad000 r-xp 00000000 00:0a 455        /lib/libm-2.3.3.so
0fdad000-0fdba000 ---p 00073000 00:0a 455        /lib/libm-2.3.3.so
0fdba000-0fdc0000 rwxp 00070000 00:0a 455        /lib/libm-2.3.3.so
0fdd0000-0fec6000 r-xp 00000000 00:0a 459        /lib/libstdc++.so.6.0.9
0fec6000-0fed0000 ---p 000f6000 00:0a 459        /lib/libstdc++.so.6.0.9
0fed0000-0fedb000 rwxp 000f0000 00:0a 459        /lib/libstdc++.so.6.0.9
0fedb000-0fee2000 rwxp 0fedb000 00:00 0
0fef2000-0fefe000 r-xp 00000000 00:0a 514        /usr/lib/libixml.so
0fefe000-0ff02000 ---p 0000c000 00:0a 514        /usr/lib/libixml.so
0ff02000-0ff0e000 rwxp 00000000 00:0a 514        /usr/lib/libixml.so
0ff0e000-0ff0f000 rwxp 0ff0e000 00:00 0
0ff1f000-0ff2d000 r-xp 00000000 00:0a 361        /lib/libpthread-0.10.so
0ff2d000-0ff2f000 ---p 0000e000 00:0a 361        /lib/libpthread-0.10.so
0ff2f000-0ff3e000 rwxp 00000000 00:0a 361        /lib/libpthread-0.10.so
0ff3e000-0ff80000 rwxp 0ff3e000 00:00 0
0ff90000-0ff95000 r-xp 00000000 00:0a 368        /lib/libcrypt-2.3.3.so
0ff95000-0ffa0000 ---p 00005000 00:0a 368        /lib/libcrypt-2.3.3.so
0ffa0000-0ffa5000 rwxp 00000000 00:0a 368        /lib/libcrypt-2.3.3.so
0ffa5000-0ffcc000 rwxp 0ffa5000 00:00 0
0ffdc000-0ffe0000 r-xp 00000000 00:0a 510        /usr/lib/liberrhand.so
0ffe0000-0ffec000 ---p 00004000 00:0a 510        /usr/lib/liberrhand.so
0ffec000-0fff0000 rwxp 00000000 00:0a 510        /usr/lib/liberrhand.so
10000000-101b2000 r-xp 00000000 00:0a 1685       /opt/bgpd/bin/bgpd
101c2000-101d1000 rwxp 001b2000 00:0a 1685       /opt/bgpd/bin/bgpd
101d1000-157cc000 rwxp 101d1000 00:00 0
30000000-30016000 r-xp 00000000 00:0a 357        /lib/ld-2.3.3.so
30016000-30019000 rw-p 30016000 00:00 0
30019000-30022000 rw-s 00000000 00:06 0          /SYSV024f823f (deleted)
30022000-30023000 rw-s 00000000 00:06 163845     /SYSV0001ed23 (deleted)
30026000-30027000 rwxp 00016000 00:0a 357        /lib/ld-2.3.3.so
7feff000-80000000 rwxp 7feff000 00:00 0

After:
=3D=3D=3D=3D=3D
# cat /proc/481/maps
0fba9000-0fcdf000 r-xp 00000000 00:0a 371        /lib/libc-2.3.3.so
0fcdf000-0fce9000 ---p 00136000 00:0a 371        /lib/libc-2.3.3.so
0fce9000-0fcf3000 rwxp 00130000 00:0a 371        /lib/libc-2.3.3.so
0fcf3000-0fcf6000 rwxp 0fcf3000 00:00 0
0fd06000-0fd19000 r-xp 00000000 00:0a 466        /lib/libgcc_s.so.1
0fd19000-0fd26000 ---p 00013000 00:0a 466        /lib/libgcc_s.so.1
0fd26000-0fd2a000 rwxp 00010000 00:0a 466        /lib/libgcc_s.so.1
0fd3a000-0fdad000 r-xp 00000000 00:0a 455        /lib/libm-2.3.3.so
0fdad000-0fdba000 ---p 00073000 00:0a 455        /lib/libm-2.3.3.so
0fdba000-0fdc0000 rwxp 00070000 00:0a 455        /lib/libm-2.3.3.so
0fdd0000-0fec6000 r-xp 00000000 00:0a 459        /lib/libstdc++.so.6.0.9
0fec6000-0fed0000 ---p 000f6000 00:0a 459        /lib/libstdc++.so.6.0.9
0fed0000-0fedb000 rwxp 000f0000 00:0a 459        /lib/libstdc++.so.6.0.9
0fedb000-0fee2000 rwxp 0fedb000 00:00 0
0fef2000-0fefe000 r-xp 00000000 00:0a 514        /usr/lib/libixml.so
0fefe000-0ff02000 ---p 0000c000 00:0a 514        /usr/lib/libixml.so
0ff02000-0ff0e000 rwxp 00000000 00:0a 514        /usr/lib/libixml.so
0ff0e000-0ff0f000 rwxp 0ff0e000 00:00 0
0ff1f000-0ff2d000 r-xp 00000000 00:0a 361        /lib/libpthread-0.10.so
0ff2d000-0ff2f000 ---p 0000e000 00:0a 361        /lib/libpthread-0.10.so
0ff2f000-0ff3e000 rwxp 00000000 00:0a 361        /lib/libpthread-0.10.so
0ff3e000-0ff80000 rwxp 0ff3e000 00:00 0
0ff90000-0ff95000 r-xp 00000000 00:0a 368        /lib/libcrypt-2.3.3.so
0ff95000-0ffa0000 ---p 00005000 00:0a 368        /lib/libcrypt-2.3.3.so
0ffa0000-0ffa5000 rwxp 00000000 00:0a 368        /lib/libcrypt-2.3.3.so
0ffa5000-0ffcc000 rwxp 0ffa5000 00:00 0
0ffdc000-0ffe0000 r-xp 00000000 00:0a 510        /usr/lib/liberrhand.so
0ffe0000-0ffec000 ---p 00004000 00:0a 510        /usr/lib/liberrhand.so
0ffec000-0fff0000 rwxp 00000000 00:0a 510        /usr/lib/liberrhand.so
10000000-101b2000 r-xp 00000000 00:0a 1685       /opt/bgpd/bin/bgpd
101c2000-101d1000 rwxp 001b2000 00:0a 1685       /opt/bgpd/bin/bgpd
101d1000-17a25000 rwxp 101d1000 00:00 0
30000000-30016000 r-xp 00000000 00:0a 357        /lib/ld-2.3.3.so
30016000-30019000 rw-p 30016000 00:00 0
30019000-30022000 rw-s 00000000 00:06 0          /SYSV024f823f (deleted)
30022000-30023000 rw-s 00000000 00:06 163845     /SYSV0001ed23 (deleted)
30026000-30027000 rwxp 00016000 00:0a 357        /lib/ld-2.3.3.so
7feff000-80000000 rwxp 7feff000 00:00 0

My applications name is "/opt/bgpd/bin/bgpd".

It is seen that the red marked section is consuming the memory. Who is cons=
uming this memory?

Regards,
Mano

--_000_8F59616961A3BD458BB4F59E7102BA0467BEE307CH1PRD0611MB444_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-fareast-language:EN-US;}
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
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";
	mso-fareast-language:EN-US;}
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
<body lang=3D"EN-IN" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hi,<o:p></o:p></p>
<p class=3D"MsoNormal">I am running an application and observing a memory l=
eak. I took two snapshots of &#8220;maps&#8221;. One is before starting the=
 action which is causing memory leak and another is after memory leak.<o:p>=
</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Following are the snapshots:<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Before:<o:p></o:p></p>
<p class=3D"MsoNormal">=3D=3D=3D=3D=3D=3D=3D<o:p></o:p></p>
<p class=3D"MsoNormal"># cat /proc/481/maps<o:p></o:p></p>
<p class=3D"MsoNormal">0fba9000-0fcdf000 r-xp 00000000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fcdf000-0fce9000 ---p 00136000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fce9000-0fcf3000 rwxp 00130000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fcf3000-0fcf6000 rwxp 0fcf3000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0fd06000-0fd19000 r-xp 00000000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd19000-0fd26000 ---p 00013000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd26000-0fd2a000 rwxp 00010000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd3a000-0fdad000 r-xp 00000000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdad000-0fdba000 ---p 00073000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdba000-0fdc0000 rwxp 00070000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdd0000-0fec6000 r-xp 00000000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fec6000-0fed0000 ---p 000f6000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fed0000-0fedb000 rwxp 000f0000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fedb000-0fee2000 rwxp 0fedb000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0fef2000-0fefe000 r-xp 00000000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fefe000-0ff02000 ---p 0000c000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff02000-0ff0e000 rwxp 00000000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff0e000-0ff0f000 rwxp 0ff0e000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ff1f000-0ff2d000 r-xp 00000000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff2d000-0ff2f000 ---p 0000e000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff2f000-0ff3e000 rwxp 00000000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff3e000-0ff80000 rwxp 0ff3e000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ff90000-0ff95000 r-xp 00000000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff95000-0ffa0000 ---p 00005000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffa0000-0ffa5000 rwxp 00000000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffa5000-0ffcc000 rwxp 0ffa5000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ffdc000-0ffe0000 r-xp 00000000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffe0000-0ffec000 ---p 00004000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffec000-0fff0000 rwxp 00000000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">10000000-101b2000 r-xp 00000000 00:0a 1685&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; /opt/bgpd/bin/bgpd<o:p></o:p></p>
<p class=3D"MsoNormal">101c2000-101d1000 rwxp 001b2000 00:0a 1685&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; /opt/bgpd/bin/bgpd<o:p></o:p></p>
<p class=3D"MsoNormal">101d1000-157cc000 rwxp 101d1000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">30000000-30016000 r-xp 00000000 00:0a 357&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/ld-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">30016000-30019000 rw-p 30016000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">30019000-30022000 rw-s 00000000 00:06 0&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /SYSV024f823f (deleted)<o:p></o:p=
></p>
<p class=3D"MsoNormal">30022000-30023000 rw-s 00000000 00:06 163845&nbsp;&n=
bsp;&nbsp;&nbsp; /SYSV0001ed23 (deleted)<o:p></o:p></p>
<p class=3D"MsoNormal">30026000-30027000 rwxp 00016000 00:0a 357&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/ld-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">7feff000-80000000 rwxp 7feff000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">After:<o:p></o:p></p>
<p class=3D"MsoNormal">=3D=3D=3D=3D=3D<o:p></o:p></p>
<p class=3D"MsoNormal"># cat /proc/481/maps<o:p></o:p></p>
<p class=3D"MsoNormal">0fba9000-0fcdf000 r-xp 00000000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fcdf000-0fce9000 ---p 00136000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fce9000-0fcf3000 rwxp 00130000 00:0a 371&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libc-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fcf3000-0fcf6000 rwxp 0fcf3000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0fd06000-0fd19000 r-xp 00000000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd19000-0fd26000 ---p 00013000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd26000-0fd2a000 rwxp 00010000 00:0a 466&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libgcc_s.so.1<o:p></o:p></p>
<p class=3D"MsoNormal">0fd3a000-0fdad000 r-xp 00000000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdad000-0fdba000 ---p 00073000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdba000-0fdc0000 rwxp 00070000 00:0a 455&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libm-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fdd0000-0fec6000 r-xp 00000000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fec6000-0fed0000 ---p 000f6000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fed0000-0fedb000 rwxp 000f0000 00:0a 459&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libstdc&#43;&#43;.so.6.0.9<o:p></o:p><=
/p>
<p class=3D"MsoNormal">0fedb000-0fee2000 rwxp 0fedb000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0fef2000-0fefe000 r-xp 00000000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0fefe000-0ff02000 ---p 0000c000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff02000-0ff0e000 rwxp 00000000 00:0a 514&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/libixml.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff0e000-0ff0f000 rwxp 0ff0e000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ff1f000-0ff2d000 r-xp 00000000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff2d000-0ff2f000 ---p 0000e000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff2f000-0ff3e000 rwxp 00000000 00:0a 361&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libpthread-0.10.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff3e000-0ff80000 rwxp 0ff3e000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ff90000-0ff95000 r-xp 00000000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ff95000-0ffa0000 ---p 00005000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffa0000-0ffa5000 rwxp 00000000 00:0a 368&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/libcrypt-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffa5000-0ffcc000 rwxp 0ffa5000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">0ffdc000-0ffe0000 r-xp 00000000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffe0000-0ffec000 ---p 00004000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">0ffec000-0fff0000 rwxp 00000000 00:0a 510&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/lib/liberrhand.so<o:p></o:p></p>
<p class=3D"MsoNormal">10000000-101b2000 r-xp 00000000 00:0a 1685&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; /opt/bgpd/bin/bgpd<o:p></o:p></p>
<p class=3D"MsoNormal">101c2000-101d1000 rwxp 001b2000 00:0a 1685&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; /opt/bgpd/bin/bgpd<o:p></o:p></p>
<p class=3D"MsoNormal"><b><span style=3D"color:red">101d1000-17a25000 rwxp =
101d1000 00:00 0<o:p></o:p></span></b></p>
<p class=3D"MsoNormal">30000000-30016000 r-xp 00000000 00:0a 357&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/ld-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">30016000-30019000 rw-p 30016000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal">30019000-30022000 rw-s 00000000 00:06 0&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /SYSV024f823f (deleted)<o:p></o:p=
></p>
<p class=3D"MsoNormal">30022000-30023000 rw-s 00000000 00:06 163845&nbsp;&n=
bsp;&nbsp;&nbsp; /SYSV0001ed23 (deleted)<o:p></o:p></p>
<p class=3D"MsoNormal">30026000-30027000 rwxp 00016000 00:0a 357&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /lib/ld-2.3.3.so<o:p></o:p></p>
<p class=3D"MsoNormal">7feff000-80000000 rwxp 7feff000 00:00 0<o:p></o:p></=
p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">My applications name is &#8220;/opt/bgpd/bin/bgpd&#8=
221;. <o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">It is seen that the red marked section is consuming =
the memory. Who is consuming this memory?<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Regards,<o:p></o:p></p>
<p class=3D"MsoNormal">Mano<o:p></o:p></p>
</div>
</body>
</html>

--_000_8F59616961A3BD458BB4F59E7102BA0467BEE307CH1PRD0611MB444_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
