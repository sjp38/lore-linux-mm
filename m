Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id ADF326B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:40:45 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i1so863456oag.34
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:40:45 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 23 Sep 2013 13:20:24 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 429B138C803B
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:20:22 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8NHKMn462390386
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 17:20:22 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8NHJLnx003172
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:19:21 -0400
Date: Mon, 23 Sep 2013 12:19:16 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20130923171916.GA23643@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5237FDCC.5010109@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Tue, Sep 17, 2013 at 02:59:24PM +0800, Bob Liu wrote:
> Hi Krzysztof,
> 
> On 09/11/2013 04:58 PM, Krzysztof Kozlowski wrote:
> > Hi,
> > 
> > Currently zbud pages are not movable and they cannot be allocated from CMA
> > (Contiguous Memory Allocator) region. These patches add migration of zbud pages.
> > 
> 
> I agree that the migration of zbud pages is important so that system
> will not enter order-0 page fragmentation and can be helpful for page
> compaction/huge pages etc..
> 
> But after I looked at the [patch 4/5], I found it will make zbud very
> complicated.
> I'd prefer to add this migration feature later until current version
> zswap/zbud becomes better enough and more stable.

I agree with this.  We are also looking to add zsmalloc as an option too.  It
would be nice to come up with a solution that worked for both (any) allocator
that zswap used.

> 
> Mel mentioned several problems about zswap/zbud in thread "[PATCH v6
> 0/5] zram/zsmalloc promotion".
> 
> Like "it's clunky as hell and the layering between zswap and zbud is
> twisty" and "I think I brought up its stalling behaviour during review
> when it was being merged. It would have been preferable if writeback
> could be initiated in batches and then waited on at the very least..
>  It's worse that it uses _swap_writepage directly instead of going
> through a writepage ops.  It would have been better if zbud pages
> existed on the LRU and written back with an address space ops and
> properly handled asynchonous writeback."

Yes, the laying in zswap vs zbud is wonky and should be addressed before adding
new layers.

> 
> So I think it would be better if we can address those issues at first
> and it would be easier to address these issues before adding more new
> features. Welcome any ideas.

Agreed.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
