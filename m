Received: by ug-out-1314.google.com with SMTP id m2so177478uge
        for <linux-mm@kvack.org>; Tue, 26 Jun 2007 12:20:48 -0700 (PDT)
Message-ID: <29495f1d0706261213w73b7cbe0weabdcb2b03a9b880@mail.gmail.com>
Date: Tue, 26 Jun 2007 12:13:57 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
In-Reply-To: <20070618095916.297690463@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095916.297690463@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> Slab defragmentation occurs either
>
> 1. Unconditionally when kmem_cache_shrink is called on slab by the kernel
>    calling kmem_cache_shrink or slabinfo triggering slab shrinking. This
>    form performs defragmentation on all nodes of a NUMA system.
>
> 2. Conditionally when kmem_cache_defrag(<percentage>, <node>) is called.
>
>    The defragmentation is only performed if the fragmentation of the slab
>    is higher then the specified percentage. Fragmentation ratios are measured
>    by calculating the percentage of objects in use compared to the total
>    number of objects that the slab cache could hold.
>
>    kmem_cache_defrag takes a node parameter. This can either be -1 if
>    defragmentation should be performed on all nodes, or a node number.
>    If a node number was specified then defragmentation is only performed
>    on a specific node.

Hrm, isn't -1 usually 'this node' for NUMA systems? Maybe nr_node_ids
or MAX_NUMNODES should mean 'all nodes'?

Perhaps these would be served with some #defines?

#define NUMA_THISNODE_ID (-1)
#define NUMA_ALLNODES_ID (MAX_NUMNODES)

or something?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
