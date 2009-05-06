Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB3B46B004F
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:36:14 -0400 (EDT)
Date: Wed, 6 May 2009 11:34:41 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] mm: SLUB fix reclaim_state
Message-ID: <20090506163440.GV31071@waste.org>
References: <20090505091343.706910164@suse.de> <20090505091434.312182900@suse.de> <1241594430.15411.3.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241594430.15411.3.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: npiggin@suse.de, stable@kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 10:20:30AM +0300, Pekka Enberg wrote:
> On Tue, 2009-05-05 at 19:13 +1000, npiggin@suse.de wrote:
> > plain text document attachment (mm-slub-fix-reclaim_state.patch)
> > SLUB does not correctly account reclaim_state.reclaimed_slab, so it will
> > break memory reclaim. Account it like SLAB does.
> > 
> > Cc: stable@kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> > Cc: Matt Mackall <mpm@selenic.com>
> > Cc: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> I have applied the patch series. I see you have cc'd stable so I assume
> you want this in 2.6.30, right? This seems like a rather serious bug but
> I wonder why we've gotten away with it for so long? Is there a test
> program or a known workload that breaks without this?

Appears to me to be less a correctness than a balancing issue. reclaim
state is a back channel into the shrink code that says 'yes, this is
working'. Without it, things should still work, but possibly not as
smoothly.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
