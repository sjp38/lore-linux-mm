Message-ID: <43CDB567.2080305@jp.fujitsu.com>
Date: Wed, 18 Jan 2006 12:26:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Question:  new bind_zonelist uses only one zone type
References: <43CCAEEF.5000403@jp.fujitsu.com> <200601171529.53811.ak@suse.de> <43CD822C.6020105@jp.fujitsu.com> <200601180400.41448.ak@suse.de>
In-Reply-To: <200601180400.41448.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On IA64/SN2 ZONE_DMA is empty and at least in the part SGI was the only
> IA64 vendor actively interested in NUMA policy.
> 
> I assume you have a NUMA platform too. Do your machines have a contiguous
> memory map where there could be one or more nodes which only
> have ZONE_DMA?
> 

Fujitsu's PrimeQuest is NUMA and has memory in 0-4G areas in node 0.
It depends on installed memory whether node 0 contains only ZONE_DMA or not.

When using SPARSEMEM, it uses NUMA config. This means one-node-NUMA.
So, if I use SPARSEMEM on ia64 SMP machine with 5 Gbytes mem,
I can allocate just 1G bytes on mbind area.
(*)Maybe using mempolicy on one-node-NUMA make no sense.


>>> It is on my todo list to fix, but I haven't gotten around to it yet.
>>>
>>> Fixing it will unfortunately increase the footprint of the policy
>>> structures, so likely it would only increase to two. If someone beats me
>>> to a patch that would be ok too.
>> I don't have real problem now. It just looks curious.
> 
> Well it's a bit nasty to not be able to policy 4GB of your memory. Maybe
> if you have a few TB of it you won't care, but on smaller machines
> it likely will make a difference.
> 
It makes difference on my *numa emulation* environment, now ;)
But it's just emulation.

-- Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
