Message-ID: <3D5D6CFF.9153184D@zip.com.au>
Date: Fri, 16 Aug 2002 14:22:07 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: clean up mem_map usage ... part 1
References: <2441610000.1029530734@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> This simply converts direct usage of mem_map to the correct macros
> (mem_map doesn't work like this for discontigmem). It also fixes a bug
> in bad_range, that happens to work for contig mem systems, but is
> incorrect. Tested both with and without discontigmem support.
> 

Looks good, thanks.  I'll nail an unneeded typecast in there.

My queue runneth over at present, and the kmap patches need to
percolate forwards soon (once they're agreeably written).  I'm
planning on sending per-zone-lru next, then discontigmem (again)
then kmap.  Probably kmap needs to come earlier..

I won't send the rmap locking hacklets until we've nailed that
BUG in __free_pages_ok.

Does pci_map_page() work on discontigmem?

What _is_ zone_start_mapnr?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
