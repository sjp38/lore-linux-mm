Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l25GjUvU017025
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 11:45:30 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l25GjUEx303528
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 11:45:30 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l25GjTt5005638
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 11:45:30 -0500
Message-ID: <45EC4924.2050104@austin.ibm.com>
Date: Mon, 05 Mar 2007 10:45:24 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E8594B.6020904@austin.ibm.com> <20070305032116.GA29678@wotan.suse.de> <45EC352A.7060802@austin.ibm.com> <20070305160143.GB8128@wotan.suse.de>
In-Reply-To: <20070305160143.GB8128@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> If you only need to allocate 1 page size and smaller allocations then no 
>> it's not a problem.  As soon as you go above that it will be.  You don't 
>> need to go all the way up to MAX_ORDER size to see an impact, it's just 
>> increasingly more severe as you get away from 1 page and towards MAX_ORDER.
> 
> We allocate order 1 and 2 pages for stuff without too much problem.

The question I want to know is where do you draw the line as to what is acceptable to 
allocate in a single contiguous block?

1 page?  8 pages?  256 pages?  4K pages?  Obviously 1 page works fine. With 4K page 
size and 16MB MAX_ORDER 4K pages is theoretically supported, but doesn't work under 
almost any circumstances (unless you use Mel's patches).

> on-demand hugepages could be done better anyway by having the hypervisor
> defrag physical memory and provide some way for the guest to ask for a
> hugepage, no?

Unless you break the 1:1 virt-phys mapping it doesn't matter if the hypervisor can 
defrag this for you as the kernel will have the physical address cached away 
somewhere and expect the data not to move.

I'm a big fan of making this somebody else's problem and the hypervisor would be a 
good place.  I just can't figure out how to actually do it at that layer without 
changing Linux in a way that is unacceptable to the community at large.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
