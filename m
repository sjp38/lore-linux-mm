Message-ID: <3D2C9288.51BBE4EB@zip.com.au>
Date: Wed, 10 Jul 2002 13:01:12 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Devil's advocate here.  Sorry.

William Lee Irwin III wrote:
> 
> ...
> (1)  page replacement no longer goes around randomly unmapping things

Got any numbers to back that up?

> (2)  referenced bits are more accurate because there aren't several ms
>         or even seconds between find the multiple pte's mapping a page

Got any numbers to show the benefit of this?

> (3)  reduces page replacement from O(total virtually mapped) to O(physical)

Numbers

> (4)  enables defragmentation of physical memory

Vapourware

> (5)  enables cooperative offlining of memory for friendly guest instance
>         behavior in UML and/or LPAR settings

Vapourware

> (6)  demonstrable benefit in performance of swapping which is common in
>         end-user interactive workstation workloads (I don't like the word
>         "desktop"). c.f. Craig Kulesa's post wrt. swapping performance

Demonstrable?  I see handwaving touchy-feely stuff.

> (7)  evidence from 2.4-based rmap trees indicates approximate parity
>         with mainline in kernel compiles with appropriate locking bits

err.  You mean that if you apply hotrodding to rmap but not mainline,
rmap achieves parity with mainline?

> (8)  partitioning of physical memory can reduce the complexity of page
>         replacement searches by scanning only the "interesting" zones
>         implemented and merged in 2.4-based rmap

But the page reclaim code is wildly inefficient in all kernels.
It's single-threaded via the spinlock.  Scaling that across
realistically two or less zones is insufficient.

Any numbers which demonstrate the benefit of this?

> (9)  partitioning of physical memory can increase the parallelism of page
>         replacement searches by independently processing different zones
>         implemented, but not merged in 2.4-based rmap

Numbers?

> (10) the reverse mappings may be used for efficiently keeping pte cache
>         attributes coherent

Do we need that?

> (11) they may be used for virtual cache invalidation (with changes)

Do we need that?

> (12) the reverse mappings enable proper RSS limit enforcement
>         implemented and merged in 2.4-based rmap
> 

Score one.


c'mon, guys.  It's all fluff.  We *have* to do better than this.
It's just software, and this is just engineering.  There's no
way we should be asking Linus to risk changing his VM based on
this sort of advocacy.

Bill, please throw away your list and come up with a new one.
Consisting of workloads and tests which we can run to evaluate
and optimise page replacement algorithms.

Alternatively, please try to enumerate the `operating regions'
for the page replacement code.  Then, we can identify measurable
tests which exercise them.  Then we can identify combinations of
those tests to model a `workload'.    We need to get this ball
rolling somehow.

btw, I told Rik I'd start on that definition today, but I'm having
trouble getting started.  Your insight would be muchly appreciated.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
