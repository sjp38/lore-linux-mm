Received: from mail.ccr.net (ccr@alogconduit1ai.ccr.net [208.130.159.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA31417
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 02:40:34 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 15 Jan 1999 01:31:02 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "14 Jan 1999 04:08:02 -0600"
Message-ID: <m1iue96lhl.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "EB" == Eric W Biederman <ebiederm> writes:

EB> Please take a look.  If it really is my fault shoot me.
Darn. It was me.

I wasn't setting PageLocked, before I added the page to the
swap cache, so the page was being removed from under my feet.
The one case I hadn't considered.

Then I was compounding it by setting after I had potentially slept,
and the page had been totally deallocated!!

That anything in the page cache is clean invariant is a pain!

Sorry for panicing but this close to the real 2.2 if I discover what
looks like a long hidden bug, I can't with a clear conscience keep quiet about it.

I shoould have the patch cleaned up tonight, and present it as an interesting variation
tommorrow.

My current tuning for handling thrashing jobs is abismal.
But the cpu usage seems low enough the rest of the time so this looks
like a valid vm strategy.  Making rpte entries for shared dirty pages
unnecessary.

We can write only once by makeing a pass over all of virtual memory, 
putting dirty pages on a dirty list, then crunching that dirty list.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
