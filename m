Received: from roman (localhost [127.0.0.1])
	by michael.checkpoint.com (8.9.3/8.9.1) with SMTP id LAA11849
	for <linux-mm@kvack.org>; Mon, 24 Jul 2000 11:15:16 +0300 (IDT)
Message-ID: <00df01bff54f$280d1230$398d96d4@checkpoint.com>
From: "Roman Mitnitski" <roman@checkpoint.com>
Subject: Allocating large chunks of mem from net-bh
Date: Mon, 24 Jul 2000 11:11:26 +0200
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_00DC_01BFF55F.E8860A20"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_00DC_01BFF55F.E8860A20
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable



 Hi.

I need to allocate (dynamically, as the need arises) large memory areas
from the bottom-half context (net-bh, to be exact) in Linux 2.2.x.=20

kmalloc does not let me allocate as much memory as I need, and
vmalloc refuses to work in bottom-half context.=20

I don't need anything special from the allocated memory, (like physical =
continuity,
or DMA area). I even don't care much how long
it takes to allocate, sice it really does not happen that much often.

Is there any reasonable workaround that would let me solve this problem?
Is the situation in 2.4 any better (because my code will have to move on =
to 2.4
eventually)

 Roman


------=_NextPart_000_00DC_01BFF55F.E8860A20
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 5.50.4134.600" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;Hi.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I need to allocate (dynamically, as the =
need=20
arises) large memory areas</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>from the bottom-half context (net-bh, =
to be exact)=20
in Linux 2.2.x. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>kmalloc does not let me&nbsp;allocate =
as much=20
memory as I need, and</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>vmalloc refuses to work =
in&nbsp;bottom-half=20
context. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I don't need anything </FONT><FONT =
face=3DArial=20
size=3D2>special from the allocated memory, (like physical=20
continuity,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>or DMA area). </FONT><FONT face=3DArial =
size=3D2>I even=20
don't care much how long</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>it takes to allocate, sice it really =
does not=20
happen that much often.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Is there any reasonable workaround that =
would let=20
me solve this problem?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Is the situation in 2.4 any better =
(because my code=20
will have to move on to 2.4</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>eventually)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;Roman</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_00DC_01BFF55F.E8860A20--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
