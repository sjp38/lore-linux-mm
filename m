Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 077E66B01B0
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 07:36:33 -0400 (EDT)
Date: Fri, 2 Jul 2010 21:36:27 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [ATTEND][LSF/VM TOPIC] mmap_sem scalability and edge cases
Message-ID: <20100702113627.GC11732@laptop>
References: <AANLkTil6P5PNAYOplauoHiOgno-wrByOSAhS494-DAyJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTil6P5PNAYOplauoHiOgno-wrByOSAhS494-DAyJ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 01:58:36AM -0700, Michel Lespinasse wrote:
> I know I'm late in the game. Anyway, here is my topic proposal.

It is quite late, but thanks for the proposal. It's an interesting one
and something I'd like to talk about too (as well as a few others who
will be there).

I would say we probably will have enough room for you, but let me finish
compiling current list of attendees and topics, and see how many
attendees we're aiming for.

Thanks,
Nick

> 
> Problem:
> The mmap_sem plays a central role in the linux VM. As a rwsem, it works well
> for many workloads where most uses only require read locks on mmap_sem.
> However, other workloads where write locks on mmap_sem are frequent quickly
> hit scalability issues due to the combination of low granularity (there is
> only one mmap_sem for an entire process address space) and large hold times
> (under memory pressure, the mmap_sem is frequently held by threads waiting
> for disk access).
> As a separate, but related problem, we are seeing some bad mmap_sem related
> issues during OOM. The OOMing thread might be unable to progress because it
> needs to acquire mmap_sem, which the thread holding it might be unable to
> progress due to memory pressure. This is not un unfrequent situation for us,
> as we have some services that are memory bound rather than compute bound &
> these are frequently run under high memory pressure conditions.
> 
> Solutions:
> We have a number of patches that partially address these issues:
> - releasing mmap_sem when a page fault requires a disk read of the backing
> file
> - reducing mmap_sem hold time during mlock operations
> - unfair read acquire for the OOMing threads
> We don't currently have patches for, but would be interested in:
> - releasing mmap_sem when a page fault causes a disk wait due to memory
> reclaim (if it's possible to do so while avoiding starvation...)
> 
> -- 
> Michel "Walken" Lespinasse
> A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
