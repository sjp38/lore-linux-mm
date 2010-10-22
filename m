Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B310B6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 08:12:17 -0400 (EDT)
Date: Fri, 22 Oct 2010 14:12:11 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101022121210.GG10456@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101021235854.GD3270@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> Again, I really think it needs to be per zone. Something like inode
> cache could still have lots of allocations in ZONE_NORMAL with plenty
> of memory free there, but a DMA zone shortage could cause it to trash
> the caches.

For hwpoison ideally I would like it per page. But that's harder of course.

But if all the shrinkers are adapted it may be worth thinking about that.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
