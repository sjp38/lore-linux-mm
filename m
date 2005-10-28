Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9SGJHJE014261
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:19:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9SGKHEf531782
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 10:20:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9SGJGGF008608
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 10:19:17 -0600
Message-ID: <43624F82.6080003@us.ibm.com>
Date: Fri, 28 Oct 2005 09:19:14 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org>
In-Reply-To: <20051028034616.GA14511@ccure.user-mode-linux.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Jeff Dike wrote:

> On Wed, Oct 26, 2005 at 03:49:55PM -0700, Badari Pulavarty wrote:
> 
>>Basically, I added "truncate_range" inode operation to provide
>>opportunity for the filesystem to zero the blocks and/or free
>>them up. 
>>
>>I also attempted to implement shmem_truncate_range() which 
>>needs lots of testing before I work out bugs :(
> 
> 
> I added memory hotplug to UML to check this out.  It seems to be freeing
> pages that are outside the desired range.  I'm doing the simplest possible
> thing - grabbing a bunch of pages that are most likely not dirty yet, 
> and MADV_TRUNCATEing them one at a time.  Everything in UML goes harwire
> after that, and the cases that I've looked at involve pages being suddenly
> zero.
> 
> UML isn't exactly a minimal test case, but I'll give you what you need
> to reproduce this if you want.
> 

I cut-n-pasted shmem_truncate_range() from shmem_truncate() and fixed
few obvious things. Its very likely that, I missed whole bunch of changes.

My touch tests so far, doesn't really verify data after freeing. I was
thinking about writing cases. If I can use UML to do it, please send it
to me. I would rather test with real world case :)

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
