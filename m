Date: Sun, 23 Nov 2003 14:40:52 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Simplify node/zone portion of page->flags
Message-Id: <20031123144052.1f0d5071.akpm@osdl.org>
In-Reply-To: <3FBEB867.9080506@us.ibm.com>
References: <3FBEB867.9080506@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@aracnet.com, jbarnes@sgi.com
List-ID: <linux-mm.kvack.org>

Matthew Dobson <colpatch@us.ibm.com> wrote:
>
> Currently we keep track of a pages node & zone in the top 8 bits (on 
>  32-bit arches, 10 bits on 64-bit arches) of page->flags.  We typically 
>  do: node_num * MAX_NR_ZONES + zone_num = 'nodezone'.  It's non-trivial 
>  to break this 'nodezone' back into node and zone numbers.  This patch 
>  modifies the way we compute the index to be: (node_num << ZONE_SHIFT) | 
>  zone_num.  This makes it trivial to recover either the node or zone 
>  number with a simple bitshift.  There are many places in the kernel 
>  where we do things like: page_zone(page)->zone_pgdat->node_id to 
>  determine the node a page belongs to.  With this patch we save several 
>  pointer dereferences, and it boils down to shifting some bits.

This rather conflicts with the patch from Jesse which I have.  Can you guys
work that out and let me know when you're done?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
