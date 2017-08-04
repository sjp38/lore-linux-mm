Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 696E46B0717
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 03:25:51 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id g189so3506338vke.9
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 00:25:51 -0700 (PDT)
Received: from SMTP-EMEA01A.ASG.COM (smtp-emea01a.asg.com. [193.240.199.23])
        by mx.google.com with ESMTPS id i135si491990vkd.19.2017.08.04.00.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 00:25:50 -0700 (PDT)
Received: from SMTP-EMEA01A.ASG.COM (localhost.localdomain [127.0.0.1])
	by localhost (Email Security Appliance) with SMTP id 943F237812D_9842274B
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 07:29:56 +0000 (GMT)
Received: from smtp-emea01.asg.com (unknown [10.33.0.47])
	(using TLSv1.2 with cipher AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by SMTP-EMEA01A.ASG.COM (Sophos Email Appliance) with ESMTPS id 583753754A8_9842273F
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 07:29:55 +0000 (GMT)
From: Herve Kergourlay <herve.kergourlay@asg.com>
Subject: Network issue
Date: Fri, 4 Aug 2017 07:25:44 +0000
Message-ID: <3ad9dda84c2a4f859c602e437a36421f@asg.com>
Content-Language: fr-FR
Content-Type: multipart/alternative;
	boundary="_000_3ad9dda84c2a4f859c602e437a36421fasgcom_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_3ad9dda84c2a4f859c602e437a36421fasgcom_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi

We have a customer suffering from network issues on a server in a context o=
f RAC cluster / https://en.wikipedia.org/wiki/Oracle_RAC

The symptom is the following ;

A call to getaddrinfo on a server name fails after some times in production=
, with errno=3D11 "Resource temporarily unavailable"

The customer have a second cluster node in the same conditions without the =
issue.

When the issue occurs we can see in system logs the following sequence


Jan 24 14:22:06 raca-srv2 kernel: device eth0 entered promiscuous mode
Jan 24 14:22:06 raca-srv2 kernel: device eth2 entered promiscuous mode
Jan 24 14:22:06 raca-srv2 kernel: device eth9 entered promiscuous mode
Jan 24 14:22:06 raca-srv2 kernel: device eth8 entered promiscuous mode
Jan 24 14:22:06 raca-srv2 kernel: device eth1 entered promiscuous mode
Jan 24 14:22:06 raca-srv2 kernel: device eth1 left promiscuous mode
Jan 24 14:22:08 raca-srv2 kernel: device eth2 left promiscuous mode
Jan 24 14:22:29 raca-srv2 kernel: device eth8 left promiscuous mode
Jan 24 14:22:35 raca-srv2 kernel: device eth9 left promiscuous mode
Jan 24 14:22:39 raca-srv2 kernel: nr_pdflush_threads exported in /proc is s=
cheduled for removal
Jan 24 14:22:39 raca-srv2 kernel: sysctl: The scan_unevictable_pages sysctl=
/node-interface has been disabled for lack of a legitimate use case. If you=
 have one, please send an email to linux-mm@kvack.org.
Jan 24 14:22:45 raca-srv2 kernel: device eth0 left promiscuous mode
Jan 24 14:26:46 raca-srv2 kernel: bnx2x 0000:88:00.0 eth8: NIC Link is Down
Jan 24 14:26:46 raca-srv2 kernel: bonding: bond0: link status definitely do=
wn for interface eth8, disabling it
Jan 24 14:26:46 raca-srv2 kernel: bonding: bond0: making interface eth0 the=
 new active one.


As your email address is explicitly notified, I send you this email. I hope=
 you will be able to us to understand what is happening

If you have questions on the context, I will be pleased to give you any use=
full answers needed.

Regards
Herv=E9



--_000_3ad9dda84c2a4f859c602e437a36421fasgcom_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
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
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
span.itsmlabelusertext
	{mso-style-name:itsmlabelusertext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:70.85pt 70.85pt 70.85pt 70.85pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"FR" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">Hi <o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">We have a customer suffering from network issues on a server in a contex=
t of RAC cluster / https://en.wikipedia.org/wiki/Oracle_RAC<o:p></o:p></spa=
n></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">The symptom is the following ;
<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">A call to getaddrinfo on a server name fails after some times in product=
ion, with errno=3D11 &quot;Resource temporarily unavailable&quot;<o:p></o:p=
></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">The customer have a second cluster node in the same conditions without t=
he issue.<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">When the issue occurs we can see in system logs the following sequence
<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">Jan 24 14:22:06 raca-srv2 kernel: device eth0 entered promiscuous mode</=
span></span><span lang=3D"EN-US"><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:06 raca-srv2 kernel: device =
eth2 entered promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:06 raca-srv2 kernel: device =
eth9 entered promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:06 raca-srv2 kernel: device =
eth8 entered promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:06 raca-srv2 kernel: device =
eth1 entered promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:06 raca-srv2 kernel: device =
eth1 left promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:08 raca-srv2 kernel: device =
eth2 left promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:29 raca-srv2 kernel: device =
eth8 left promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:35 raca-srv2 kernel: device =
eth9 left promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:22:39 raca-srv2 kernel: nr_pdfl=
ush_threads exported in /proc is scheduled for removal</span><br>
<span class=3D"itsmlabelusertext"><b>Jan 24 14:22:39 raca-srv2 kernel: sysc=
tl: The scan_unevictable_pages sysctl/node-interface has been disabled for =
lack of a legitimate use case. If you have one, please send an email to lin=
ux-mm@kvack.org.</b></span><b><br>
</b><span class=3D"itsmlabelusertext">Jan 24 14:22:45 raca-srv2 kernel: dev=
ice eth0 left promiscuous mode</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:26:46 raca-srv2 kernel: bnx2x 0=
000:88:00.0 eth8: NIC Link is Down</span><br>
<span class=3D"itsmlabelusertext">Jan 24 14:26:46 raca-srv2 kernel: bonding=
: bond0: link status definitely down for interface eth8, disabling it</span=
><br>
<span class=3D"itsmlabelusertext">Jan 24 14:26:46 raca-srv2 kernel: bonding=
: bond0: making interface eth0 the new active one.<o:p></o:p></span></span>=
</p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">As your email address is explicitly notified, I send you this email. I h=
ope you will be able to us to understand what is happening<o:p></o:p></span=
></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">If you have questions on the context, I will be pleased to give you any =
usefull answers needed.<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">Regards<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S">Herv=E9<o:p></o:p></span></span></p>
<p class=3D"MsoNormal"><span class=3D"itsmlabelusertext"><span lang=3D"EN-U=
S"><o:p>&nbsp;</o:p></span></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
</div>
</body>
</html>

--_000_3ad9dda84c2a4f859c602e437a36421fasgcom_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
