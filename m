Date: Wed, 3 May 2000 00:08:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <yttg0s13gjx.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005030004330.1677-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On 2 May 2000, Juan J. Quintela wrote:

>swap_entry bit, but not agreement in which is the correct one.

My latest one is the correct one but I would also use the atomic operation
in shrink_mmap even if we hold the page lock to be fully safe. I have an
assert that BUG if a page is freed with such bit set and it never triggers
since I noticed the few problematic places thanks to Ben.

>diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1plus/mm/memory.c lin
>ux/mm/memory.c
>--- pre7-1plus/mm/memory.c      Tue Apr 25 00:46:18 2000
>+++ linux/mm/memory.c   Tue May  2 00:36:13 2000
>@@ -1053,7 +1053,7 @@
> 
>        pte = mk_pte(page, vma->vm_page_prot);
> 
>-       SetPageSwapEntry(page);
>+       /*      SetPageSwapEntry(page);  */
> 
>        /*
>         * Freeze the "shared"ness of the page, ie page_count + swap_count.

Are you sure it solves the problem? Could you try also the other patch I
sent you in the email of 1 minute ago? that should be even more effective.

I'll let you know what happens here...

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
