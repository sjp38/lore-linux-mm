Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 55A8F6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:46:29 -0400 (EDT)
Date: Fri, 22 Oct 2010 18:46:24 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101022164624.GA18103@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
 <20101022155513.GA26790@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101022155513.GA26790@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> Given that we have up to 6 zones per node currently, and we would mostly
> use one with a few fallbacks that seems like a lot of overkill.

Most people don't have that many zones.

But it's relatively common to use both ZONE_DMA32 and ZONE_NORMAL on x86.
e.g. on a 16GB x86 system, node 0 is roughly split 50:50 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
