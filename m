Date: Fri, 21 May 1999 10:25:42 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Assumed Failure rates in Various o.s's ?
In-Reply-To: <19990521120725.A581384@daimi.au.dk>
Message-ID: <Pine.LNX.3.95.990521101041.17710A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Erik Corry <erik@arbat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, ak-uu@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 1999, Erik Corry wrote:

> According to Andi you already fixed this with a read lock that
> prevents mmap and mmunmap from doing anything while the copy
> is running.  This makes sense, since if you do it right with a
> readers/writers lock you can keep out mmap without serialising
> copy_to_user or copy_from_user.

I really like the cleanliness of this approach, but it's troublesome:
memory allocations in other threads would then get blocked during large
IOs -- very bad.  What if we instead move from the mm level semaphore to a
per vma locking scheme?  The mmap semaphore could become a spinlock for
fudging with list of vmas, and mmap/page faults/... could lock the
specific vma.  Or would this be too heavy?

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
