Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6C5156B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 20:55:19 -0400 (EDT)
Message-ID: <COL115-DS17FCFB8683288781F8E011BC770@phx.gbl>
From: "Jun Hu" <duanshuidao@hotmail.com>
Subject: [help] kernel boot parameter "mem=xx"  disparity
Date: Wed, 17 Oct 2012 08:55:14 +0800
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0009_01CDAC45.1F3E7440"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

OaECO>>.a MIME ,nE 1/2 uA?a. 1/2 OE 1/4 th!GBP

------=_NextPart_000_0009_01CDAC45.1F3E7440
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

Hi Guys:

My machine has 8G memory, when I use kernel boot parameter mem=3D5G , it =
only display =A1=B04084 M=A1=B1 using =A1=B0free =A8Cm =A1=B0.=20
where the =A1=B05120-4084 =3D 1036M =A1=B0 memory run?

# /bin/uname -a
Linux dom0-93 3.0.13-0.27-default #1 SMP Wed Feb 15 13:33:49 UTC 2012 =
(d73692b) x86_64 x86_64 x86_64 GNU/Linux

dom0-93:~ # free -m
total used free shared buffers cached
Mem: 4084 259 3824 0 6 84
-/+ buffers/cache: 169 3915
Swap: 1916 0 1916
dom0-93:~ # cat /proc/cmdline=20
root=3D/dev/disk/by-id/cciss-3600508b100104839535656314933001b-part1 =
resume=3D/dev/disk/by-id/cciss-3600508b100104839535656314933001b-part2 =
splash=3Dsilent crashkernel=3D256M-:128M vga=3D0x317 mem=3D5120M


when I didn't append "mem=3D" parmeter, "free -m " shows that total =
memory is  7892M ,
it only eat up  300M (8192-7892), though I don't know where the 300M =
memory go.

why? 
------=_NextPart_000_0009_01CDAC45.1F3E7440
Content-Type: text/html;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<HTML><HEAD></HEAD>
<BODY dir=3Dltr>
<DIV dir=3Dltr>
<DIV style=3D"FONT-FAMILY: 'Calibri'; COLOR: #000000; FONT-SIZE: 12pt">
<DIV=20
style=3D"FONT-STYLE: normal; DISPLAY: inline; FONT-FAMILY: 'Calibri'; =
COLOR: #000000; FONT-SIZE: small; FONT-WEIGHT: normal; TEXT-DECORATION: =
none">
<DIV dir=3Dltr>
<DIV style=3D"FONT-FAMILY: 'Calibri'; COLOR: #000000; FONT-SIZE: 12pt">
<DIV>Hi Guys:</DIV>
<DIV>&nbsp;</DIV>
<DIV>My machine has 8G memory, when I use kernel boot parameter mem=3D5G =
, it only=20
display =A1=B04084 M=A1=B1 using =A1=B0free =A8Cm =A1=B0. </DIV>
<DIV>where the =A1=B05120-4084 =3D 1036M =A1=B0 memory run?</DIV>
<DIV>&nbsp;</DIV>
<DIV># /bin/uname -a</DIV>
<DIV>Linux dom0-93 3.0.13-0.27-default #1 SMP Wed Feb 15 13:33:49 UTC =
2012=20
(d73692b) x86_64 x86_64 x86_64 GNU/Linux</DIV>
<DIV>&nbsp;</DIV>
<DIV>dom0-93:~ # free -m</DIV>
<DIV>total used free shared buffers cached</DIV>
<DIV>Mem: 4084 259 3824 0 6 84</DIV>
<DIV>-/+ buffers/cache: 169 3915</DIV>
<DIV>Swap: 1916 0 1916</DIV>
<DIV>dom0-93:~ # cat /proc/cmdline </DIV>
<DIV>root=3D/dev/disk/by-id/cciss-3600508b100104839535656314933001b-part1=
=20
resume=3D/dev/disk/by-id/cciss-3600508b100104839535656314933001b-part2=20
splash=3Dsilent crashkernel=3D256M-:128M vga=3D0x317 mem=3D5120M</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>when I didn't append "mem=3D" parmeter, "free -m " shows that total =
memory=20
is&nbsp; 7892M ,</DIV>
<DIV>it only eat up&nbsp; 300M (8192-7892), though I don't know where =
the 300M=20
memory go.</DIV>
<DIV>&nbsp;</DIV>
<DIV>why? </DIV></DIV></DIV></DIV></DIV></DIV></BODY></HTML>

------=_NextPart_000_0009_01CDAC45.1F3E7440--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
