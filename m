Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04562
	for <linux-mm@kvack.org>; Fri, 27 Nov 1998 07:05:37 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <199811261236.MAA14785@dax.scot.redhat.com> 	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> <199811271602.QAA00642@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 28 Nov 1998 01:31:00 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Fri, 27 Nov 1998 16:02:51 GMT"
Message-ID: <m1ogpsp93f.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> Looks like I have a handle on what's wrong with the 2.1.130 vm (in
ST> particular, its tendency to cache too much at the expense of
ST> swapping).

I really should look and play with this but I have one question.

Why does it make sense when we want memory, to write every page
we can to swap before we free any memory?

I can't see how the policy of staying on a particular method of freeing pages
will hurt in the other cases where if we say we freed a page we actually did,
but in the current swap-out case it worries me.

Would a limit on a number of pages to try to write-to swap before we start trying to reclaim
pages be reasonable?

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
