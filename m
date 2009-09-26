Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF746B0055
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 23:49:34 -0400 (EDT)
Date: Sat, 26 Sep 2009 05:49:36 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926034936.GK30185@one.firstfloor.org>
References: <20090926031537.GA10176@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090926031537.GA10176@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 26, 2009 at 11:15:37AM +0800, Wu Fengguang wrote:
> The swap cache and page cache code assume that they 'own' the newly
> allocated page and therefore can disregard the locking rules. However
> now hwpoison can hit any time on any page.
> 
> So use the safer lock_page()/trylock_page(). The main intention is not
> to close such a small time window of memory corruption. But to avoid
> kernel oops that may result from such races, and also avoid raising
> false alerts in hwpoison stress tests.
> 
> This in theory will slightly increase page cache/swap cache overheads,
> however it seems to be too small to be measurable in benchmark.

Thanks. Can you please describe what benchmarks you used?

Acked-by: Andi Kleen <ak@linux.intel.com>
-andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
