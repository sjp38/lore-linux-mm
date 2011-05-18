Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CA9096B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 17:35:58 -0400 (EDT)
Date: Wed, 18 May 2011 23:35:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap chain locking v2
Message-ID: <20110518213556.GC12317@one.firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org> <1305330384-19540-2-git-send-email-andi@firstfloor.org> <20110518132547.24d665e1.akpm@linux-foundation.org> <20110518211443.GB12317@one.firstfloor.org> <20110518142052.e0b6f327.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518142052.e0b6f327.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

> ah, whoop, sorry.  It's getting turned into a mutex, by
> mm-convert-anon_vma-lock-to-a-mutex.patch

Do you plan to merge that next cycle? If yes I can rebase on top
of that. Otherwise the other way round?

> > To be honest I forgot where the -mm tree is, so I can't check. 
> > It's not in its old place on kernel.org anymore?
> 
> http://userweb.kernel.org/~akpm/mmotm/
> 
> If you dive into the `series' file you'll see that this patch is part of this
> series:

Thanks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
