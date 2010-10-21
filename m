Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8CC735F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:22:39 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:22:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101021181347.GB32737@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1010211321220.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021181347.GB32737@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Andi Kleen wrote:

> On Thu, Oct 21, 2010 at 12:59:17PM -0500, Christoph Lameter wrote:
> > Slab objects (and other caches) are always allocated from ZONE_NORMAL.
> > Not from any other zone. Calling the shrinkers for those zones may put
> > unnecessary pressure on the caches.
>
> How about GFP_DMA? That's still supported unfortunately
> (my old patchkit to try to kill it never was finished or merged)
>
> So I think these checks would need to be <= ZONE_NORMAL,
> not ==

Yes. Plus there is also the fallback situation. Allocation for
ZONE_NORMAL can fall back and therefore slab objects can end up in these
zones.

Then we end up with still having multiple shrinker invocations for the
the same data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
