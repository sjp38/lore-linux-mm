Received: from mail.ccr.net (ccr@alogconduit1aj.ccr.net [208.130.159.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA20776
	for <linux-mm@kvack.org>; Mon, 30 Nov 1998 19:29:11 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <199811261236.MAA14785@dax.scot.redhat.com> 	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> 	<199811271602.QAA00642@dax.scot.redhat.com> 	<m1ogpsp93f.fsf@flinx.ccr.net> <199811301113.LAA02870@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Nov 1998 16:00:18 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 30 Nov 1998 11:13:44 GMT"
Message-ID: <m1n25896z1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I just performed one more test on
pre-linux-2.1.130 + Stephan Tweedies vm patch.

I went into proc
and changed pagecache from:
5 30 75 to 0 100 100
Then I ran my test program.
Until it was done running the system was locked up.

The same results happend with
0 75 75

With 0 30 75 however  I can finish composing this email.

I now know definentily that this is an autobalancing problem.

My suggestion would be to drop a call to shrink_mmap immediately
after swap_out with the same size.  And to ignore it's return code.

But however we do it, in cases of heavy swapping we need to call shrink_mmap
more often.

Perhaps this evening I can try some more.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
