Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA23920
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 11:42:55 -0500
Date: Mon, 21 Dec 1998 16:42:09 GMT
Message-Id: <199812211642.QAA02775@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.96.981221150612.546A-100000@laser.bogus>
References: <199812211339.NAA02125@dax.scot.redhat.com>
	<Pine.LNX.3.96.981221150612.546A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Dec 1998 15:08:35 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Mon, 21 Dec 1998, Stephen C. Tweedie wrote:
>> in every case I have tried.  132-pre3 seems OK on a larger memory
>> machine, but there's no way I'll be running it on my low-memory test
>> boxes.

> Could you try to apply my patch I sent to you too some minutes ago? 

No.  I'm in thesis mode until the new year (I really shouldn't be
writing this!).  I've already tested the VM, and have something which
works.  What is in ac* has been tuned and gives overall good
behaviour.  Every single proposal I've seen since, without exception,
has performed worse on low memory, worse on 64MB, has trashed the
cache, has result in large amounts of read IO during kernel builds, or
has had some other such regression against the VM I've been tuning for
the last two or three weeks.  I am _not_ about to go starting that
tuning process all over again.

If you want my attention, then benchmark your own patch and show me
that it is better than what we have.  So far, I have been benchmarking
everybody else's patches, and they are all worse than what I already
have.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
