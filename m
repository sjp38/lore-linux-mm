Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE1646B0069
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 01:21:00 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id g33so26061221plb.13
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 22:21:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y20si26332133pgv.291.2017.12.29.22.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Dec 2017 22:20:59 -0800 (PST)
Date: Fri, 29 Dec 2017 22:20:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 2/8] slub: Add defrag_ratio field and sysfs support
Message-ID: <20171230062052.GB27959@bombadil.infradead.org>
References: <20171227220636.361857279@linux.com>
 <20171227220652.322991754@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227220652.322991754@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Wed, Dec 27, 2017 at 04:06:38PM -0600, Christoph Lameter wrote:
> +++ linux/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -180,6 +180,19 @@ Description:
>  		list.  It can be written to clear the current count.
>  		Available when CONFIG_SLUB_STATS is enabled.
>  
> +What:		/sys/kernel/slab/cache/defrag_ratio
> +Date:		December 2017
> +KernelVersion:	4.16
> +Contact:	Christoph Lameter <cl@linux-foundation.org>
> +		Pekka Enberg <penberg@cs.helsinki.fi>,
> +Description:
> +		The defrag_ratio files allows the control of how agressive
> +		slab fragmentation reduction works at reclaiming objects from
> +		sparsely populated slabs. This is a percentage. If a slab
> +		has more than this percentage of available object then reclaim
> +		will attempt to reclaim objects so that the whole slab
> +		page can be freed. The default is 30%.
> +
>  What:		/sys/kernel/slab/cache/deactivate_to_tail
>  Date:		February 2008
>  KernelVersion:	2.6.25

Should this documentation mention it's SLUB-only?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
