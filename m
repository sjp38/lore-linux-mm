Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6D64B6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 13:30:35 -0400 (EDT)
Received: by eyg7 with SMTP id 7so1491282eyg.41
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:30:32 -0700 (PDT)
Date: Wed, 20 Jul 2011 20:28:53 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <alpine.DEB.2.00.1107201212140.1472@router.home>
Message-ID: <alpine.DEB.2.00.1107202028050.2847@tiger>
References: <20110720121612.28888.38970.stgit@localhost6>  <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>  <alpine.DEB.2.00.1107200854390.32737@router.home>  <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107200950270.1472@router.home>  <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1107201033080.1472@router.home>  <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1107201114480.1472@router.home>
  <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1311181463.2338.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <alpine.DEB.2.00.1107201212140.1472@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, 20 Jul 2011, Eric Dumazet wrote:
>> [PATCH v2] slab: shrinks sizeof(struct kmem_cache)

On Wed, 20 Jul 2011, Christoph Lameter wrote:
> This will solve the issue for small nr_cpu_ids but those with 4k cpus will
> still have the issue.
>
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks! Do we still want the __GFP_REPEAT patch from Konstantin 
though?

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
