Date: Sun, 23 Nov 2003 14:49:03 -0800
Subject: Re: [RFC] Simplify node/zone portion of page->flags
Message-ID: <20031123224903.GB21617@sgi.com>
References: <3FBEB867.9080506@us.ibm.com> <20031123144052.1f0d5071.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031123144052.1f0d5071.akpm@osdl.org>
From: jbarnes@sgi.com (Jesse Barnes)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: colpatch@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

On Sun, Nov 23, 2003 at 02:40:52PM -0800, Andrew Morton wrote:
> >  zone_num.  This makes it trivial to recover either the node or zone 
> >  number with a simple bitshift.  There are many places in the kernel 
> >  where we do things like: page_zone(page)->zone_pgdat->node_id to 
> >  determine the node a page belongs to.  With this patch we save several 
> >  pointer dereferences, and it boils down to shifting some bits.
> 
> This rather conflicts with the patch from Jesse which I have.  Can you guys
> work that out and let me know when you're done?

I like Matt's patch, but haven't tested it yet.  I'll try it out on
Monday.

Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
