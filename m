Date: Sat, 11 Jul 1998 16:14:26 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807091442.PAA01020@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980711161041.6711A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 1998, Stephen C. Tweedie wrote:

> There's a fundamentally nice property about the multi-level cache
> which we _cannot_ easily emulate with page aging, and that is the
> ability to avoid aging any hot pages at all while we are just
> consuming cold pages.  For example, a large "find|xargs grep" can be
> satisfied without staling any of the existing hot cached pages.

Thinking over this design, I wonder how many levels
we'll need for normal operation, and how many pages
are allowed in each level.

I'd think we'll want 4 levels, with each 'lower'
level having 30% to 70% more pages than the level
above. This should be enough to cater to the needs
of both rc5des-like programs and multi-megabyte
tiled image processing.

Then again, I could be completely wrong :) Anyone?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
