Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11850
	for <linux-mm@kvack.org>; Wed, 29 Jul 1998 17:30:58 -0400
Date: Wed, 29 Jul 1998 20:00:14 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: de-luxe zone allocator, design 2
In-Reply-To: <199807291104.MAA01217@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980729195814.12136G-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Jul 1998, Stephen C. Tweedie wrote:
> On Tue, 28 Jul 1998 18:15:41 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > Agreed, although 16k chunks would probably be better for
> > 3 and 4 MB machines (allows DMA and network buffers).
> 
> In 2.1.112 we've now chopped down the default slab size for large
> objects from 16k to 8k, so 8k should be OK.  (8k NFS still needs 16k
> chunks, but you really want to be using 4k or smaller blocks on such
> low memory machines anyway, for precisely this reason.)

Isn't packing locality _very_ important on machines where you
have no memory to spare? In that case 16k would probably be
better; PLUS 16k will allow for real DMA buffers and stuff.

When we have lazy page reclamation, we don't have to keep free
the amount of pages we're keeping free now, so 16k areas should
be OK... (we'll only need to keep 2 of those free on most small
machines)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
