Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 557676B006C
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:53:06 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so20737075pab.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:53:06 -0700 (PDT)
Received: from mx143.netapp.com (mx143.netapp.com. [216.240.21.24])
        by mx.google.com with ESMTPS id f5si38310526pat.128.2015.04.29.00.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 00:53:05 -0700 (PDT)
From: "Scheffenegger, Richard" <rs@netapp.com>
Subject: readahead for strided IO
Date: Wed, 29 Apr 2015 07:52:47 +0000
Message-ID: <31da5f365fe64fbb90d33cda2180faa3@hioexcmbx05-prd.hq.netapp.com>
Content-Language: en-US
Content-Type: multipart/related;
	boundary="_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_";
	type="multipart/alternative"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "trond@primarydata.com" <trond@primarydata.com>

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: multipart/alternative;
	boundary="_000_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_"

--_000_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

I hope that you could help me out. We are currently investigating a perform=
ance issue involving a NFSv3 server (our applicance), and a Linux applicati=
on doing IO against it.

The IO pattern are strictly sequential, but strided reads: the application =
requests 4k, skips 4k, reads 4k, skips 4k, ... in a monotonic increasing pa=
ttern, and apparently using blocking read() calls. Unfortunately, I don't k=
now exactly, if the file handle was created using O_RDONLY or O_RDWR, and O=
_DIRECT or O_SYNC were specified.

As you can imagine, the RTT overhead (10s of usec per IO) of individual 4k =
NFS reads, which are issued by the NFS client only once the application act=
ually requests them, is a severe limitation in terms of IOPS  (bandwidth is=
 around 25-30MB/s, IOPS around 7000), even though the storage system / NFS =
server is detecting the strided reads and serving them directly from it's p=
re-fetch cache (few usec latency there).

Complicating the issue is that the application behaving so inefficient is c=
losed source. The best approaches would obviously be for the application to=
 request larger blocks of data and once in application memory, discard abou=
t half of it (the strides are broken every ~20-30 IOs, and interspaced with=
 16k reads, followed by strided reads aligned to the other odd/even 4k bloc=
k offsets in the file), or to explicitly make use of the readahead() facili=
ty of linux.


The reason I write this is my curiosity, if there would be any way to confi=
gure the linux readahead facitily to be really aggressive on a particular n=
fs mount; we checked the /sys/class/bdi settings for the mount in question,=
 and increased the read_ahead_kb, but that didn't change anything; I guess =
what would be necessary was a flag to have mm/readahead kick in for every r=
ead, regardless if it's considered a sequential read or not...

