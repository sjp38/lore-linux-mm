Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EFB2C6B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 04:44:09 -0400 (EDT)
Received: by wyg36 with SMTP id 36so899776wyg.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 01:44:07 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1107200950270.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Jul 2011 10:43:59 +0200
Message-ID: <1311237839.2422.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  09:52 -0500, Christoph Lameter a A(C)crit :

> We should be making it a per cpu pointer like slub then. I looked at what
> it would take to do so a couple of month ago but it was quite invasive.
> 

I took a look at this too, but using percpu data would consume more
memory, because percpu allocator allocates memory blobs for all possible
cpus, while current code handles online/offline cpu nicely.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
