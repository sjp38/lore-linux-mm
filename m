Date: Tue, 15 May 2007 11:19:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/8] Do not depend on MAX_ORDER when grouping pages by
 mobility
In-Reply-To: <20070515150331.16348.18072.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705151118340.31972@schroedinger.engr.sgi.com>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150331.16348.18072.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Mel Gorman wrote:

>  
>  #define SECTION_BLOCKFLAGS_BITS \
> -		((1 << (PFN_SECTION_SHIFT - (MAX_ORDER-1))) * NR_PAGEBLOCK_BITS)
> +	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
>  

Ahh, Blockflags so this is not related to SPARSEMEM... 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
