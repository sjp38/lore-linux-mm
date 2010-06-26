Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C89036B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 22:32:06 -0400 (EDT)
Date: Sat, 26 Jun 2010 12:32:00 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [S+Q 12/16] SLUB: Add SLAB style per cpu queueing
Message-ID: <20100626023200.GD29809@laptop>
References: <20100625212026.810557229@quilx.com>
 <20100625212108.124809375@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100625212108.124809375@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 04:20:38PM -0500, Christoph Lameter wrote:
> This patch adds SLAB style cpu queueing and uses a new way for
>  managing objects in the slabs using bitmaps. It uses a percpu queue so that
> free operations can be properly buffered and a bitmap for managing the
> free/allocated state in the slabs. It uses slightly more memory
> (due to the need to place large bitmaps --sized a few words--in some
> slab pages) but in general does compete well in terms of space use.
> The storage format using bitmaps avoids the SLAB management structure that
> SLAB needs for each slab page and therefore the metadata is more compact
> and easily fits into a cacheline.
> 
> The SLAB scheme of not touching the object during management is adopted.
> SLUB can now efficiently free and allocate cache cold objects.

BTW. this was never the problem with SLUB, because SLQB didn't have
the big performance regression on tpcc. SLUB IIRC had to touch more
cachelines per operation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
