Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F1D8F6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:34:41 -0400 (EDT)
Date: Wed, 14 Apr 2010 14:34:39 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414123439.GS18855@one.firstfloor.org>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com> <20100413095815.GU25756@csn.ul.ie> <20100413111902.GY2493@dastard> <20100413193428.GI25756@csn.ul.ie> <20100413202021.GZ13327@think> <877hoa9wlv.fsf@basil.nowhere.org> <20100414112015.GO13327@think> <8739yy9qnf.fsf@basil.nowhere.org> <20100414133229.134264f0@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100414133229.134264f0@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 01:32:29PM +0100, Alan Cox wrote:
> > The only part of the 4K stack code that's good is the separate
> > interrupt stack, but that one should be just combined with a sane 8K 
> > process stack.
> 
> The reality is that if you are blowing a 4K process stack you are
> probably playing russian roulette on the current 8K x86-32 stack as well
> because of the non IRQ split. So it needs fixing either way

Yes I think the 8K stack on 32bit should be combined with a interrupt 
stack too. There's no reason not to have an interrupt stack ever. 

Again the problem with fixing it is that you won't have any safety net
for a slightly different stacking etc. path that you didn't cover.

That said extreme examples (like some of those Chris listed) definitely
need fixing by moving them to different threads. But even after that
you still want a safety net. 4K is just too near the edge.

Maybe it would work if we never used any indirect calls, but that's
clearly not the case.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
