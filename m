Subject: Re: [patch 07/10] Memoryless nodes: SLUB support
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070618192545.764710140@sgi.com>
References: <20070618191956.411091458@sgi.com>
	 <20070618192545.764710140@sgi.com>
Content-Type: text/plain
Date: Wed, 20 Jun 2007 10:10:11 -0400
Message-Id: <1182348612.5058.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-18 at 12:20 -0700, clameter@sgi.com wrote:
> plain text document attachment (memless_slub)
> Simply switch all for_each_online_node to for_each_memory_node. That way
> SLUB only operates on nodes with memory. Any allocation attempt on a
> memoryless node will fall whereupon SLUB will fetch memory from a nearby
> node (depending on how memory policies and cpuset describe fallback).
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.22-rc4-mm2/mm/slub.c
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-18 11:16:15.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-18 11:28:50.000000000 -0700

<snip>

Christoph:

This patch didn't apply to 22-rc4-mm2.  Does it assume some other SLUB
patches?

I resolved the conflicts by just doing what the description says:
replacing all 'for_each_online_node" with "for_each_memory_node", but I
was surprised that this one patch out of 10 didn't apply.  I'm probably
missing some other patch.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
