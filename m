Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19732
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 14:08:31 -0500
Date: Sat, 5 Dec 1998 20:02:17 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <m0zmMvm-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.981205200128.4902A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: chris@ferret.lmh.ox.ac.uk, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sat, 5 Dec 1998, Alan Cox wrote:

> > I will compile a new patch (against 2.1.130 again, since
> > 2.1.131 contains mostly VM mistakes that I want reversed)
> > this weekend...
> 
> 2.1.131 is materially faster here than any of the variants I've
> tried. Are you sure ? 

Sure it's faster. It just doesn't come near the
auto balancing that could have been (and appears
to be in my tree).

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
