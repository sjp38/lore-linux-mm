Message-ID: <436BF7D3.1090200@yahoo.com.au>
Date: Sat, 05 Nov 2005 11:07:47 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051104201248.GA14201@elte.hu> <20051104210418.BC56F184739@thermo.lanl.gov> <e692861c0511041331ge5dd1abq57b6c513540fa200@mail.gmail.com> <200511042343.27832.ak@suse.de>
In-Reply-To: <200511042343.27832.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Gregory Maxwell <gmaxwell@gmail.com>, Andy Nelson <andy@thermo.lanl.gov>, mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Friday 04 November 2005 22:31, Gregory Maxwell wrote:
> 
>>
>>Thats the idea. The 'hugetlb zone' will only be usable for allocations
>>which are guaranteed reclaimable.  Reclaimable includes userspace
>>usage (since at worst an in use userspace page can be swapped out then
>>paged back into another physical location).
> 
> 
> I don't like it very much. You have two choices if a workload runs
> out of the kernel allocatable pages. Either you spill into the reclaimable
> zone or you fail the allocation. The first means that the huge pages
> thing is unreliable, the second would mean that all the many problems
> of limited lowmem would be back.
> 

These are essentially the same problems that the frag patches face as
well.

> None of this is very attractive.
> 

Though it is simple and I expect it should actually do a really good
job for the non-kernel-intensive HPC group, and the highly tuned
database group.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
