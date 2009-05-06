Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 823F96B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 03:20:15 -0400 (EDT)
Subject: Re: [patch 1/3] mm: SLUB fix reclaim_state
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090505091434.312182900@suse.de>
References: <20090505091343.706910164@suse.de>
	 <20090505091434.312182900@suse.de>
Date: Wed, 06 May 2009 10:20:30 +0300
Message-Id: <1241594430.15411.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-05-05 at 19:13 +1000, npiggin@suse.de wrote:
> plain text document attachment (mm-slub-fix-reclaim_state.patch)
> SLUB does not correctly account reclaim_state.reclaimed_slab, so it will
> break memory reclaim. Account it like SLAB does.
> 
> Cc: stable@kernel.org
> Cc: linux-mm@kvack.org
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Christoph Lameter <cl@linux.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

I have applied the patch series. I see you have cc'd stable so I assume
you want this in 2.6.30, right? This seems like a rather serious bug but
I wonder why we've gotten away with it for so long? Is there a test
program or a known workload that breaks without this?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
