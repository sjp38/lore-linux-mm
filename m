Date: Sat, 11 Jul 1998 21:47:44 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807112123.WAA03437@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980711214119.28032A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 11 Jul 1998, Stephen C. Tweedie wrote:

> Personally, I think just a two-level LRU ought to be adequat.   Yes, I
> know this implies getting rid of some of the page ageing from 2.1 again,
> but frankly, that code seems to be more painful than it's worth.  The
> "solution" of calling shrink_mmap multiple times just makes the
> algorithm hideously expensive to execute.

Hmmm, is that a hint that I should sit down and work on the code tomorrow
whilst recovering? =)

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
