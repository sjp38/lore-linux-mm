Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A7F26B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 06:22:35 -0400 (EDT)
Date: Mon, 28 Jun 2010 05:19:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 12/16] SLUB: Add SLAB style per cpu queueing
In-Reply-To: <20100626023200.GD29809@laptop>
Message-ID: <alpine.DEB.2.00.1006280513050.8725@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212108.124809375@quilx.com> <20100626023200.GD29809@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, Nick Piggin wrote:

> > The SLAB scheme of not touching the object during management is adopted.
> > SLUB can now efficiently free and allocate cache cold objects.
>
> BTW. this was never the problem with SLUB, because SLQB didn't have
> the big performance regression on tpcc. SLUB IIRC had to touch more
> cachelines per operation.

Wish you were more detailed here. SLUB was designed for minimal cacheline
footprint and always had an edge there. AFACT SLQB was able to address
tpcc in some ways was because the issue with the hotpath on free was
addressed. These were issues with atomic ops on free not cache footprint.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
