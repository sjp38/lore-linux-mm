Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBE8B6B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:55:50 -0400 (EDT)
Date: Thu, 28 May 2009 10:03:19 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [9/16] HWPOISON: Use bitmask/action code for try_to_unmap behaviour
Message-ID: <20090528080319.GA1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201235.9475E1D0292@basil.firstfloor.org> <20090528072703.GF6920@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528072703.GF6920@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 09:27:03AM +0200, Nick Piggin wrote:
> Not a bad idea, but I would prefer to have a set of flags which tell
> try_to_unmap what to do, and then combine them with #defines for
> callers. Like gfp flags.

That's exactly what the patch does?

It just has actions and flags because the actions can be contradictory.

> And just use regular bitops rather than this TTU_ACTION macro.

TTU_ACTION does mask against multiple bits. None of the regular
bitops do that. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
