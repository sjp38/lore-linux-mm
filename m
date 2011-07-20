Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 05BDA6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 14:07:20 -0400 (EDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.1107202040240.2847@tiger>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
	 <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201033080.1472@router.home>
	 <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201114480.1472@router.home>
	 <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311181463.2338.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201212140.1472@router.home>
	 <alpine.DEB.2.00.1107202028050.2847@tiger>
	 <alpine.DEB.2.00.1107201237190.1472@router.home>
	 <alpine.DEB.2.00.1107202040240.2847@tiger>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 13:07:04 -0500
Message-ID: <1311185224.14555.43.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2011-07-20 at 20:41 +0300, Pekka Enberg wrote:
> On Wed, 20 Jul 2011, Pekka Enberg wrote:
> >> On Wed, 20 Jul 2011, Eric Dumazet wrote:
> >>>> [PATCH v2] slab: shrinks sizeof(struct kmem_cache)
> >>
> >> On Wed, 20 Jul 2011, Christoph Lameter wrote:
> >>> This will solve the issue for small nr_cpu_ids but those with 4k cpus will
> >>> still have the issue.
> >>>
> >>> Acked-by: Christoph Lameter <cl@linux.com>
> >>
> >> Applied, thanks! Do we still want the __GFP_REPEAT patch from Konstantin
> >> though?
> 
> On Wed, 20 Jul 2011, Christoph Lameter wrote:
> > Those with 4k cpus will be thankful I guess.
> 
> OTOH, I'm slightly worried that it might mask a real problem 
> with GFP_KERNEL not being aggressive enough. Mel?

I think that's already been demonstrated here, yes. It's just waiting
for another obscure workload to trigger it.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
