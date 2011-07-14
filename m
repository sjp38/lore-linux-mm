Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DFCAE90011A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 02:45:49 -0400 (EDT)
Message-ID: <1310625925.65469.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Date: Wed, 13 Jul 2011 23:45:25 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Memory allocation from ZONE_HIGHMEM ???
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="0-235916557-1310625925=:65469"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--0-235916557-1310625925=:65469
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,=0A=A0=0AI have a question regarding kernel memory allocation(using kmal=
loc)=A0from ZONE_HIGHMEM zone.=0A=A0=0AI have a custom linux kernel2.6.36 r=
unning on linux mobile (arm cortexA9)=0AI have two zones on my system as sh=
own by buddyinfo.=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A/opt/home/root # cat /proc/buddyinfo=0ANod=
e 0, zone=A0=A0 Normal=A0=A0=A0=A0=A0 2=A0=A0=A0=A0 32=A0=A0=A0=A0 22=A0=A0=
=A0=A0 14=A0=A0=A0=A0 12=A0=A0=A0=A0=A0 4=A0=A0=A0=A0 12=A0=A0=A0=A0=A0 3=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0 23=0ANode 0, zone=A0 HighMem=
=A0=A0=A0 529=A0=A0=A0 243=A0=A0=A0 114=A0=A0=A0=A0 43=A0=A0=A0=A0 25=A0=A0=
=A0=A0 23=A0=A0=A0=A0 19=A0=A0=A0=A0 19=A0=A0=A0=A0 16=A0=A0=A0=A0 14=A0=A0=
=A0=A0 27=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=0A=A0=0AWhen I do memory allocation using kmalloc, th=
e pages are allocated from Normal zone.=0AMy=A0allocation size=A0is for=A0o=
rder-10 pages =3D=A023 * 1024 * PAGE_SIZE =3D 80MB=0AIf I use more than tha=
t my allocation will fail which is obvious.=0A=A0=0ABut I want to specifica=
lly allocate=A0pages from ZONE_HIGHMEM instead of Normal zone.=0AHow to exp=
licitly do that in kernel?=0A=A0=0AIf somebody have tried this please let m=
e know.=0A=A0=0A=A0=0A=A0=0AThanks, Regards,=0APintu
--0-235916557-1310625925=:65469
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:Co=
urier New, courier, monaco, monospace, sans-serif;font-size:12pt"><div styl=
e=3D"RIGHT: auto">Hi,</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">I have a question regarding kernel memory alloca=
tion(using kmalloc)&nbsp;from ZONE_HIGHMEM zone.</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">I have a custom linux kernel2.6.36 running on li=
nux mobile (arm cortexA9)</div>
<div style=3D"RIGHT: auto">I have two zones on my system as shown by buddyi=
nfo.</div>
<div style=3D"RIGHT: auto">=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>
<div style=3D"RIGHT: auto">/opt/home/root # cat /proc/buddyinfo<BR>Node 0, =
zone&nbsp;&nbsp; Normal&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&n=
bsp; 32&nbsp;&nbsp;&nbsp;&nbsp; 22&nbsp;&nbsp;&nbsp;&nbsp; 14&nbsp;&nbsp;&n=
bsp;&nbsp; 12&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp; 12&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp; 23<BR>Node 0, zone&nbsp; HighMem=
&nbsp;&nbsp;&nbsp; 529&nbsp;&nbsp;&nbsp; 243&nbsp;&nbsp;&nbsp; 114&nbsp;&nb=
sp;&nbsp;&nbsp; 43&nbsp;&nbsp;&nbsp;&nbsp; 25&nbsp;&nbsp;&nbsp;&nbsp; 23&nb=
sp;&nbsp;&nbsp;&nbsp; 19&nbsp;&nbsp;&nbsp;&nbsp; 19&nbsp;&nbsp;&nbsp;&nbsp;=
 16&nbsp;&nbsp;&nbsp;&nbsp; 14&nbsp;&nbsp;&nbsp;&nbsp; 27</div>
<div style=3D"RIGHT: auto">=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">When I do memory allocation using kmalloc, the p=
ages are allocated from Normal zone.</div>
<div style=3D"RIGHT: auto">My&nbsp;allocation size&nbsp;is for&nbsp;order-1=
0 pages =3D&nbsp;23 * 1024 * PAGE_SIZE =3D 80MB</div>
<div style=3D"RIGHT: auto">If I use more than that my allocation will fail =
which is obvious.</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">But I want to specifically allocate&nbsp;pages f=
rom ZONE_HIGHMEM instead of Normal zone.</div>
<div style=3D"RIGHT: auto">How to explicitly do that in kernel?</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">If somebody have tried this please let me know.<=
/div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">Thanks, Regards,</div>
<div style=3D"RIGHT: auto">Pintu</div>
<div style=3D"RIGHT: auto"><VAR id=3Dyui-ie-cursor></VAR>&nbsp;</div>
<div style=3D"RIGHT: auto">&nbsp;</div></div></body></html>
--0-235916557-1310625925=:65469--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
