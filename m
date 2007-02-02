Date: Thu, 1 Feb 2007 23:55:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab: reduce size of alien cache to cover only possible nodes
Message-Id: <20070201235518.6c901bbf.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702012343020.17885@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702012343020.17885@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2007 23:45:44 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> The alien cache is a per cpu per node array allocated for every slab
> on the system. Currently we size this array for all nodes
> that the kernel does support. For IA64 this is 1024 nodes. So we allocate
> an array with 1024 objects even if we only boot a system with 4 nodes.
> 
> This patch uses "nr_node_ids" to determine the number of possible nodes 
> supported by a hardware configuration and only allocates an alien cache 
> sized for possible nodes.
> 
> The initialization of nr_node_ids occurred too late relative to the bootstrap
> of the slab allocator and so I moved the setup_nr_node_ids() into
> free_area_init_nodes().

How does/will this play with node hotplug?  Not at all, afaict.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
