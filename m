Date: Fri, 25 Mar 2005 10:38:04 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] remove non-DISCONTIG use of pgdat->node_mem_map
Message-ID: <22520000.1111775883@[10.10.2.4]>
In-Reply-To: <E1DEsgS-0002zz-00@kernel.beaverton.ibm.com>
References: <E1DEsgS-0002zz-00@kernel.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

> This patch effectively eliminates direct use of pgdat->node_mem_map
> outside of the DISCONTIG code.  On a flat memory system, these fields
> aren't currently used, neither are they on a sparsemem system.
> 
> There was also a node_mem_map(nid) macro on many architectures. Its
> use along with the use of ->node_mem_map itself was not consistent.
> It has been removed in favor of two new, more explicit,
> arch-independent macros:
> 
> 	pgdat_page_nr(pgdat, pagenr)
> 	nid_page_nr(nid, pagenr)
> 
> I called them "pgdat" and "nid" because we overload the term "node"
> to mean "NUMA node", "DISCONTIG node" or "pg_data_t" in very
> confusing ways.  I believe the newer names are much clearer.

Seems like a good plan - the abstraction will make it easier to change the
underlying mechanism. I'm not desperately keen on the new naming, but
given the current code state it makes sense, I guess. Once Andy has got
sparsemem merged up, and we change struct pgdat to be called struct node
or something more sensible, we can revisit it then.

Signed-off-by: Martin J. Bligh <mbligh@aracnet.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
