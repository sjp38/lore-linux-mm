From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17036.42124.398130.730456@gargle.gargle.HOWL>
Date: Thu, 19 May 2005 18:37:00 +0400
Subject: Re: page flags ?
In-Reply-To: <20050519041116.1e3a6d29.akpm@osdl.org>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	<20050518145644.717afc21.akpm@osdl.org>
	<1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	<20050518162302.13a13356.akpm@osdl.org>
	<428C6FB9.4060602@shadowen.org>
	<20050519041116.1e3a6d29.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pbadari@us.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Andy Whitcroft <apw@shadowen.org> wrote:
 > >
 > >  > How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.
 > > 
 > >  The short answer is that on 32 bit architectures there are 24 bits
 > >  allocated to general page flags, page-flags.h indicates that 21 are
 > >  currently assigned so assuming it is accurate there are currently 3 bits
 > >  free.
 > 
 > Yipes, I didn't realise we were that close.
 > 
 > We can reclaim PG_highmem, use page_zone(page)->highmem
 > 
 > We can probably reclaim PG_slab
 > 
 > We can conceivably reclaim PG_swapcache, although that stuff got ugly.
 > 
 > Would dearly love to nuke PG_reserved, but everybody's scared of that ;)
 > 
 > PG_uncached is currently ia64-only and could conceivably be moved to bit
 > 32, except there are rumours that arm might want to use it someday.
 > 
 > It's a bit irritating that swsusp uses two flags.
 > 
 > I don't see any other low-hanging fruit there.

Things like PG_uptodate and PG_error can be moved to the radix-tree tags
after checking that they are used only for pages in the mapping, which
seems to be the case.

 > --

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
