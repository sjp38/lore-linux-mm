Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 958436B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 20:04:09 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id jw12so961132veb.25
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 17:04:09 -0700 (PDT)
Received: from mx0a-0016f401.pphosted.com (mx0a-0016f401.pphosted.com. [67.231.148.174])
        by mx.google.com with ESMTPS id ga2si14794018vdc.81.2014.07.03.17.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 17:04:08 -0700 (PDT)
From: Yonghai Huang <huangyh@marvell.com>
Date: Thu, 3 Jul 2014 17:03:58 -0700
Subject: zsmalloc failure issue in low memory conditions
Message-ID: <77956EDC1B917843AC9B7965A3BD78B06ACB34DB39@SC-VEXCH2.marvell.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_77956EDC1B917843AC9B7965A3BD78B06ACB34DB39SCVEXCH2marve_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ngupta@vflare.org" <ngupta@vflare.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_77956EDC1B917843AC9B7965A3BD78B06ACB34DB39SCVEXCH2marve_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, nugpta and all:
Sorry to distribute you, now I met zsmalloc failure issue in very low memor=
y conditions, and i found someone already have met such issue, and have had=
 discussions, but looks like no final patch for it, i don't know whether th=
ere are patches to fix it. could you give some advice on it?
Below is discussion link for it:
http://linux-kernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-mem=
ory-conditions-td742009.html

With kind regards,
Yonghai

--_000_77956EDC1B917843AC9B7965A3BD78B06ACB34DB39SCVEXCH2marve_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40"><head><meta http-equiv=3DContent-Type content=
=3D"text/html; charset=3Dus-ascii"><meta name=3DGenerator content=3D"Micros=
oft Word 12 (filtered medium)"><style><!--
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
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
h1
	{mso-style-priority:9;
	mso-style-link:"Heading 1 Char";
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:24.0pt;
	font-family:"Times New Roman","serif";}
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
	color:#1F497D;
	font-weight:normal;
	font-style:normal;
	text-decoration:none none;}
span.Heading1Char
	{mso-style-name:"Heading 1 Char";
	mso-style-priority:9;
	mso-style-link:"Heading 1";
	font-family:"Times New Roman","serif";
	font-weight:bold;}
.MsoChpDefault
	{mso-style-type:export-only;}
.MsoPapDefault
	{mso-style-type:export-only;
	mso-margin-top-alt:auto;
	mso-margin-bottom-alt:auto;}
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
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue vli=
nk=3Dpurple><div class=3DWordSection1><p class=3DMsoNormal><span style=3D'f=
ont-size:10.5pt;font-family:"Arial","sans-serif";color:#222222;background:w=
hite'>Hi, nugpta and all:</span><o:p></o:p></p><p class=3DMsoNormal style=
=3D'text-indent:.5in;background:white'><span style=3D'font-size:10.5pt;font=
-family:"Arial","sans-serif";color:#222222'>Sorry to distribute you, now I =
met zsmalloc failure issue in very low memory conditions, and i found someo=
ne already have met such issue, and have had discussions, but looks like no=
 final patch for it, i don't know whether there are patches to fix it. coul=
d you give some advice on it?<o:p></o:p></span></p><p class=3DMsoNormal sty=
le=3D'background:white'><span style=3D'font-size:10.5pt;font-family:"Arial"=
,"sans-serif";color:#222222'>Below is discussion link for it:<o:p></o:p></s=
pan></p><h1 style=3D'mso-margin-top-alt:3.0pt;margin-right:0in;margin-botto=
m:9.6pt;margin-left:0in;background:white'><span style=3D'font-size:17.5pt;f=
ont-family:"Arial","sans-serif";color:#465FBC'><a href=3D"http://linux-kern=
el.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions-td=
742009.html" target=3D"_blank"><span style=3D'color:#1155CC'>http://linux-k=
ernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions=
-td742009.html</span></a></span><span style=3D'font-family:"Arial","sans-se=
rif";color:#222222'><o:p></o:p></span></h1><p class=3DMsoNormal style=3D'ma=
rgin:0in;margin-bottom:.0001pt'><b><i><span style=3D'font-size:10.0pt;color=
:#1F497D'><o:p>&nbsp;</o:p></span></i></b></p><p class=3DMsoNormal style=3D=
'margin:0in;margin-bottom:.0001pt'><b><i><span style=3D'font-size:10.0pt;co=
lor:#1F497D'>With kind regards,</span></i></b><span style=3D'font-size:12.0=
pt;font-family:SimSun;color:#1F497D'><o:p></o:p></span></p><p class=3DMsoNo=
rmal><b><i><span style=3D'font-size:10.0pt;color:#1F497D'>Yonghai</span></i=
></b><o:p></o:p></p></div></body></html>=

--_000_77956EDC1B917843AC9B7965A3BD78B06ACB34DB39SCVEXCH2marve_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
