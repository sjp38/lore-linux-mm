From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906211736.KAA17592@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Mon, 21 Jun 1999 10:36:37 -0700 (PDT)
In-Reply-To: <14190.28416.483360.862142@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 21, 99 05:57:36 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 21 Jun 1999 09:46:19 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > I don't agree with you about swapoff needing the mmap_sem. In my
> > thinking, mmap_sem is needed to preserve the vma list, *if* you 
> > go to sleep while scanning the list. Updates to the vma fields/
> > chain are protected by kernel_lock and mmap_sem. 
> 
> No.  mmap_sem protects both the vma list and the page tables.  Page
> faults hold the mmap semaphore both to protect the vma list and to
> protect against concurrent pagins to the same page.  
> 
> The swapper is currently exempt from the mmap_sem, so the paging code
> needs to check whether the current pte has disappeared if it ever
> blocks, but it assumes that we never have concurrent pagein occurring
> (think threads).  swapoff currently breaks that assumption.
>

But doesn't my previous logic work in this case too? Namely
that kernel_lock is held when any code looks at or changes
a pte, so if swapoff holds the kernel_lock and never goes to 
sleep, things should work?

Maybe if you can jot down a quick scenario where a problem occurs
when swapoff does not take mmap_sem, it would be easier for me
to spot which concurrency issue I am missing ...

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
