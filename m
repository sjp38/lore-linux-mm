Date: Sat, 11 Jul 1998 22:23:11 +0100
Message-Id: <199807112123.WAA03437@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980711161041.6711A-100000@mirkwood.dummy.home>
References: <199807091442.PAA01020@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980711161041.6711A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 11 Jul 1998 16:14:26 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> I'd think we'll want 4 levels, with each 'lower'
> level having 30% to 70% more pages than the level
> above. This should be enough to cater to the needs
> of both rc5des-like programs and multi-megabyte
> tiled image processing.

> Then again, I could be completely wrong :) Anyone?

Maybe, maybe not --- we'd have to try it.  However, I'm always a bit
dubious about being overly clever about this kind of stuff, and two
level may well work fine.  At worst, we can do ageing on the resident
level and LRU on the transient, and let the aging take care of it.

Personally, I think just a two-level LRU ought to be adequat.   Yes, I
know this implies getting rid of some of the page ageing from 2.1 again,
but frankly, that code seems to be more painful than it's worth.  The
"solution" of calling shrink_mmap multiple times just makes the
algorithm hideously expensive to execute.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
