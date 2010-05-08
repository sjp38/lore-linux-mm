Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D352D6200BD
	for <linux-mm@kvack.org>; Sat,  8 May 2010 07:15:28 -0400 (EDT)
Received: by fxm7 with SMTP id 7so562369fxm.14
        for <linux-mm@kvack.org>; Sat, 08 May 2010 04:15:26 -0700 (PDT)
MIME-Version: 1.0
From: Henrik Kjellberg <et05hk6@gmail.com>
Date: Sat, 8 May 2010 13:15:05 +0200
Message-ID: <m2ze31aef501005080415t3b43f92exc1abda4b34d92992@mail.gmail.com>
Subject: Partial Array Self-Refresh on linux embedded systems
Content-Type: multipart/alternative; boundary=001485f4532edcf1300486134a8e
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linus.walleij@stericsson.com, Per Andersson <Per.Andersson@cs.lth.se>, =?ISO-8859-1?Q?Per_Frid=E9n?= <per.friden@stericsson.com>, Rickard Andersson <rickard.andersson@stericsson.com>
List-ID: <linux-mm.kvack.org>

--001485f4532edcf1300486134a8e
Content-Type: text/plain; charset=ISO-8859-1

Hello,
I have done my master thesis on the subject of Partial Array Self-refresh in
an embedded Linux environment at STEricsson. I have now finished my thesis,
started working and has verry little time (read: no time) to spend on Linux
hacking. There fore I would like to pass my work on, in hope that someone
else will find it interesting and worth puting som effort in.

One of the greatest challenges in mobile systems, like cell-phones, is
battery time. All unnecessary power consumers of a mobile system have to be
minimized. One such consumer is the dynamic memory. Dynamic Random Access
Memory (DRAM), is a volatile memory, where every bit of memory consists of a
capacitor and a transistor. When the capacitor is charged, the bit is set to
one, and when it is uncharged, the bit is set to zero.
 The main advantage with the construction is that only two components are
needed, which leads to a high memory density on the chip.
The disadvantage is the physical properties of a capacitor as a component.
The physical capacitor has leak currents, which drains the capacitor. The
leakage itself does not lead to noticeable losses, but the data will get
corrupted unless it is constantly refreshed by recharging the capacitor. The
recharging is done by reading out and writing back all the data of the
memory.
 During normal operation, the refresh is handled by the operating system.
When in idle mode, on the other hand, the refresh is done by the memory
itself, in a so called self-refresh mode, since the processor is powered
down. To refresh the whole memory if only a part of it is in use is a super
uous waste of power. That is why Partial Array Self-refresh (PASR) was
introduced.
There is no software implementation making use of PASR in the Linux kernel
as of today. The article is based on my master thesis, which aims to present
a possible implementation of PASR and evaluate its e ciency.

An article summarizing what I have done is found below:
http://sam.cs.lth.se/ExjobGetFile?id=240

Best regards
Henrik Kjellberg

--001485f4532edcf1300486134a8e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,<br>I have done my master thesis on the subject of Partial Array Self=
-refresh in an embedded Linux environment at STEricsson. I have now finishe=
d my thesis, started working and has verry little time (read: no time) to s=
pend on Linux hacking. There fore I would like to pass my work on, in hope =
that someone else will find it interesting and worth puting som effort in.<=
br>

<br>One of the greatest challenges in mobile systems, like cell-phones, is =
battery time. All unnecessary power consumers of a mobile system have to be=
 minimized. One such consumer is the dynamic memory. Dynamic Random Access =
Memory (DRAM), is a volatile memory, where every bit of memory consists of =
a capacitor and a transistor. When the capacitor is charged, the bit is set=
 to one, and when it is uncharged, the bit is set to zero.<br>

=A0The main advantage with the construction is that only two components are=
 needed, which leads to a high memory density on the chip.<br>The disadvant=
age is the physical properties of a capacitor as a component. The physical =
capacitor has leak currents, which drains the capacitor. The leakage itself=
 does not lead to noticeable losses, but the data will get corrupted unless=
 it is constantly refreshed by recharging the capacitor. The recharging is =
done by reading out and writing back all the data of the memory.<br>

=A0During normal operation, the refresh is handled by the operating system.=
 When in idle mode, on the other hand, the refresh is done by the memory it=
self, in a so called self-refresh mode, since the processor is powered down=
. To refresh the whole memory if only a part of it is in use is a super uou=
s waste of power. That is why Partial Array Self-refresh (PASR) was introdu=
ced.<br>

There is no software implementation making use of PASR in the Linux kernel =
as of today. The article is based on my master thesis, which aims to presen=
t a possible implementation of PASR and evaluate its e ciency.<br><br>
An article summarizing what I have done is found below:<br>
<a href=3D"http://sam.cs.lth.se/ExjobGetFile?id=3D240">http://sam.cs.lth.se=
/ExjobGetFile?id=3D240</a><br><br>Best regards<br>Henrik Kjellberg<br>

--001485f4532edcf1300486134a8e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
