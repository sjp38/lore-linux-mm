Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA09825
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 20:38:03 -0500
Subject: Re: Removing swap lockmap...
References: <87iue47gy4.fsf@atlas.CARNet.hr> <m11zksyuad.fsf@flinx.ccr.net>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 19 Jan 1999 02:37:49 +0100
In-Reply-To: ebiederm+eric@ccr.net's message of "18 Jan 1999 18:34:50 -0600"
Message-ID: <871zksqbyq.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

ebiederm+eric@ccr.net (Eric W. Biederman) writes:

> >>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> 
> 
> ZC> I removed swap lockmap all together and, to my surprise, I can't
> ZC> produce any ill behaviour on my system, not even under very heavy
> ZC> swapping (in low memory condition).
> 
> ZC> I remember there were some issues when swap lockmap was removed in
> ZC> 2.1.89, so it was reintroduced later (processes were dying randomly).
> 
> 
> ZC> Question is, why is everything running so smoothly now, even without
> ZC> swap lockmap?
> 
> For this patch to be safe we need to 
> A) Fix sysv shm to use the swap cache.

Yes, this case probably doesn't get enough testing with my current
setup, so it is quite hard (for me) to prove removing lockmap is
no-no. Problem is that I don't understand shm swapping very well, it
is piggybacked on "regular" MM as a special case, and I didn't had
time to go through it, yet.

> B) garantee that shrink_mmap is the only place that
>    removes a page from the swap cache, and that it never removes
>    a page while I/O is in progress, (as Stephen said).
> 
> This means a lot of the current cases like delete_from_swap_cache,
> and free_page_and_swap_cache need to be removed.

Yes, I believe you on this one.

> 
> And we need to be very carefull when we break down the swap cache,
> and make it an unshared page.
> 
> The change to normally remove pages with shrink_mmap is what makes it
> mostly safe now.
> 
> For 2.3 it should go.  For 2.2 it should stay.
> 

I'll still be testing it, nevertheless. Maybe after some time I get in 
some trouble, and then at least I'll know what to do. :-)

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
