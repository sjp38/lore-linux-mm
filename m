From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14340.24096.808136.514437@dukat.scot.redhat.com>
Date: Wed, 13 Oct 1999 11:25:36 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910111823320.18777-100000@weyl.math.psu.edu>
References: <14338.25285.780802.755159@dukat.scot.redhat.com>
	<Pine.GSO.4.10.9910111823320.18777-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 18:31:37 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

> And spinlock being released in the ->swapout() is outright ugly. OK, so
> we are adding to mm_struct a new semaphore (vma_sem) and getting it around
> the places where the list is modified + in the swapper (for scanning). In
> normal situation it will never give us contention - everyone except
> swapper uses it with mmap_sem already held. Are there any objections
> against it? If it's OK I'll go ahead and do it. Comments?

Looks OK as long as the swapper remains non-recursive and we never, ever
allocate memory outside the swapper with vma_sem held.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
