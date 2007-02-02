Date: Fri, 2 Feb 2007 11:13:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: reduce size of alien cache to cover only possible nodes
In-Reply-To: <20070201235518.6c901bbf.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702021113080.20232@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702012343020.17885@schroedinger.engr.sgi.com>
 <20070201235518.6c901bbf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2007, Andrew Morton wrote:

> > The initialization of nr_node_ids occurred too late relative to the bootstrap
> > of the slab allocator and so I moved the setup_nr_node_ids() into
> > free_area_init_nodes().
> 
> How does/will this play with node hotplug?  Not at all, afaict.

Plays well. You cannot plug in node that is not in the node possible map 
and we use the node possible map for nr_node_id calculation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
