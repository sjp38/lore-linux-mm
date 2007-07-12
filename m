Date: Wed, 11 Jul 2007 17:07:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/12] Memoryless nodes: SLUB support
Message-Id: <20070711170736.f6c304d3.akpm@linux-foundation.org>
In-Reply-To: <20070711182251.433134748@sgi.com>
References: <20070711182219.234782227@sgi.com>
	<20070711182251.433134748@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007 11:22:26 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> Simply switch all for_each_online_node to for_each_memory_node. That way
> SLUB only operates on nodes with memory. Any allocation attempt on a
> memoryless node will fall whereupon SLUB will fetch memory from a nearby
> node (depending on how memory policies and cpuset describe fallback).
> 

This is as far as I got when a reject storm hit.

> -	for_each_online_node(node)
> +	for_each_node_state(node, N_MEMORY)
>  		__kmem_cache_shrink(s, get_node(s, node), scratch);

I can find no sign of any __kmem_cache_shrink's anywhere.

Let's park all this until post-merge-window please.  Generally, now is not
a good time for me to be merging 2.6.24 stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
