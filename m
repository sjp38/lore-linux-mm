Date: Mon, 13 Jul 1998 14:23:56 +0100
Message-Id: <199807131323.OAA06205@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980712002155.8107D-100000@mirkwood.dummy.home>
References: <199807112123.WAA03437@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980712002155.8107D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 12 Jul 1998 00:25:20 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Sat, 11 Jul 1998, Stephen C. Tweedie wrote:
>> On Sat, 11 Jul 1998 16:14:26 +0200 (CEST), Rik van Riel
>> <H.H.vanRiel@phys.uu.nl> said:
>> 
>> > I'd think we'll want 4 levels, with each 'lower'
>> > level having 30% to 70% more pages than the level
>> 
>> Personally, I think just a two-level LRU ought to be adequat.   Yes, I
>> know this implies getting rid of some of the page ageing from 2.1 again,
>> but frankly, that code seems to be more painful than it's worth.  The
>> "solution" of calling shrink_mmap multiple times just makes the
>> algorithm hideously expensive to execute.

> This could be adequat, but then we will want to maintain
> an active:inactive ratio of 1:2, in order to get a somewhat
> realistic aging effect on the LRU inactive pages.

Aging is not a good thing in the cache, in general.  We _want_ to be
able to empty the cache at short notice.  LRU works for that.  The
existing physical scan is definitely suboptimal without ageing, but that
doesn't mean that aging is the right answer.  (I tried doing buffer
ageing in the original kswap.  It sucked.)

> Or maybe we want to do a 3-level thingy, inactive in LRU
> order and active and hyperactive (wired?) with aging.

If we have more than 2 levels, then we definitely don't want ageing:
just let migration of pages between the levels do the ageing for us.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
