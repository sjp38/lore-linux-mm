Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6586B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 15:29:23 -0400 (EDT)
Date: Mon, 13 Jun 2011 14:29:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
In-Reply-To: <1307990048.11288.3.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1106131428560.5601@router.home>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>  <alpine.DEB.2.00.1106131258300.3108@router.home> <1307990048.11288.3.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, 13 Jun 2011, Pekka Enberg wrote:

> > Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
> > alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
> > was not applied? Pekka?
>
> This patch?
>
> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce
>
> It's queued and will be sent to Linus soon.

Ok it will also fix Hugh's problem then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
