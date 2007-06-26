Date: Tue, 26 Jun 2007 12:19:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
In-Reply-To: <29495f1d0706261213w73b7cbe0weabdcb2b03a9b880@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706261217250.20282@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>  <20070618095916.297690463@sgi.com>
 <29495f1d0706261213w73b7cbe0weabdcb2b03a9b880@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Nish Aravamudan wrote:

> >    kmem_cache_defrag takes a node parameter. This can either be -1 if
> >    defragmentation should be performed on all nodes, or a node number.
> >    If a node number was specified then defragmentation is only performed
> >    on a specific node.
> 
> Hrm, isn't -1 usually 'this node' for NUMA systems? Maybe nr_node_ids
> or MAX_NUMNODES should mean 'all nodes'?

-1 means no node specified. What the function does in this case depends
on the function. For "this node" you can use numa_node_id().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
