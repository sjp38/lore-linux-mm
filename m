Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 767805F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:33:35 -0400 (EDT)
Date: Thu, 21 Oct 2010 20:33:31 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-ID: <20101021183331.GC32737@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <20101021181347.GB32737@basil.fritz.box>
 <alpine.DEB.2.00.1010211326310.24115@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211326310.24115@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 01:27:05PM -0500, Christoph Lameter wrote:
> Potential fixup....
> 
> 
> 
> Allocations to ZONE_NORMAL may fall back to ZONE_DMA and ZONE_DMA32
> so we must allow calling shrinkers for these zones as well.

With this change the original patch looks good to me.

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
