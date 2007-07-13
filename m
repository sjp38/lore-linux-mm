Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DNIJUt017249
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 19:18:19 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6DNIJGi450642
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 19:18:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DNIIkj010690
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 19:18:18 -0400
Date: Fri, 13 Jul 2007 16:18:17 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
Message-ID: <20070713231817.GB31518@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070713151431.GG10067@us.ibm.com> <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com> <1184347239.5579.3.camel@localhost> <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com> <1184360032.5579.17.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184360032.5579.17.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 13.07.2007 [16:53:52 -0400], Lee Schermerhorn wrote:
> Christoph:
> 
> Had a chance to build/boot the latest series with the updated #7, ...
> 
> Quite a few offsets and one reject in #7, but easy to resolve.
> 
> Boots OK.  Quick test of hugetlb allocation on my platform shows the
> old behavior with huge pages doubling up on the node that the
> "memoryless" one falls back on.  Guess this is expected until we get
> Nish's patch atop this one.

Yep, I've tested his stack as well (just got some results and it seems
ok).

> Next week I'll reconfig a platform fully interleaved which will result
> in all of the real nodes appearing memoryless and do more testing.
> 
> Have a nice vacation.
> 
> Nish:
> 
> Shall I try to rebase your patches atop Christoph's in my tree?

I've got all three of my patches rebased. I'll repost them shortly, am
just trying to verify they still work as expected on NUMA, NUMA w/
memoryless and non-NUMA, as before.

Thanks,
Nish

> The last ones I have are from 19jul:
> 
> 	01-fix-hugetlb-pool-allocation-with-memoryless-nodes

FWIW, you just need to

sed -i 's/node_memory_map/node_states(N_MEMORY)/g' mm/hugetlb.c

for this patch and

> 	02-hugetlb-numafy-several-functions
> 	03-add-per-node-nr_hugepages-sysfs-attribute

these two apply cleanly. Everything should build at that point, as well.

> Do you have more recent ones?

I'll make sure you're on the Cc once I repost.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
