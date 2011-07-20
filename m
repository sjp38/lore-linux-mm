Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0E97A6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:09:42 -0400 (EDT)
Date: Wed, 20 Jul 2011 20:09:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
Message-ID: <20110720190933.GN5349@suse.de>
References: <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107201033080.1472@router.home>
 <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107201114480.1472@router.home>
 <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1311181463.2338.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107201212140.1472@router.home>
 <alpine.DEB.2.00.1107202028050.2847@tiger>
 <alpine.DEB.2.00.1107201237190.1472@router.home>
 <alpine.DEB.2.00.1107202040240.2847@tiger>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107202040240.2847@tiger>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, Jul 20, 2011 at 08:41:12PM +0300, Pekka Enberg wrote:
> On Wed, 20 Jul 2011, Pekka Enberg wrote:
> >>On Wed, 20 Jul 2011, Eric Dumazet wrote:
> >>>>[PATCH v2] slab: shrinks sizeof(struct kmem_cache)
> >>
> >>On Wed, 20 Jul 2011, Christoph Lameter wrote:
> >>>This will solve the issue for small nr_cpu_ids but those with 4k cpus will
> >>>still have the issue.
> >>>
> >>>Acked-by: Christoph Lameter <cl@linux.com>
> >>
> >>Applied, thanks! Do we still want the __GFP_REPEAT patch from Konstantin
> >>though?
> 
> On Wed, 20 Jul 2011, Christoph Lameter wrote:
> >Those with 4k cpus will be thankful I guess.
> 
> OTOH, I'm slightly worried that it might mask a real problem with
> GFP_KERNEL not being aggressive enough. Mel?
> 

The reproduction case was while memory was under heavy pressure
(swapout was active) and even then only 1 in a 1000 containers were
failing to create due to an order-4 allocation failure. I'm not
convinced we need to increase how aggressive the allocator is for
PAGE_ALLOC_COSTLY_ORDER in general based on this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
