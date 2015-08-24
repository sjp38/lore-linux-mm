Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 96A7D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:12:27 -0400 (EDT)
Received: by qkfh127 with SMTP id h127so86133847qkf.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:12:27 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0090.outbound.protection.outlook.com. [157.56.111.90])
        by mx.google.com with ESMTPS id 107si29940815qgz.36.2015.08.24.13.12.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 13:12:26 -0700 (PDT)
From: James Hartshorn <jhartshorn@connexity.com>
Subject: Can we disable transparent hugepages for lack of a legitimate use
 case please?
Date: Mon, 24 Aug 2015 20:12:24 +0000
Message-ID: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_BLUPR02MB1698DD8F0D1550366489DF8CCD620BLUPR02MB1698namp_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_BLUPR02MB1698DD8F0D1550366489DF8CCD620BLUPR02MB1698namp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

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

--_000_BLUPR02MB1698DD8F0D1550366489DF8CCD620BLUPR02MB1698namp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt;color:#000000;back=
ground-color:#FFFFFF;font-family:Calibri,Arial,Helvetica,sans-serif;">
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
<p>Thoughts? &nbsp;<span style=3D"font-size: 12pt;"></span></p>
</div>
</body>
</html>

--_000_BLUPR02MB1698DD8F0D1550366489DF8CCD620BLUPR02MB1698namp_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
