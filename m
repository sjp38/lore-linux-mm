Received: from post.mail.demon.net (finch-post-10.mail.demon.net [194.217.242.38])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA25064
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 07:30:57 -0500
Date: Thu, 14 Jan 1999 11:02:34 +0000 (GMT/BST)
From: Mike Jagdis <mike@roan.co.uk>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113201316.9943B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.91.990114105702.20708C-100000@toaster.roan.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Andrea Arcangeli wrote:

> I was't aware of that. I noticed that also postgres (a big database) uses
> shm but it's _only_ something like 1 Mbyte (at least during trivial
> usage). With my current code such 1 Mbyte would not be touched unless
> there would be some really big memory squeezee (like something that cause
> a swapout of tons of memory and that would slowdown a bit the system
> anyway). This is obviously not true in clean pre7 (see
> try_to_free_pages()). 
> 
> With my latest code, optimizing the shm swapout (as we do with normal
> userspace memory) would help only if the shm memory is going to be in size
> something like the total VM allocated in all processes' mm.  Since I
> supposed that "normal" apps don't use huge amount of shm memory I told
> that we could not care until 2.3. I can't know how much shm memory uses
> Oracle SQL server because I can't have it. I am pretty sure instead that
> postgresql will be not stuck in shm swapout here even if the shm swapout
> code is gross.

Informix Dynamic Server is a free download from www.informix.com
(but its fairly big, ~30MB). I think Oracle is downloadable too.
With either the shm used is normally "large" with respect to
available physical memory (i.e. everything that isn't needed by
processes under your normal load) because the database engines
use it to cache data (this is why they want raw IO - there's no
point the OS caching the data as well).

				Mike

-- 
    A train stops at a train station, a bus stops at a bus station.
    On my desk I have a work station...
.----------------------------------------------------------------------.
|  Mike Jagdis                  |  Internet:  mailto:mike@roan.co.uk   |
|  Roan Technology Ltd.         |                                      |
|  54A Peach Street, Wokingham  |  Telephone:  +44 118 989 0403        |
|  RG40 1XG, ENGLAND            |  Fax:        +44 118 989 1195        |
`----------------------------------------------------------------------'

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
