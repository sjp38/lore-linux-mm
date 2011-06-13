Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ACC5E6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:00:02 -0400 (EDT)
Date: Mon, 13 Jun 2011 12:59:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
In-Reply-To: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
Message-ID: <alpine.DEB.2.00.1106131258300.3108@router.home>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Sun, 12 Jun 2011, Hugh Dickins wrote:

> 3.0-rc won't boot with SLUB on my PowerPC G5: kernel BUG at mm/slub.c:1950!
> Bisected to 1759415e630e "slub: Remove CONFIG_CMPXCHG_LOCAL ifdeffery".
>
> After giving myself a medal for finding the BUG on line 1950 of mm/slub.c
> (it's actually the
> 	VM_BUG_ON((unsigned long)(&pcp1) % (2 * sizeof(pcp1)));
> on line 268 of the morass that is include/linux/percpu.h)
> I tried the following alignment patch and found it to work.

Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
was not applied? Pekka?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
