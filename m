Message-ID: <40214A11.3060007@techsource.com>
Date: Wed, 04 Feb 2004 14:37:53 -0500
From: Timothy Miller <miller@techsource.com>
MIME-Version: 1.0
Subject: Re: Active Memory Defragmentation: Our implementation & problems
References: <20040204185446.91810.qmail@web9705.mail.yahoo.com> <Pine.LNX.4.53.0402041402310.2722@chaos>
In-Reply-To: <Pine.LNX.4.53.0402041402310.2722@chaos>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: Alok Mooley <rangdi@yahoo.com>, Dave Hansen <haveblue@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Richard B. Johnson wrote:

> If this is an Intel x86 machine, it is impossible for pages
> to get fragmented in the first place. The hardware allows any
> page, from anywhere in memory, to be concatenated into linear
> virtual address space. Even the kernel address space is virtual.
> The only time you need physically-adjacent pages is if you
> are doing DMA that is more than a page-length at a time. The
> kernel keeps a bunch of those pages around for just that
> purpose.
> 
> So, if you are making a "memory defragmenter", it is a CPU time-sink.
> That's all.

Would memory fragmentation have any appreciable impact on L2 cache line 
collisions?

Would defragmenting it help?

In the case of the Opteron, there is a 1M cache that is (I forget) N-way 
set associative, and it's physically indexed.  If a bunch of pages were 
located such that there were a disproportionately large number of lines 
which hit the same tag, you could be thrashing the cache.

There are two ways to deal with this:  (1) intelligently locates pages 
in physical memory; (2) hope that natural entropy keeps things random 
enough that it doesn't matter.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
