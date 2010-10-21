Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 16CAC5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:13:51 -0400 (EDT)
Date: Thu, 21 Oct 2010 20:13:47 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-ID: <20101021181347.GB32737@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211255570.24115@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 12:59:17PM -0500, Christoph Lameter wrote:
> Slab objects (and other caches) are always allocated from ZONE_NORMAL.
> Not from any other zone. Calling the shrinkers for those zones may put
> unnecessary pressure on the caches.

How about GFP_DMA? That's still supported unfortunately
(my old patchkit to try to kill it never was finished or merged)

So I think these checks would need to be <= ZONE_NORMAL,
not ==

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
