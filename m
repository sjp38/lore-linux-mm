Received: from sbustd.stud.uni-sb.de (IDENT:PmR8Or2qevXdhTnRTprTU3HIBiwj0ZFS@eris.rz.uni-sb.de [134.96.7.8])
	by indyio.rz.uni-sb.de (8.9.3/8.9.3) with ESMTP id LAA3958313
	for <linux-mm@kvack.org>; Tue, 27 Jul 1999 11:33:00 +0200 (CST)
Message-ID: <003101bed81b$1d39dac0$30b16086@sl16es04.phil.uni-sb.de>
From: "ms" <masp0008@stud.uni-sb.de>
Subject: mm synchronization question
Date: Tue, 27 Jul 1999 12:30:39 +0200
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_002E_01BED82B.E0C2AAC0"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_002E_01BED82B.E0C2AAC0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I think I found a minor bug:
do_wp_page() does not call spin_unlock() if called with bad parameters:
if "goto  bad_wp_page" is executed, then noone unlocks the =
page_table_lock spinlock.
=20
My second question is the mm semaphore:
It seems that if in a multi threaded application several threads access =
a large mmaped file, that then all page-in operations are serialized =
(including waiting for the disk IO)
Is that correct?
Are there any plans to change that?
=20
a possible alternative:
* every mm has a linked list of all pages the OS is currently working =
on.
* instead of just acquiring the mm semaphore, every operation must first =
check that there are no collisions with pending operations, then it =
acquires the semaphore.
* we drop the mm semaphore during long (i.e. IO) operations.

Please Cc, I=B4m currently not on the mailing list.
--
    Manfred

------=_NextPart_000_002E_01BED82B.E0C2AAC0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD W3 HTML//EN">
<HTML>
<HEAD>

<META content=3Dtext/html;charset=3Diso-8859-1 =
http-equiv=3DContent-Type><!DOCTYPE HTML PUBLIC "-//W3C//DTD W3 =
HTML//EN">
<META content=3D'"MSHTML 4.72.3110.7"' name=3DGENERATOR>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>I think I found a minor =

bug:</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>do_wp_page() does not =
call=20
spin_unlock() if called with bad parameters:</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>if &quot;goto&nbsp; =
bad_wp_page&quot;=20
is executed, then noone unlocks the page_table_lock =
spinlock.</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>My second question is =
the mm=20
semaphore:</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>It seems that if in a =
multi threaded=20
application several threads access a large mmaped file, that then all =
page-in=20
operations are serialized (including waiting for the disk =
IO)</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>Is that =
correct?</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>Are there any plans to =
change=20
that?</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>a possible =
alternative:</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2></FONT><FONT =
face=3DArial size=3D2>*=20
every mm has a linked list of all pages the OS is currently working=20
on.</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>* instead of just =
acquiring the mm=20
semaphore, every operation must first check that there are no collisions =
with=20
pending operations, then it acquires the semaphore.</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>* we drop the mm =
semaphore during=20
long (i.e. IO) operations.</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>Please Cc, I&acute;m =
currently not on=20
the mailing list.</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>--</FONT></DIV>
<DIV><FONT color=3D#000000 face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;=20
Manfred</FONT></DIV></BODY></HTML>

------=_NextPart_000_002E_01BED82B.E0C2AAC0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
