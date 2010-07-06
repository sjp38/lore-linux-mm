Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EEBE56B024C
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 16:48:10 -0400 (EDT)
Date: Tue, 6 Jul 2010 15:44:45 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 07/16] slub: discard_slab_unlock
In-Reply-To: <alpine.DEB.2.00.1006261632080.27174@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007061542540.7945@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212105.203196516@quilx.com> <alpine.DEB.2.00.1006261632080.27174@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, David Rientjes wrote:

> > The sequence of unlocking a slab and freeing occurs multiple times.
> > Put the common into a single function.
> >
>
> Did you want to respond to the comments I made about this patch at
> http://marc.info/?l=linux-mm&m=127689747432061 ?  Specifically, how it
> makes seeing if there are unmatched slab_lock() -> slab_unlock() pairs
> more difficult.

I dont think so. The name includes slab_unlock at the end. We could drop
this but its a frequent action necessary when disposing of a slab page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
