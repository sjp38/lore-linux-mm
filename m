Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA22526
	for <linux-mm@kvack.org>; Sun, 6 Dec 1998 00:31:11 -0500
Date: Sun, 6 Dec 1998 06:20:57 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <m0zmMvm-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.981206061950.14666F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: chris@ferret.lmh.ox.ac.uk, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sat, 5 Dec 1998, Alan Cox wrote:
> 
> > I will compile a new patch (against 2.1.130 again, since
> > 2.1.131 contains mostly VM mistakes that I want reversed)
> > this weekend...
> 
> 2.1.131 is materially faster here than any of the variants I've
> tried. Are you sure ? 

Not completely, but please check out my new patch against
2.1.131. It should be faster still without putting too
much of a cap on the cache size.

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
