Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 92FE26B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 04:49:56 -0400 (EDT)
Subject: Re: [patch 1/3] mm: SLUB fix reclaim_state
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090506134236.GA3012@wotan.suse.de>
References: <20090505091343.706910164@suse.de>
	 <20090505091434.312182900@suse.de>
	 <1241594430.15411.3.camel@penberg-laptop>
	 <20090506134236.GA3012@wotan.suse.de>
Date: Thu, 07 May 2009 11:50:40 +0300
Message-Id: <1241686240.17846.19.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, 2009-05-06 at 15:42 +0200, Nick Piggin wrote:
> > I have applied the patch series. I see you have cc'd stable so I assume
> > you want this in 2.6.30, right? This seems like a rather serious bug but
> 
> Thanks. I think it makes sense to into 2.6.30. Also probably all active
> .stable kernels.
> 
> 
> > I wonder why we've gotten away with it for so long? Is there a test
> > program or a known workload that breaks without this?
> 
> Well... it isn't doing what reclaim code wants, and it is differing
> behaviour between SLAB and SL?B, so I think it is fairly safe to
> merge these now.
> 
> It doesn't look like too much *significant* changes to heuristics, but
> things will get skewed here and there.

Yeah, that's my thinking too. Oh, well, I'll forward it to Linus' way
and let the stable guys decide whether they want to take it or not.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
