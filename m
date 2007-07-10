Date: Tue, 10 Jul 2007 18:54:49 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: zone movable patches comments
In-Reply-To: <46934F9C.9060201@shadowen.org>
References: <46933BD7.2020200@yahoo.com.au> <46934F9C.9060201@shadowen.org>
Message-Id: <20070710182944.83D7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@skynet.ie>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> > No I really don't see why kernelcore=toosmall is any better than
> > movable_mem=toobig. And why do you think the admin knows how much
> > memory is enough to run the kernel, or why should that be the same
> > between different sized machines? If you have a huge machine, you
> > need much more addressable kernel memory for the mem_map array
> > before you even think about anything else.
> > 
> > Actually, it is more likely that the admin knows exactly how much
> > memory they need to reserve (eg. for their database's shared
> > memory segment or to hot unplug or whatever), and in that case
> > it is much better to be able to specify movable_mem= and just be
> > given exactly what you asked for and the kernel can be given the
> > rest.

If hot-unplug is invoked after bootup, then movable_mem will be
useful to specify removable memory size. It is true.

However, if hot-add is invoked at first after bootup, 
movable_mem is not so useful.
I think admin expects hot-add memory will be removable zone in many
case, because he wish the memory for his application rather than
for kernel.
But, movable mem can't specify size of hot-add memory in the future.
I suppose "kernelcore" is desirable for its case.


> > If somebody is playing with this parameter, they definitely know
> > what they are doing and they are not just blindly throwing it out
> > over their cluster because it might be a good idea.
> 
> It feels very much that there are two usage models.  Those who know how
> much "kernel" memory works for them and want whatever is left usable for
> their small/huge page workloads, and those who know how much they need
> for their DB and are happy for the system to have the rest.  Both seem
> like valid use cases, both would have the same underlying implementation
> a sized ZONE_MOVABLE.
> 
> How about we have two kernel options "kernelcore=" and "movable=" which
> would both size ZONE_MOVABLE.  Both would be the minimum sizes, so the
> effective differences would be the rounding to whole pageblocks.

I would like to vote it due to above mentioned. :-)

Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
