Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 968CF6B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 05:58:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so16003938pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 02:58:37 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0a-0016f401.pphosted.com. [67.231.148.174])
        by mx.google.com with ESMTPS id b132si41988840pfb.196.2016.08.09.02.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 02:58:36 -0700 (PDT)
Received: from pps.filterd (m0045849.ppops.net [127.0.0.1])
	by mx0a-0016f401.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u799nQ1S011289
	for <linux-mm@kvack.org>; Tue, 9 Aug 2016 02:58:36 -0700
Received: from il-exch02.marvell.com ([199.203.130.102])
	by mx0a-0016f401.pphosted.com with ESMTP id 24nd8q3q59-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Aug 2016 02:58:36 -0700
From: Yehuda Yitschak <yehuday@marvell.com>
Subject: [QUESTION] mmap of  device file with huge pages
Date: Tue, 9 Aug 2016 09:58:32 +0000
Message-ID: <85d8c7bb8bcc4a30865a4512dd174cf8@IL-EXCH02.marvell.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_85d8c7bb8bcc4a30865a4512dd174cf8ILEXCH02marvellcom_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Shadi Ammouri <shadi@marvell.com>

--_000_85d8c7bb8bcc4a30865a4512dd174cf8ILEXCH02marvellcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello everyone

I am trying mmap  kernel buffers associated with a device file (like /dev/m=
em) using huge pages.
I couldn't find any mechanism to do this.

On the kernel side I allocate a contiguous 2M buffer using alloc_pages.

A regular mmap with MAP_HUGETLB flag will only accept anonymous mappings or=
 hugetlbfs files but not device files.
So, I think I need to make sure the mapping uses huge pages in my device fi=
le's mmap hook.
Usually these kind of mmap fops use remap_pfn_range but I couldn't find a w=
ay to make remap_pfn_range use huge pages.

I also tried to make Transparent huge pages recognize the mapping done with=
 remap_pfn_range and collapse them to a huge page but that didn't work. Not=
 sure why

I would appreciate any advice on this issue

Thanks !

-------------------
Yehuda Yitschak
Marvell Semiconductor Ltd.


--_000_85d8c7bb8bcc4a30865a4512dd174cf8ILEXCH02marvellcom_
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
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";}
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
<p class=3D"MsoNormal">Hello everyone <o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I am trying mmap &nbsp;kernel buffers associated wit=
h a device file (like /dev/mem) using huge pages.<o:p></o:p></p>
<p class=3D"MsoNormal">I couldn&#8217;t find any mechanism to do this.<o:p>=
</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">On the kernel side I allocate a contiguous 2M buffer=
 using alloc_pages.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">A regular mmap with MAP_HUGETLB flag will only accep=
t anonymous mappings or hugetlbfs files but not device files.<o:p></o:p></p=
>
<p class=3D"MsoNormal">So, I think I need to make sure the mapping uses hug=
e pages in my device file&#8217;s mmap hook.<o:p></o:p></p>
<p class=3D"MsoNormal">Usually these kind of mmap fops use remap_pfn_range =
but I couldn&#8217;t find a way to make remap_pfn_range use huge pages.<o:p=
></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I also tried to make Transparent huge pages recogniz=
e the mapping done with remap_pfn_range and collapse them to a huge page bu=
t that didn&#8217;t work. Not sure why
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I would appreciate any advice on this issue <o:p></o=
:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Thanks !<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">-------------------<o:p></o:p></p>
<p class=3D"MsoNormal">Yehuda Yitschak<o:p></o:p></p>
<p class=3D"MsoNormal">Marvell Semiconductor Ltd.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_85d8c7bb8bcc4a30865a4512dd174cf8ILEXCH02marvellcom_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
