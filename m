Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19139
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 14:07:19 -0400
Date: Sun, 5 Jul 1998 20:04:33 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: increasing page size
In-Reply-To: <19980705145314.A1909@uni-koblenz.de>
Message-ID: <Pine.LNX.3.96.980705200308.1574J-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: ralf@uni-koblenz.de
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998 ralf@uni-koblenz.de wrote:
> On Sat, Jul 04, 1998 Rik van Riel wrote:
> 
> > Page size is coded into hardware (except on m68k) and
> > there's no reason for using 32 kB pages when we can
> > use proper readahead and I/O clustering.
> 
> Page size is selectable on a per page base on all MIPS CPUs.  Possible
> sizes are 4kb, 16kb, 64kb, 256kb, 1mb, 4mb and 16mb.  Since the number
> of TLB entries (64 on R3k family, 32 entries on R4300, 48 R4k, R5k)
> can become a performance limit for apps with a large working set, using
> larger pagesizes is desireable.

Hmm, would that be tunable on a per-application basis, or
maybe as a kernel compile time option?

(the per-application thingy would be nice so we could avoid
breakage of applications when we switch the page size of the
kernel)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