Finally, are there ways to extract statistical information from mm/readahea=
d, ie. if it was actually called (not that due to some flags used by the ap=
plication, it's completely bypassed to begin with), and when/why/how it dec=
ided to do the IO (or not) it does?

Thanks a lot!



Richard Scheffenegger
Storage Infrastructure Architect

NetApp Austria GmbH
+43 676 6543146 Tel
+43 1 3676811-3100 Fax
rs@netapp.com<mailto:rs@netapp.com>
www.netapp.at<http://www.netapp.at>

[Unbound Cloud(tm)]<http://www.netapp.com/au/campaigns/unboundcloud/index.a=
spx?ref_source=3Dudf-cld--16113>
Die neue Vision des Cloud-
Datenmanagements<http://www.netapp.com/de/campaigns/unboundcloud/index.aspx=
?ref_source=3Dudf-cld--16117>

[Description: Description: Description: Description: Description: Descripti=
on: Facebook]<http://www.facebook.com/NetAppAustria>

Facebook<http://www.facebook.com/NetAppAustria>

[Description: Description: Description: Description: Description: Descripti=
on: Twitter]<http://twitter.com/NetAppAustria>

Twitter<http://twitter.com/NetAppAustria>

[Description: Description: Description: Description: Description: Descripti=
on: YouTube]<http://www.youtube.com/user/NetAppTV>

YouTube<http://www.youtube.com/user/NetAppTV>

[Description: Description: cid:image001.png@01CD2C88.A2795F10]<http://www.x=
ing.com/companies/netappaustriagmbh/about>




--_000_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
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
<!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
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
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-priority:99;
	mso-style-link:"Balloon Text Char";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-fareast-language:EN-US;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.BalloonTextChar
	{mso-style-name:"Balloon Text Char";
	mso-style-priority:99;
	mso-style-link:"Balloon Text";
	font-family:"Tahoma","sans-serif";}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";
	mso-fareast-language:EN-US;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:70.85pt 70.85pt 2.0cm 70.85pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"DE-AT" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Hi,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">I hope that you could help me o=
ut. We are currently investigating a performance issue involving a NFSv3 se=
rver (our applicance), and a Linux application doing IO against it.<o:p></o=
:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">The IO pattern are strictly seq=
uential, but strided reads: the application requests 4k, skips 4k, reads 4k=
, skips 4k, &#8230; in a monotonic increasing pattern, and apparently using=
 blocking read() calls. Unfortunately, I don&#8217;t
 know exactly, if the file handle was created using O_RDONLY or O_RDWR, and=
 O_DIRECT or O_SYNC were specified.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">As you can imagine, the RTT ove=
rhead (10s of usec per IO) of individual 4k NFS reads, which are issued by =
the NFS client only once the application actually requests them, is a sever=
e limitation in terms of IOPS &nbsp;(bandwidth
 is around 25-30MB/s, IOPS around 7000), even though the storage system / N=
FS server is detecting the strided reads and serving them directly from it&=
#8217;s pre-fetch cache (few usec latency there).<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Complicating the issue is that =
the application behaving so inefficient is closed source. The best approach=
es would obviously be for the application to request larger blocks of data =
and once in application memory, discard
 about half of it (the strides are broken every ~20-30 IOs, and interspaced=
 with 16k reads, followed by strided reads aligned to the other odd/even 4k=
 block offsets in the file), or to explicitly make use of the readahead() f=
acility of linux.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">The reason I write this is my c=
uriosity, if there would be any way to configure the linux readahead faciti=
ly to be really aggressive on a particular nfs mount; we checked the /sys/c=
lass/bdi settings for the mount in question,
 and increased the read_ahead_kb, but that didn&#8217;t change anything; I =
guess what would be necessary was a flag to have mm/readahead kick in for e=
very read, regardless if it&#8217;s considered a sequential read or not&#82=
30;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Finally, are there ways to extr=
act statistical information from mm/readahead, ie. if it was actually calle=
d (not that due to some flags used by the application, it&#8217;s completel=
y bypassed to begin with), and when/why/how
 it decided to do the IO (or not) it does?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Thanks a lot!<o:p></o:p></span>=
</p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><b><span lang=3D"EN-US" style=3D"font-size:9.0pt;fon=
t-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast=
-language:DE-AT">Richard Scheffenegger<o:p></o:p></span></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;font-f=
amily:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-la=
nguage:DE-AT">Storage Infrastructure Architect<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt;font-=
family:&quot;Times New Roman&quot;,&quot;serif&quot;;mso-fareast-language:D=
E-AT"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><b><span lang=3D"EN-US" style=3D"font-size:9.0pt;fon=
t-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast=
-language:DE-AT">NetApp Austria GmbH<o:p></o:p></span></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;font-f=
amily:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-la=
nguage:DE-AT">&#43;43 676 6543146 Tel<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;font-f=
amily:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-la=
nguage:DE-AT">&#43;43 1 3676811-3100 Fax<o:p></o:p></span></p>
<p class=3D"MsoNormal"><u><span style=3D"font-size:9.0pt;font-family:&quot;=
Arial&quot;,&quot;sans-serif&quot;;color:blue;mso-fareast-language:DE-AT"><=
a href=3D"mailto:rs@netapp.com"><span lang=3D"EN-US" style=3D"color:blue">r=
s@netapp.com</span></a></span></u><u><span lang=3D"EN-US" style=3D"font-siz=
e:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:blue;mso=
-fareast-language:DE-AT"><o:p></o:p></span></u></p>
<p class=3D"MsoNormal"><span style=3D"font-size:9.0pt;font-family:&quot;Ari=
al&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-language:DE-AT"><=
a href=3D"http://www.netapp.at"><span lang=3D"EN-US" style=3D"color:blue">w=
ww.netapp.at</span></a></span><span lang=3D"EN-US" style=3D"font-size:9.0pt=
;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-far=
east-language:DE-AT"><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;font-f=
amily:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-la=
nguage:DE-AT"><br>
</span><a href=3D"http://www.netapp.com/au/campaigns/unboundcloud/index.asp=
x?ref_source=3Dudf-cld--16113"><span style=3D"font-size:9.0pt;font-family:&=
quot;Arial&quot;,&quot;sans-serif&quot;;color:blue;mso-fareast-language:DE-=
AT;text-decoration:none"><img border=3D"0" width=3D"179" height=3D"36" id=
=3D"Picture_x0020_1" src=3D"cid:image001.jpg@01D08260.C7683130" alt=3D"Unbo=
und Cloud&#8482;"></span></a><span style=3D"font-size:9.0pt;font-family:&qu=
ot;Arial&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-language:DE=
-AT">&nbsp;</span><span style=3D"font-size:12.0pt;font-family:&quot;Times N=
ew Roman&quot;,&quot;serif&quot;;mso-fareast-language:DE-AT"><o:p></o:p></s=
pan></p>
<p class=3D"MsoNormal"><span style=3D"font-size:8.5pt;font-family:&quot;Ari=
al&quot;,&quot;sans-serif&quot;;color:#454545;mso-fareast-language:DE-AT"><=
a href=3D"http://www.netapp.com/de/campaigns/unboundcloud/index.aspx?ref_so=
urce=3Dudf-cld--16117"><span style=3D"color:blue">Die neue Vision
 des Cloud-<br>
Datenmanagements</span></a><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:DE=
-AT"><o:p>&nbsp;</o:p></span></p>
<table class=3D"MsoNormalTable" border=3D"0" cellspacing=3D"0" cellpadding=
=3D"0" width=3D"375" style=3D"width:281.35pt;margin-left:-6.0pt">
<tbody>
<tr>
<td width=3D"17" style=3D"width:13.1pt;padding:0cm 0cm 0cm 0cm">
<p class=3D"MsoNormal"><a href=3D"http://www.facebook.com/NetAppAustria"><s=
pan style=3D"font-size:9.0pt;color:blue;mso-fareast-language:DE-AT;text-dec=
oration:none"><img border=3D"0" width=3D"16" height=3D"16" id=3D"Picture_x0=
020_2" src=3D"cid:image002.png@01D08260.C7683130" alt=3D"Description: Descr=
iption: Description: Description: Description: Description: Facebook"></spa=
n></a><span style=3D"font-size:9.0pt;color:black;mso-fareast-language:DE"><=
o:p></o:p></span></p>
</td>
<td width=3D"77" style=3D"width:57.75pt;padding:0cm 11.25pt 0cm 6.0pt">
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN"><a href=3D"http://www.facebook.com/NetAppAustria"><span style=3D"font-=
size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#0070=
C0">Facebook</span></a></span><span style=3D"font-size:9.0pt;color:#0070C0;=
mso-fareast-language:DE"><o:p></o:p></span></p>
</td>
<td width=3D"18" style=3D"width:13.3pt;padding:0cm 0cm 0cm 0cm">
<p class=3D"MsoNormal"><a href=3D"http://twitter.com/NetAppAustria"><span s=
tyle=3D"font-size:9.0pt;color:blue;mso-fareast-language:DE-AT;text-decorati=
on:none"><img border=3D"0" width=3D"16" height=3D"16" id=3D"Picture_x0020_3=
" src=3D"cid:image003.png@01D08260.C7683130" alt=3D"Description: Descriptio=
n: Description: Description: Description: Description: Twitter"></span></a>=
<span style=3D"font-size:9.0pt;color:black;mso-fareast-language:DE"><o:p></=
o:p></span></p>
</td>
<td width=3D"65" style=3D"width:48.95pt;padding:0cm 11.25pt 0cm 6.0pt">
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:ZH=
-CN"><a href=3D"http://twitter.com/NetAppAustria"><span style=3D"font-size:=
9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#0070C0">T=
witter</span></a></span><span style=3D"font-size:9.0pt;color:#0070C0;mso-fa=
reast-language:DE"><o:p></o:p></span></p>
</td>
<td width=3D"17" style=3D"width:13.1pt;padding:0cm 0cm 0cm 0cm">
<p class=3D"MsoNormal"><a href=3D"http://www.youtube.com/user/NetAppTV"><sp=
an style=3D"font-size:9.0pt;color:blue;mso-fareast-language:DE-AT;text-deco=
ration:none"><img border=3D"0" width=3D"16" height=3D"16" id=3D"Picture_x00=
20_4" src=3D"cid:image004.png@01D08260.C7683130" alt=3D"Description: Descri=
ption: Description: Description: Description: Description: YouTube"></span>=
</a><span style=3D"font-size:9.0pt;color:black;mso-fareast-language:DE"><o:=
p></o:p></span></p>
</td>
<td width=3D"74" style=3D"width:55.65pt;padding:0cm 11.25pt 0cm 6.0pt">
<p class=3D"MsoNormal" style=3D"text-align:justify"><span style=3D"color:#1=
F497D;mso-fareast-language:ZH-CN"><a href=3D"http://www.youtube.com/user/Ne=
tAppTV"><span style=3D"font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;=
sans-serif&quot;;color:#0070C0">YouTube</span></a></span><span style=3D"fon=
t-size:9.0pt;color:#0070C0;mso-fareast-language:DE"><o:p></o:p></span></p>
</td>
<td width=3D"98" valign=3D"top" style=3D"width:73.5pt;padding:0cm 0cm 0cm 0=
cm">
<p class=3D"MsoNormal" align=3D"right" style=3D"text-align:right"><a href=
=3D"http://www.xing.com/companies/netappaustriagmbh/about"><b><span style=
=3D"font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;co=
lor:black;mso-fareast-language:DE-AT;text-decoration:none"><img border=3D"0=
" width=3D"87" height=3D"20" id=3D"Picture_x0020_5" src=3D"cid:image005.png=
@01D08260.C7683130" alt=3D"Description: Description: cid:image001.png@01CD2=
C88.A2795F10"></span></b></a><span style=3D"font-size:9.0pt;color:#1F497D;m=
so-fareast-language:DE"><o:p></o:p></span></p>
</td>
</tr>
</tbody>
</table>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"color:#1F497D;mso-fare=
ast-language:DE-AT"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_--

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: image/jpeg; name="image001.jpg"
Content-Description: image001.jpg
Content-Disposition: inline; filename="image001.jpg"; size=7167;
	creation-date="Wed, 29 Apr 2015 07:52:45 GMT";
	modification-date="Wed, 29 Apr 2015 07:52:45 GMT"
Content-ID: <image001.jpg@01D08260.C7683130>
Content-Transfer-Encoding: base64

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

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: image/png; name="image002.png"
Content-Description: image002.png
Content-Disposition: inline; filename="image002.png"; size=381;
	creation-date="Wed, 29 Apr 2015 07:52:45 GMT";
	modification-date="Wed, 29 Apr 2015 07:52:45 GMT"
Content-ID: <image002.png@01D08260.C7683130>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAR9JREFUeNpi/P//P0NoWvf/qzcfMJACtNUVGFbPKmVkDEnt+v/p2y8G
FRV1BiYWNqAUIwGt/xn+/v7JcPfOTQY+HnYGFpDN9vYODI9ffWf48PEdwz+gi/ABRqD5EiK8DMpA
Cw8cOMjAAhJkZmVneA/UjEuvqrwwQ3eZJ4OIIDeYbxM1k0FcWBLMZoI7DI/FyJoRToFQLMQEGLLN
6ICJgUKA1wVHlqVj5SO7BK8Bb95/RfECjE+0CwKyl6DYDONTNQyoE4hykgIM33/8IahYXVEUYivQ
WjkJfoQL/v75xSDEz8nAxEiEk4E6hAW4GX7//gFJT6DMxMDIxGCgr8PAyspJRF76D9Z84fxFcMZg
BGfndGB2vvGQxOwsD87OAAEGAEBJX61tQeB5AAAAAElFTkSuQmCC

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: image/png; name="image003.png"
Content-Description: image003.png
Content-Disposition: inline; filename="image003.png"; size=574;
	creation-date="Wed, 29 Apr 2015 07:52:45 GMT";
	modification-date="Wed, 29 Apr 2015 07:52:45 GMT"
Content-ID: <image003.png@01D08260.C7683130>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAeBJREFUeNqMU01LVUEYfmbOnLwfxw9MLrZJQ5CgFoJGLaJ/0KatW+lH
iHQR/BnSzt/QVktadUEQokV+0aJMrna/Ms989b5zjsb1GNcZhuGdeZ9nnveZGeG9x+qXC7/fBYTA
rduDKlB/OCTEm89/fCkCXtQcEuUHkngaHS2wdSxhKFB7PY/XMx6au48wWy5hOIrQsxa7vXOcGVMg
SWj/eU1hfU9AWiqhrBzaBHhULeNjy+NJA9imeS6pEKkvDCZlDGOlI0aHbKMkJVYOVDiFZ44Nrd80
uDNWOQqso0XnC1LZjlcT41exppz3rTaa2gQMYxXjLG9ScN2/hUZ/vDpt8GykinenvwLGElayfJvL
GtTqhzFGVRRyGcPYoIAHX8kgivq0RsuIkHuJUyzF5CZeb5/m/5HyfJICH1qdkGtyEyUbkSkoEnxP
+99ALDOXTI7JTAxmXF4NcJdeY9NkiS93VR/BypQjExMc/GzmHuQKbF7CcaqxOKn/68Ha0R3U4jiA
dW5kMLGnJUbpeW6etbFYGye6FBs/FE6N7CNYvn9BhwiMKYVuGoUyxNJO28ek+OmERYUKujcU43G1
Eq6r8ImMRaPzG9/OHbZPorAq+Dsv7XT8166/9VfmzJkEeDs3Iv4KMACy3jTZSx8JagAAAABJRU5E
rkJggg==

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: image/png; name="image004.png"
Content-Description: image004.png
Content-Disposition: inline; filename="image004.png"; size=413;
	creation-date="Wed, 29 Apr 2015 07:52:46 GMT";
	modification-date="Wed, 29 Apr 2015 07:52:46 GMT"
Content-ID: <image004.png@01D08260.C7683130>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAT9JREFUeNpi/P//PwMQgAkyACMTSPO19fkMDd68YBHX9LUMi489IdaA
/wz/oQDEeb8SQpMC4Kqvrc8Da1509DGYv2uSO5if1nkSbgEyjWHA12erwJI3/vz7/w3KhmkAieEy
gIlYz84tEGa4+RczrFngwcnICA2W/wyckqEMOye5g8XSOk8wqDMzMvy1j2bQYGFicElbgxoNUGeR
DVgYbt1iYPCyhJlHfJIAKdtxHOgCZaH/DHfeIiRUhJEdyMBw5w2aGCqABKKKCBbNxCVQJhSFRrYM
YNeAuCAaxGeAsqevgLBB9Nm7DAzrDqDGAmrQMqLyQS4DGVLWAUzrrlDBx3gMIOR0uFcZsRiwezcD
SqCevwDhb97MwNBVAfQ0I4R/6TIDQ5ADOB0wvJdl/A9zOa5UgZTOwJENIgQe/WcECDAAehfuqZmW
/DcAAAAASUVORK5CYII=

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_
Content-Type: image/png; name="image005.png"
Content-Description: image005.png
Content-Disposition: inline; filename="image005.png"; size=2648;
	creation-date="Wed, 29 Apr 2015 07:52:46 GMT";
	modification-date="Wed, 29 Apr 2015 07:52:46 GMT"
Content-ID: <image005.png@01D08260.C7683130>
Content-Transfer-Encoding: base64

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
J/Ekrv8CZGb34PaDrXwAAAAASUVORK5CYII=

--_008_31da5f365fe64fbb90d33cda2180faa3hioexcmbx05prdhqnetappc_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
