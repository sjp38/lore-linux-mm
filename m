Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B66246B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 05:07:16 -0500 (EST)
Date: Mon, 15 Feb 2010 11:07:12 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc() v2
Message-ID: <20100215100712.GC21783@one.firstfloor.org>
References: <20100211953.850854588@firstfloor.org> <20100211205401.002CFB1978@basil.firstfloor.org> <20100215060400.GG5723@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100215060400.GG5723@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

> This is a better way to go anyway because it really is a proper
> "fallback" alloc. I think that possibly used to work (ie. kmem_getpages
> would be able to pass -1 for the node there) but got broken along the
> line.

Thanks for the review.

I should add there's still one open problem: in some cases 
the oom killer kicks in on hotadd. Still working on that one.

In general hotadd was mighty bitrotted :/

> 
> Although it's not such a hot path to begin with, care to put a branch
> annotation there?

pointer == NULL is already default unlikely in gcc

/* Pointers are usually not NULL.  */
DEF_PREDICTOR (PRED_POINTER, "pointer", HITRATE (85), 0)
DEF_PREDICTOR (PRED_TREE_POINTER, "pointer (on trees)", HITRATE (85), 0)

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
