Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA20126
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 15:48:36 -0500
Date: Wed, 13 Jan 1999 20:26:21 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m100Vbm-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990113201316.9943B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Alan Cox wrote:

> > >> Could somebody spare a minute to explain why is that so, and what
> > >> needs to be done to make SHM swapping asynchronous?
> > 
> > > Maybe because nobody care about shm? I think shm can wait for 2.3 to be
> > > improved.
> > 
> > "Nobody"?  Oracle uses large shared memory regions for starters.
> 
> All the big databases use large shared memory objects. 

I was't aware of that. I noticed that also postgres (a big database) uses
shm but it's _only_ something like 1 Mbyte (at least during trivial
usage). With my current code such 1 Mbyte would not be touched unless
there would be some really big memory squeezee (like something that cause
a swapout of tons of memory and that would slowdown a bit the system
anyway). This is obviously not true in clean pre7 (see
try_to_free_pages()). 

With my latest code, optimizing the shm swapout (as we do with normal
userspace memory) would help only if the shm memory is going to be in size
something like the total VM allocated in all processes' mm.  Since I
supposed that "normal" apps don't use huge amount of shm memory I told
that we could not care until 2.3. I can't know how much shm memory uses
Oracle SQL server because I can't have it. I am pretty sure instead that
postgresql will be not stuck in shm swapout here even if the shm swapout
code is gross.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
