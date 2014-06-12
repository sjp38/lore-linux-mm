Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 15CC96B0038
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:02 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so1387581pdb.39
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:01 -0700 (PDT)
Received: from mailuogwdur.emc.com (mailuogwdur.emc.com. [128.221.224.79])
        by mx.google.com with ESMTPS id kc2si42852596pbc.148.2014.06.12.14.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 14:48:00 -0700 (PDT)
Received: from maildlpprd55.lss.emc.com (maildlpprd55.lss.emc.com [10.106.48.159])
	by mailuogwprd54.lss.emc.com (Sentrion-MTA-4.3.0/Sentrion-MTA-4.3.0) with ESMTP id s5CLlxOa002517
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:47:59 -0400
Received: from mailusrhubprd52.lss.emc.com (mailusrhubprd52.lss.emc.com [10.106.48.25]) by maildlpprd55.lss.emc.com (RSA Interceptor) for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:47:44 -0400
Received: from mxhub40.corp.emc.com (mxhub40.corp.emc.com [128.222.70.107])
	by mailusrhubprd52.lss.emc.com (Sentrion-MTA-4.3.0/Sentrion-MTA-4.3.0) with ESMTP id s5CLlieu008788
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:47:44 -0400
From: "Alkalay, Amitai" <Amitai.Alkalay@emc.com>
Date: Thu, 12 Jun 2014 17:47:42 -0400
Subject: kernel mem_map reservation with hugepages
Message-ID: <E01DC0E960CD0F49B63BFEE7FBA569971125F1D1C0@MX16A.corp.emc.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_E01DC0E960CD0F49B63BFEE7FBA569971125F1D1C0MX16Acorpemcc_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_E01DC0E960CD0F49B63BFEE7FBA569971125F1D1C0MX16Acorpemcc_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


Hi,

According to this page<http://linux-mm.org/WhereDidMyMemoryGo> about 1.36% =
of the system memory is reserved to mem_map (I confirmed it before in the c=
ode - I saw that the kernel indeed saves a struct of 65 bytes for each page=
, meaning 63 structs per page).
I have a server (CentOS6) with 256GB of RAM,  so it means that the kernel r=
eserves about 4GB for mem_map.
Most of the pages in my server are hugepages, using the kernel command line=
 argument "hugepages=3DX".
I believe this means that the kernel can reserve a much smaller amount of m=
emory for the mappings - since there are much less pages (i.e. if all pages=
 are huges it can reserve 8MB instead of 4GB).

Am I right?
Any suggestions if and how it can be done?

Thanks,
Amitai


--_000_E01DC0E960CD0F49B63BFEE7FBA569971125F1D1C0MX16Acorpemcc_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40"><head><META HTTP-EQUIV=3D"Content-Type" CONTENT=
=3D"text/html; charset=3Dus-ascii"><meta name=3DGenerator content=3D"Micros=
oft Word 14 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
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
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue vli=
nk=3Dpurple><div class=3DWordSection1><p class=3DMsoNormal><o:p>&nbsp;</o:p=
></p><p class=3DMsoNormal>Hi,<o:p></o:p></p><p class=3DMsoNormal><o:p>&nbsp=
;</o:p></p><p class=3DMsoNormal>According to this <a href=3D"http://linux-m=
m.org/WhereDidMyMemoryGo">page</a> about 1.36% of the system memory is rese=
rved to mem_map<span style=3D'color:#1F497D'> (I confirmed it before in the=
 code &#8211; I </span>saw that the kernel indeed saves a struct of 65 byte=
s for each page, meaning 63 structs per page<span style=3D'color:#1F497D'>)=
.<o:p></o:p></span></p><p class=3DMsoNormal>I have a server (CentOS6) with =
256GB of RAM, &nbsp;so it means that the kernel reserves about 4GB for mem_=
map.<o:p></o:p></p><p class=3DMsoNormal>Most of the <span style=3D'color:#1=
F497D'>pages</span> in my server <span style=3D'color:#1F497D'>are </span>h=
ugepages, using the kernel command line argument &#8220;hugepages=3DX&#8221=
;.<o:p></o:p></p><p class=3DMsoNormal><span style=3D'color:#1F497D'>I belie=
ve t</span>his means that the kernel can reserve a much smaller amount of m=
emory for the mappings &#8211; since there are much less pages (i.e. if all=
 pages are huges it can reserve 8MB instead of 4GB).<o:p></o:p></p><p class=
=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal><span style=3D'color=
:#1F497D'>Am I right? <o:p></o:p></span></p><p class=3DMsoNormal>Any sugges=
tions if and how it can be done?<o:p></o:p></p><p class=3DMsoNormal><o:p>&n=
bsp;</o:p></p><p class=3DMsoNormal>Thanks,<o:p></o:p></p><p class=3DMsoNorm=
al>Amitai<o:p></o:p></p><p class=3DMsoNormal><o:p>&nbsp;</o:p></p></div></b=
ody></html>=

--_000_E01DC0E960CD0F49B63BFEE7FBA569971125F1D1C0MX16Acorpemcc_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
