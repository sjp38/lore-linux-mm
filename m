Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA20838
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 17:14:25 -0500
Date: Wed, 13 Jan 1999 22:14:02 GMT
Message-Id: <199901132214.WAA07436@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113190617.185C-100000@laser.bogus>
References: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.990113190617.185C-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 13 Jan 1999 19:10:28 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Wed, 13 Jan 1999, Rik van Riel wrote:
>> - in allocating swap space it just doesn't make sense to read
>> into the next swap 'region'

> The point is that I can't see a swap `region' looking at how
> scan_swap_map() works. The more atomic region I can see in the swap space
> is a block of bytes large PAGE_SIZE bytes (e.g. offset ;).

The whole point is that we try to swap adjacent virtual pages to
adjacent swap entries, so there is a good chance that nearby swap
entries are going to be useful when we page them back in again.  Given
that adjacent swap entries on a swap partition are guaranteed to be
physically contiguous, it costs very little to swap in several nearby
elements at the same time, and we get a good chance of reading in useful
pages.

> For the case of binaries the aging on the page cache should take care of
> it (even if there's no aging on the swap cache as pre[567] if I remeber
> well). 

There is no aging on the page cache at all other than the PG_referenced
bit.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
