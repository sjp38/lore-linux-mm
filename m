Date: Wed, 16 Aug 2000 14:30:41 -0700 (PDT)
From: <bodnar42@bodnar42.dhs.org>
Subject: 2.4.0-t7p4-vmpatch2 results #1
Message-ID: <Pine.LNX.4.21.0008161429310.2972-100000@bodnar42.dhs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
 The test system is a AMD K6/2 337 with 64megs of SDRAM. The kernel
is Linux-2.4.0-test7pre4 w/ 2.4.0-t7p4-vmpatch2 + ReiserFS
3.6.12. The distribution is a more or less stock version of Mandrake
cooker.

 GNOME startup time has significantly improved, from around 40 seconds to
about 15. Also, the starting init -> GDM login prompt time appears to be
about halved, although its really hard to tell without actually timing
it. Once the system is up, responsiveness has improved, and thrashing has
basically stopped except in the most ridiculous workloads (VMWare running
FreeBSD in GNOME, for example). No memory leaks, deadlocks, or weird
slowdowns have been observed, and from what I've seen system stability has
defintely not taken a negative hit.

 It would be wonderful if these changes would make it in before 2.4.0,
current/future Linux users would be much better off, and I really don't
like patching my kernel ;)

-Bodnar42


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
