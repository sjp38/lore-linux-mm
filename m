Message-Id: <200410052218.i95MI3630436@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: slab fragmentation ?
Date: Tue, 5 Oct 2004 15:18:11 -0700
In-Reply-To: <200410052211.i95MBU630399@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Badari Pulavarty' <pbadari@us.ibm.com>, Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote on Tuesday, October 05, 2004 2:14 PM
> > >>The fix would be simple: kmem_cache_alloc_node must walk through the
> > >>list of partial slabs and check if it finds a slab from the correct
> > >>node. If it does, then just use that slab instead of allocating a new
> > >>one.
>
> I don't see how to find out which slab came from which node. I don't
> think we save "nodeid" anywhere in the slab. Do we ?

Chen, Kenneth W wrote on Tuesday, October 05, 2004 3:12 PM
> If you have a pointer to the slab page, then you can traverse through
> pgdat of each zone: page_zone(page)->zone_pgdat->node_id.

Actually, better yet there is one nice inline function does that already:
page_to_nid().

- Ken


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
