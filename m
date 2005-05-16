Date: Mon, 16 May 2005 09:47:08 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: NUMA aware slab allocator V3
In-Reply-To: <1116251568.1005.29.camel@localhost>
Message-ID: <Pine.LNX.4.62.0505160943140.1330@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
 <20050512000444.641f44a9.akpm@osdl.org>  <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
  <20050513000648.7d341710.akpm@osdl.org>  <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
  <20050513043311.7961e694.akpm@osdl.org>  <Pine.LNX.4.62.0505131823210.12315@schroedinger.engr.sgi.com>
 <1116251568.1005.29.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 16 May 2005, Dave Hansen wrote:

> There are some broken assumptions in the kernel that
> CONFIG_DISCONTIG==CONFIG_NUMA.  These usually manifest when code assumes
> that one pg_data_t means one NUMA node.
> 
> However, NUMA node ids are actually distinct from "discontigmem nodes".
> A "discontigmem node" is just one physically contiguous area of memory,
> thus one pg_data_t.  Some (non-NUMA) Mac G5's have a gap in their
> address space, so they get two discontigmem nodes.

I thought the discontigous memory in one node was handled through zones? 
I.e. ZONE_HIGHMEM in i386?

> So, that #error is bogus.  It's perfectly valid to have multiple
> discontigmem nodes, when the number of NUMA nodes is 1.  MAX_NUMNODES
> refers to discontigmem nodes, not NUMA nodes.

Ok. We looked through the code and saw that the check may be removed 
without causing problems. However, there is still a feeling of uneasiness 
about this.

To what node does numa_node_id() refer? And it is legit to use 
numa_node_id() to index cpu maps and stuff? How do the concepts of numa 
node id relate to discontig node ids?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
