Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA18676
	for <linux-mm@kvack.org>; Tue, 11 May 1999 07:29:38 -0400
Date: Tue, 11 May 1999 13:38:48 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <m1g154e7ou.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9905111334580.929-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10 May 1999, Eric W. Biederman wrote:

>The reason I am looking at reverse page entries, is I would like to handle
>dirty mapped pages better.  
>My thought is basically to trap the fault that dirties the page and mark it dirty.
>Then after it has aged long enough I unmap or at least clear the write allow bits of
>the pte or ptes.
>
>This does buy an improvement, in when things get written out.  But beyond that I
>don't know.

Having the reverse lookup from pagemap to ptes would also make life a bit
easier in my update_shared_mappings ;). So in general I see your point.
Think when you'll clear the dirty bit from the pagemap, then you'll want
to mark clean also the pte in the tasks. Right?

But I am worried by page faults. The page fault that allow us to know
where there is an uptodate swap-entry on disk just hurt performances more
than not having such information (I did benchmarks).

>It's certainly something to think about for your other algorithms.

I am not sure if it's worthwhile, but I think it worth testing ;).

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
