Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00115
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 13:45:52 -0500
Date: Wed, 2 Dec 1998 19:32:56 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Update shared mappings
In-Reply-To: <199812021621.QAA04235@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981202191811.4720A-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 1998, Stephen C. Tweedie wrote:

>else's mm semaphore.  If you have two processes doing that to each other
>(ie. two processes mapping the same file r/w and doing msyncs), then you
>can most certainly still deadlock.

The thing would be trivially fixable if it would exists a down_trylock() 
that returns 0 if the semaphore was just held. I rejected now the
update_shared_mappings from my tree in the meantime though.

I have a question. Please consider only the UP case (as if linux would not
support SMP at all). Is it possible that while we are running inside
sys_msync() and another process has the mmap semaphore held?

Stephen I read some emails about a PG_dirty flag. Could you tell me some
more about that flag? 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
