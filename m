Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA08462
	for <linux-mm@kvack.org>; Fri, 8 Jan 1999 21:35:43 -0500
Date: Sat, 9 Jan 1999 03:34:56 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <199901090213.CAA05306@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990109032305.805C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stephen!

On Sat, 9 Jan 1999, Stephen C. Tweedie wrote:

> deadlock.  The easiest way I can see of achieving something like this is
> to set current->flags |= PF_MEMALLOC while we hold the superblock lock,

Hmm, we must not avoid shrink_mmap() to run. So I see plain wrong to set
the PF_MEMALLOC before call __get_free_pages(). Very cleaner to use
GFP_ATOMIC to achieve the same effect btw ;).

Now I am too tired to follow the other part of your email (I'll read
tomorrow, now it's time to sleep for me... ;).

Forget to tell, did you have comments about the FreeAfter() stuff? It made
sense to me (looking at page_io if I remeber well) but I have not
carefully reread it yet after Linus's comments on it. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
