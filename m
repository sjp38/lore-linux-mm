Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9FMhDNX070384
	for <linux-mm@kvack.org>; Fri, 15 Oct 2004 18:43:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9FMhCOX159148
	for <linux-mm@kvack.org>; Fri, 15 Oct 2004 16:43:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9FMhCti013799
	for <linux-mm@kvack.org>; Fri, 15 Oct 2004 16:43:12 -0600
Subject: Re: [PATCH] reduce fragmentation due to kmem_cache_alloc_node
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1097863727.2861.43.camel@dyn318077bld.beaverton.ibm.com>
References: <41684BF3.5070108@colorfullife.com>
	 <1097863727.2861.43.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain
Message-Id: <1097879593.2861.61.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 15 Oct 2004 15:33:14 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-10-15 at 11:08, Badari Pulavarty wrote:

> 
> I see size-64 "inuse" objects increasing. Eventually, it fills
> up entire low-mem. I guess while freeing up scsi-debug disks,
> is not cleaning up all the allocations :(
> 
> But one question I have is - Is it possible to hold size-64 slab,
> because it has a management allocation (slabp - 40 byte allocations)
> from alloc_slabmgmt() ?  I remember seeing this earlier. Is it worth
> moving all managment allocations to its own slab ? should I try it ?

Nope. Moving "slabp" allocations to its own slab, didn't fix anything.
I guess scsi-debug is not cleaning up properly :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
