Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id ABAD16B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:41:10 -0400 (EDT)
Received: by wwj40 with SMTP id 40so259071wwj.26
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 07:41:07 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4E26E705.8050704@parallels.com>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <4E26D7EA.3000902@parallels.com>
	 <alpine.DEB.2.00.1107201638520.4921@tiger>
	 <alpine.DEB.2.00.1107200852590.32737@router.home>
	 <20110720142018.GL5349@suse.de>  <4E26E705.8050704@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 16:40:59 +0200
Message-ID: <1311172859.2338.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  18:32 +0400, Konstantin Khlebnikov a
A(C)crit :

> I catch this on our rhel6-openvz kernel, and yes it very patchy,
> but I don't see any reasons why this cannot be reproduced on mainline kernel.
> 
> there was abount ten containers with random stuff, node already do intensive swapout but still alive,
> in this situation starting new containers sometimes (1 per 1000) fails due to kmem_cache_create failures in nf_conntrack,
> there no other messages except:
> Unable to create nf_conn slab cache
> and some
> nf_conntrack: falling back to vmalloc.
> (it try allocates huge hash table and do it via vmalloc if kmalloc fails)


Does this kernel contain commit 6d4831c2 ?
(vfs: avoid large kmalloc()s for the fdtable)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
