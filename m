Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 12D0A6B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 05:56:00 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so6749858pac.38
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 02:55:59 -0700 (PDT)
From: "xiaowen.liu@freescale.com" <xiaowen.liu@freescale.com>
Subject: rss MM_FILEPAGES statistics value issue in kernel memory
 remap_pfn_range function.
Date: Wed, 24 Sep 2014 09:55:56 +0000
Message-ID: <e71eda4ca6734380876f0ddbb4e4f258@DM2PR03MB432.namprd03.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_e71eda4ca6734380876f0ddbb4e4f258DM2PR03MB432namprd03pro_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "majordomo@kvack.org" <majordomo@kvack.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_e71eda4ca6734380876f0ddbb4e4f258DM2PR03MB432namprd03pro_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi majordomo,

Sorry to bother you.

I noticed that there are two functions provided to map memory to user space=
 from kernel: remap_pfn_range and vm_insert_page.
There is one difference that vm_insert_page increase task rss MM_FILEPAGES =
value. But remap_pfn_range doesn't.
The issue is the munmap function will call zap_pte_range to decrease task r=
ss MM_FILEPAGES value.
So, the task rss MM_FILEPAGES value increase and decrease doesn't match.

And there are many places in kernel driver call remap_pfn_range to map memo=
ry to user space.

I think remap_pfn_range should also increase task rss MM_FILEPAGES value.

If there is any misunderstanding, please correct me.
Thanks.


BestRegards,
Ivan.liu









--_000_e71eda4ca6734380876f0ddbb4e4f258DM2PR03MB432namprd03pro_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
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
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
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
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
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
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">Hi majordomo,<o:p><=
/o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">Sorry to bother you=
.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">I noticed that ther=
e are two functions provided to map memory to user space from kernel: remap=
_pfn_range and vm_insert_page.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">There is one differ=
ence that vm_insert_page increase task rss MM_FILEPAGES value. But remap_pf=
n_range doesn&#8217;t.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">The issue is the mu=
nmap function will call zap_pte_range to decrease task rss MM_FILEPAGES val=
ue.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">So, the task rss MM=
_FILEPAGES value increase and decrease doesn&#8217;t match.<o:p></o:p></spa=
n></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">And there are many =
places in kernel driver call remap_pfn_range to map memory to user space.<o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">I think remap_pfn_r=
ange should also increase task rss MM_FILEPAGES value.<o:p></o:p></span></p=
>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">If there is any mis=
understanding, please correct me.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">Thanks. <o:p></o:p>=
</span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">BestRegards,<o:p></=
o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:14.0pt">Ivan.liu<o:p></o:p>=
</span></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_e71eda4ca6734380876f0ddbb4e4f258DM2PR03MB432namprd03pro_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
