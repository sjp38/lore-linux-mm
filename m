Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA29001
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 05:50:22 -0500
Date: Tue, 22 Dec 1998 11:49:54 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <m11zlssj7r.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981222114610.538B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On 22 Dec 1998, Eric W. Biederman wrote:

>To date I have only studied one very specific case,  what happens when
>a process dirties pages faster then the system can handle. 

Me too.

>3) The vm I was playing with had no way to limit the total vm size.
>   So process that are thrashing will slow other processes as well.
>   So we have a potential worst case scenario, the only solution to 
>   would be to implement RLIMIT_RSS.  

Hmm, no limiting the resident size is a workaround I think...

I agree that the fact that swapout returns 1 and really has not freed a
page is a bit messy though. Should we always do a shrink_mmap()  after
every succesfully swapout? 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
