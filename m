Date: Sun, 12 Jul 1998 00:25:20 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807112123.WAA03437@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980712002155.8107D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 11 Jul 1998, Stephen C. Tweedie wrote:
> On Sat, 11 Jul 1998 16:14:26 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I'd think we'll want 4 levels, with each 'lower'
> > level having 30% to 70% more pages than the level
> 
> Personally, I think just a two-level LRU ought to be adequat.   Yes, I
> know this implies getting rid of some of the page ageing from 2.1 again,
> but frankly, that code seems to be more painful than it's worth.  The
> "solution" of calling shrink_mmap multiple times just makes the
> algorithm hideously expensive to execute.

This could be adequat, but then we will want to maintain
an active:inactive ratio of 1:2, in order to get a somewhat
realistic aging effect on the LRU inactive pages.

Or maybe we want to do a 3-level thingy, inactive in LRU
order and active and hyperactive (wired?) with aging.
Then we only promote pages to the highest level when they've
reached the highest age in the active level.
(OK, this is probably _far_ too complex, but I'm just
exploring some wild ideas here in the hope of triggering
some ingenious idea)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
