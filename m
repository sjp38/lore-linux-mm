Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18697
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 12:31:16 -0400
Date: Sun, 5 Jul 1998 13:29:58 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: increasing page size
In-Reply-To: <Pine.A41.3.95.980705101710.48492B-100000@stud2.tuwien.ac.at>
Message-ID: <Pine.LNX.3.96.980705132841.960B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter-Paul Witta <e9525748@student.tuwien.ac.at>
Cc: "David S. Miller" <davem@dm.cobaltmicro.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Peter-Paul Witta wrote:

> > Stephen Tweedie and Ingo Molnar have some swapin
> > readahead code, carefully hidden in a secret place...
> 
> this wont solve the dma fragmentation problem, would it???

That is solved with a new memory allocator. See my home
page for more info.

> > Page size is coded into hardware (except on m68k) and
> > there's no reason for using 32 kB pages when we can
> > use proper readahead and I/O clustering.
> 
> i thought intel ia32 had no problems with 4k .. 4m ???

x86 uses 4k for user pages. The 4M pages only work for
ring-0 (kernel mode) stuff.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
