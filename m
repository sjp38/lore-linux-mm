Date: Fri, 31 Jan 2003 10:15:09 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch] GFP_ZONEMASK vs. MAX_NR_ZONES
Message-ID: <20030131101509.A18876@infradead.org>
References: <3E39DCE8.8050101@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E39DCE8.8050101@us.ibm.com>; from colpatch@us.ibm.com on Thu, Jan 30, 2003 at 06:18:16PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, "Martin J. Bligh" <mbligh@aracnet.com>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 30, 2003 at 06:18:16PM -0800, Matthew Dobson wrote:
> Whilst reading through some code for an unrelated patch the other day, I 
> stumbled across the build_zonelist* functions.  It seemed to me that the 
> bounds on the loop seemed too large.
> 
> There are only 3 memory zones: DMA (__GFP_DMA = 0x01), NORMAL, & HIGHMEM 
> (__GFP_DMA = 0x02).  Thus, GFP_ZONEMASK doesn't need to be 0x0f, but 
> only 0x03.  My guess this was to leave room for future zones?  In any 
> case, the loop in build_zonelists should almost certainly not go from 
> i=0..GFP_ZONEMASK.  This instantiates 13 zones that are never used, 
> because there is no case that I could find where any zonemask above 0x02 
> is used.  A zonemask of 0x03 would be DMA | HIGHMEM, but I could not 
> find an instance of that either, probably because it wouldn't make much 
> sense to request a chunk of memory from DMA & HIGHMEM.

Erich Focht added a hack to NEC's tree so he can represent different
nodes on their IA64 machines as memory zones and most 64it architectures
really only needs a single zone (ZONE_NORMAL), so it might be an interesting
option to make all this stuff per-arch..

> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
