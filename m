Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DAEC66B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 15:02:31 -0500 (EST)
Date: Fri, 2 Dec 2011 14:02:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1322825802.2607.10.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1112021401200.13405@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <1322825802.2607.10.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alex Shi <alex.shi@intel.com>, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011, Eric Dumazet wrote:

> netperf (loopback or ethernet) is a known stress test for slub, and your
> patch removes code that might hurt netperf, but benefit real workload.
>
> Have you tried instead this far less intrusive solution ?
>
> if (tail == DEACTIVATE_TO_TAIL ||
>     page->inuse > page->objects / 4)
>          list_add_tail(&page->lru, &n->partial);
> else
>          list_add(&page->lru, &n->partial);

One could also move this logic to reside outside of the call to
add_partial(). This is called mostly from __slab_free() so the logic could
be put in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
