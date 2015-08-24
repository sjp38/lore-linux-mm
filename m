Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF1986B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:20:08 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so1053231pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:20:08 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bbn0109.outbound.protection.outlook.com. [157.56.111.109])
        by mx.google.com with ESMTPS id gw7si29261634pac.35.2015.08.24.13.20.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 13:20:08 -0700 (PDT)
From: "Bridgman, John" <John.Bridgman@amd.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
Date: Mon, 24 Aug 2015 20:20:01 +0000
Message-ID: <20150824201952.5931089.66204.70511@amd.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
In-Reply-To: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_2015082420195259310896620470511amdcom_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartshorn <jhartshorn@connexity.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_2015082420195259310896620470511amdcom_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We find it useful for GPU compute applications (APU I suppose, with GPU acc=
ess via IOMMUv2) working on large datasets.

I wouldn't have expected THP to find much use for databases -- those seem t=
o be more like graphics stacks where you have enough hints about future usa=
ge to justify explicit management of pages. I thought of THP as "the soluti=
on for everything else".

From: James Hartshorn
Sent: Monday, August 24, 2015 3:12 PM
To: linux-mm@kvack.org
Subject: Can we disable transparent hugepages for lack of a legitimate use =
case please?



Hi,


I've been struggling with transparent hugepage performance issues, and can'=
t seem to find anyone who actually uses it intentionally.  Virtually every =
database that runs on linux however recommends disabling it or setting it t=
o madvise.  I'm referring to:


/sys/kernel/mm/transparent_hugepage/enabled


I asked on the internet http://unix.stackexchange.com/questions/201906/does=
-anyone-actually-use-and-benefit-from-transparent-huge-pages and got no res=
ponses there.



Independently I noticed


"sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled=
 for lack of a legitimate use case.  If you have one, please send an email =
to linux-mm@kvack.org."


And thought wow that's exactly what should be done to transparent hugepages=
.


Thoughts?

--_000_2015082420195259310896620470511amdcom_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"">
<!--
p
	{margin-top:0;
	margin-bottom:0}
-->
</style>
</head>
<body dir=3D"ltr">
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
We find it useful for GPU compute applications (APU I suppose, with GPU acc=
ess via IOMMUv2) working on large datasets.&nbsp;</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
<br>
</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
I wouldn't have expected THP to find much use for databases -- those seem t=
o be more like graphics stacks where you have enough hints about future usa=
ge to justify explicit management of pages. I thought of THP as &quot;the s=
olution for everything else&quot;.</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
<br>
</div>
<div style=3D"font-size:initial; font-family:Calibri,'Slate Pro',sans-serif=
,sans-serif; color:rgb(31,73,125); text-align:initial; background-color:rgb=
(255,255,255)">
</div>
<table width=3D"100%" style=3D"background-color:white; border-spacing:0px">
<tbody>
<tr>
<td colspan=3D"2" style=3D"font-size:initial; text-align:initial; backgroun=
d-color:rgb(255,255,255)">
<div style=3D"border-style:solid none none; border-top-color:rgb(181,196,22=
3); border-top-width:1pt; padding:3pt 0in 0in; font-family:Tahoma,'BB Alpha=
 Sans','Slate Pro'; font-size:10pt">
<div><b>From: </b>James Hartshorn</div>
<div><b>Sent: </b>Monday, August 24, 2015 3:12 PM</div>
<div><b>To: </b>linux-mm@kvack.org</div>
<div><b>Subject: </b>Can we disable transparent hugepages for lack of a leg=
itimate use case please?</div>
</div>
</td>
</tr>
</tbody>
</table>
<div style=3D"border-style:solid none none; border-top-color:rgb(186,188,20=
9); border-top-width:1pt; font-size:initial; text-align:initial; background=
-color:rgb(255,255,255)">
</div>
<br>
<div>
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt; color:#000000; ba=
ckground-color:#FFFFFF; font-family:Calibri,Arial,Helvetica,sans-serif">
<p>Hi,</p>
<p><br>
</p>
<p>I've been struggling with transparent hugepage performance issues, and c=
an't seem to find anyone who actually uses it intentionally. &nbsp;Virtuall=
y every database that runs on linux however recommends disabling it or sett=
ing it to madvise. &nbsp;I'm referring to:</p>
<p><br>
</p>
<p>/sys/kernel/mm/transparent_hugepage/enabled<br>
</p>
<p><br>
</p>
<p>I asked on the internet&nbsp;<a href=3D"http://unix.stackexchange.com/qu=
estions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-p=
ages" id=3D"LPlnk636904" title=3D"http://unix.stackexchange.com/questions/2=
01906/does-anyone-actually-use-and-benefit-from-transparent-huge-pages=0A=
Ctrl&#43;Click or tap to follow the link">http://unix.stackexchange.com/que=
stions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-pa=
ges</a>&nbsp;and
 got no responses there. &nbsp;</p>
<br>
<p><br>
</p>
<p>Independently I noticed&nbsp;</p>
<p><br>
</p>
<p>&quot;sysctl: The scan_unevictable_pages sysctl/node-interface has been =
disabled for lack of a legitimate use case. &nbsp;If you have one, please s=
end an email to linux-mm@kvack.org.&quot;</p>
<p><br>
</p>
<p>And thought wow that's exactly what should be done to transparent hugepa=
ges. &nbsp;</p>
<p><br>
</p>
<p>Thoughts? &nbsp;<span style=3D"font-size:12pt"></span></p>
</div>
</div>
</body>
</html>

--_000_2015082420195259310896620470511amdcom_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
