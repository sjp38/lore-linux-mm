Message-ID: <43D127A3.1010200@jp.fujitsu.com>
Date: Sat, 21 Jan 2006 03:10:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 0/5] Reducing fragmentation using zones
References: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie> <43CFE77B.3090708@austin.ibm.com> <43D02B3E.5030603@jp.fujitsu.com> <Pine.LNX.4.58.0601200102040.15823@skynet> <43D03C24.5080409@jp.fujitsu.com> <Pine.LNX.4.58.0601200934300.10920@skynet> <43D0BE27.5000807@jp.fujitsu.com> <Pine.LNX.4.58.0601201204100.14292@skynet>
In-Reply-To: <Pine.LNX.4.58.0601201204100.14292@skynet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Joel Schopp <jschopp@austin.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Fri, 20 Jan 2006, KAMEZAWA Hiroyuki wrote:
>>1. Using 1000+ processes(threads) at once
> 
> 
> Would tiobench --threads be suitable or would the IO skew what you are
> looking for? If the IO is a problem, what would you recommend instead?
> 
What I'm looking for is slab usage coming with threads/procs.

> 
>>2. heavy network load.
> 
> 
> Would iperf be suitable?
> 
maybe
> 
>>3. running NFS
> 
> 
> Is running a kernel build over NFS reasonable? Should it be a remote NFS
> server or could I setup a NFS share and mount it locally? If a kernel
> build is not suitable, would tiobench over NFS be a better plan?
> 
I considered doing kernel build on  NFS which is mounted localy.


> The scenario people really care about (someone correct me if I'm wrong
> here) for hot-remove is giving virtual machines more or less memory as
> demand requires. In this case, the "big"  area of memory required is the
> same size as a sparsemem section - 16MiB on the ppc64 and 64MiB on the x86
> (I think). Also, for hot-remove, it does not really matter where in the
> zone the chunk is, as long as it is free. For ppc64, 16MiB of contiguous
> memory is reasonably easy to get with the list-based approach and the case
> would likely be the same for x86 if the value of MAX_ORDER was increased.
> 
What I' want is just node-hotplug on NUMA, removing physical range of mem.
So I'll need and push dividing memory into removable zones or pgdat, anyway.
For people who just want resizing, what you say is main reason for hotplug.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
