Subject: Re: slab fragmentation ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <4162ECAD.8090403@colorfullife.com>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>
	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>
	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
	 <415F968B.8000403@colorfullife.com>
	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>
	 <41617567.9010507@colorfullife.com>
	 <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
	 <4162E0AF.4000704@colorfullife.com>
	 <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>
	 <4162ECAD.8090403@colorfullife.com>
Content-Type: text/plain
Message-Id: <1097010817.12861.164.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 05 Oct 2004 14:13:37 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-05 at 11:49, Manfred Spraul wrote:
> Badari Pulavarty wrote:
> 
> >>The fix would be simple: kmem_cache_alloc_node must walk through the 
> >>list of partial slabs and check if it finds a slab from the correct 
> >>node. If it does, then just use that slab instead of allocating a new 
> >>one. 

I don't see how to find out which slab came from which node. I don't
think we save "nodeid" anywhere in the slab. Do we ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
