Date: Thu, 9 Jul 1998 20:59:57 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807091442.PAA01020@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980709205619.28236F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Stephen Tweedie <sct@dcs.ed.ac.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 1998, Stephen C. Tweedie wrote:
> On Tue, 7 Jul 1998 13:50:02 -0400 (EDT), "Benjamin C.R. LaHaise"
> <blah@kvack.org> said:
> 
> > Right.  I'd rather see a multi-level lru like policy (ie on each cache hit
> > it gets moved up one level in the cache, with the lru'd pages from a given
>
> There's a fundamentally nice property about the multi-level cache
> which we _cannot_ easily emulate with page aging, and that is the
> ability to avoid aging any hot pages at all while we are just
> consuming cold pages.  For example, a large "find|xargs grep" can be
> satisfied without staling any of the existing hot cached pages.

Then I'd better incorporate a design for this in the zone
allocator (we could add this to the page_struct, but in
the zone_struct we can make a nice bitmap of it).

OTOH, is it really _that_ much different from an aging
scheme with an initial age of 1?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
