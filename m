Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA25355
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 10:30:33 -0400
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
References: <Pine.LNX.3.96.980705131034.327C-100000@dragon.bogus>
	<Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
	<199807061024.LAA00796@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 06 Jul 1998 08:37:02 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Mon, 6 Jul 1998 11:24:25 +0100
Message-ID: <m1vhpb2j9d.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> It does: the Duff's device in try_to_free_page does it, and seems to
ST> work well enough.  It was certainly tuned tightly enough: all of the
ST> hard part of getting the kswap stuff working well in try_to_swap_out()
ST> was to do with tuning the aggressiveness of swap relative to the buffer
ST> and cache reclaim mechanisms so that the try_to_free_page loop works
ST> well.  That's why the recent policies of adding little rules here and
ST> there all over the mm layer have disturbed the balance so much, I think.

The use of touch_page and age_page appear to be the most likely
canidates for the page cache being more persistent than it used to
be.

If I'm not mistaken shrink_mmap must be called more often now to
remove a given page.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
