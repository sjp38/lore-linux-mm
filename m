Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 734F06B00A4
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 17:03:07 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n91L3LjO004134
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 14:03:22 -0700
Received: from pxi38 (pxi38.prod.google.com [10.243.27.38])
	by spaceape12.eur.corp.google.com with ESMTP id n91L3Ivo000374
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 14:03:19 -0700
Received: by pxi38 with SMTP id 38so590554pxi.13
        for <linux-mm@kvack.org>; Thu, 01 Oct 2009 14:03:18 -0700 (PDT)
Date: Thu, 1 Oct 2009 14:03:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/31] mm: expose gfp_to_alloc_flags()
In-Reply-To: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
Message-ID: <alpine.DEB.1.00.0910011355230.32006@chino.kir.corp.google.com>
References: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> 
> Expose the gfp to alloc_flags mapping, so we can use it in other parts
> of the vm.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>

Nack, these flags are internal to the page allocator and exporting them to 
generic VM code is unnecessary.

The only bit you actually use in your patchset is ALLOC_NO_WATERMARKS to 
determine whether a particular allocation can use memory reserves.  I'd 
suggest adding a bool function that returns whether the current context is 
given access to reserves including your new __GFP_MEMALLOC flag and 
exporting that instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
