Date: Mon, 18 Sep 2006 18:20:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918173134.d3850903.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609181815250.30365@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org> <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
 <20060918173134.d3850903.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Andrew Morton wrote:

> Which is pretty much the same thing.  I assume your objdump was of
> an unlinked .o file, so contig_page_data shows up as 0x0.

Correct.
 
> The code looks OK though.
> 
> It would be nice to be able to reclaim a few bits from page->flags - we're
> awfully short on them.  

With the zone reduction patchset we already have an additional bit. If you 
look at the i386 code it does an "and 1,ax". With the optional zone dma 
patch we will have an additional bit because then there are no zones 
anymore for SMP and UP. At that point page_zone() becomes a constant.

The node id is essential for NUMA locality and we cannot easily remove 
that from the page flags without additional lookups.

Configurations using DISCONTIG do not need the section bits that 
sparsemem requires. Sparsemem is tunable though. If you configure coarser 
granularity then more bits can be recovered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
