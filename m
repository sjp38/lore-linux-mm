Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA04026
	for <linux-mm@kvack.org>; Tue, 28 Jul 1998 12:30:55 -0400
Date: Tue, 28 Jul 1998 18:15:41 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: de-luxe zone allocator, design 2
In-Reply-To: <199807271112.MAA00732@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980728181426.6846B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 1998, Stephen C. Tweedie wrote:
> On Fri, 24 Jul 1998 23:03:18 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > With the reports of Linux booting in 3 MB it's probably
> > time for some low-mem adjustments, but in general this
> > scheme should be somewhat better designed overall.
> 
> In 3MB, zoning in 128k chunks is crazy --- you want 8k chunks, max!

Agreed, although 16k chunks would probably be better for
3 and 4 MB machines (allows DMA and network buffers).

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
