Message-ID: <43E38C9A.7060103@jp.fujitsu.com>
Date: Sat, 04 Feb 2006 02:02:18 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] pearing off zone from physical memory layout [0/10]
References: <43E307DB.3000903@jp.fujitsu.com> <Pine.LNX.4.62.0602030842310.386@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0602030842310.386@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 3 Feb 2006, KAMEZAWA Hiroyuki wrote:
> 
>> By this, zone's meaning will be changed from "a range of memory to be used
>> in a same manner" to "a group of memory to be used in a same manner".
> 
> For us on IA64 a zone describes the memory of a node in a NUMA system. 
> This is due to our IA64 not having memory issues like restricted DMA 
> areas or not directly addressable memory.
> 
> That memory is to be used in the same manner. Yes. So in principle this 
> would also work for us. I'd like to have an option though to get rid of 
> all the extra zones if one has a clean memory architecture. We still carry 
> the DMA and HIGHMEM stuff around without purpose.
> 
Unfortunately, some of ia64 machines has DMA zone (for support 32bit bus < 4G mem).
But yes, HIGHMEM is not necessary.

> Would this also mean that one can dynamically add/remove memory to a zone 
> if the memory has to be treated the same way?
> 
Yes, I think so.  When support buddy-system, it can be done by MAX_ORDER size.
One of my purpose is to add memory to NORMAL if necessary.
(removing looks difficult ?)

Thanks,
-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
