Date: Fri, 10 Jul 1998 07:57:57 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807092337.AAA07652@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980710075508.31668E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 1998, Stephen C. Tweedie wrote:

> potentially far more valuable pages.  A multilevel cache is pretty much
> essential if you're going to let any cached data survive a grep flood.
> Whether you _want_ that, or whether you'd rather just let the cache
> drain and repopulate it after the IO has calmed, is a different
> question; there are situations where one or other decision might be
> best, so it's not a guaranteed win.  But the multilevel cache does have
> some nice properties which aren't so easy to get with page aging.  It
> also tends to be faster at finding pages to evict, since we don't
> require multiple passes to flush the transient page queue.

Let's go with those nice properties. Especially the last
one (quicker at finding pages) is essential in preventing
memory fragmentation (a 'lazy' list can be used to prevent
pressure on the few last 'free' zones from building).

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
