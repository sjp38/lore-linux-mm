Received: from web3.hq.eso.org (web3.hq.eso.org [134.171.7.4])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA24771
	for <linux-mm@kvack.org>; Mon, 17 Aug 1998 04:47:00 -0400
Received: from localhost (ndevilla@localhost) by opus3.hq.eso.org (8.8.5/eso_cl_6.0) with SMTP id KAA27333 for <linux-mm@kvack.org>; Mon, 17 Aug 1998 10:46:25 +0200 (MET DST)
Date: Mon, 17 Aug 1998 10:46:24 +0200 (MET DST)
From: Nicolas Devillard <ndevilla@mygale.org>
Subject: memory overcommitment
Message-ID: <Pine.SOL.3.96.980817103420.26929A-100000@opus3>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear all:

I can allocate up to 2 gigs of memory on a Linux box with 256 megs of
actual RAM + swap. Having browsed through pages and pages of linux-kernel
mailing-lists archives, I found out a thread discussing that with the
usual pros and cons, but could not find anything done about it. Ah, and I
know the standard answer: ulimit or limit would do the job, but they do
not apply system-wide.

The usual story of over-commitment compares memory allocation to
airplane companies, but in this case something goes wrong: the kernel
actually knows that it has only 256 megs, why does it commit itself to
promise more than 8 times this amount to any normal user requesting it??
A company selling 100 tickets for a 12-seat plane would have serious
problems I guess. It is Ok to overbook, but what are you doing exactly
when all passengers show up at the counter, especially when you have
overbooked by a factor 8 or so?

In this case, I found out that once I start touching the 2 generously
allocated gigs of memory, RAM goes away, then swap, then daemons start
dying one by one and the machine freezes to the point of unusability. More
than a single memory allocation problem or policy, it is a serious threat
to security, because it allows to kill dameons for any user.

Anything done about it? Some references I may have missed about this
point? Someone working on it? An easy quickfix maybe??

Thanks for helping,
Nicolas

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
