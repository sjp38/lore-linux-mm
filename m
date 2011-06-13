Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BBCFF6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:34:11 -0400 (EDT)
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1106131258300.3108@router.home>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
	 <alpine.DEB.2.00.1106131258300.3108@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 13 Jun 2011 21:34:08 +0300
Message-ID: <1307990048.11288.3.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, 2011-06-13 at 12:59 -0500, Christoph Lameter wrote:
> On Sun, 12 Jun 2011, Hugh Dickins wrote:
> 
> > 3.0-rc won't boot with SLUB on my PowerPC G5: kernel BUG at mm/slub.c:1950!
> > Bisected to 1759415e630e "slub: Remove CONFIG_CMPXCHG_LOCAL ifdeffery".
> >
> > After giving myself a medal for finding the BUG on line 1950 of mm/slub.c
> > (it's actually the
> > 	VM_BUG_ON((unsigned long)(&pcp1) % (2 * sizeof(pcp1)));
> > on line 268 of the morass that is include/linux/percpu.h)
> > I tried the following alignment patch and found it to work.
> 
> Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
> alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
> was not applied? Pekka?

This patch?

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce

It's queued and will be sent to Linus soon.

			Pekka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
