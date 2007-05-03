Date: Thu, 3 May 2007 17:54:07 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Message-ID: <20070503155407.GA7536@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> - If replying, please be sure to cc the appropriate individuals.  
>   Please also consider rewriting the Subject: to something 
>   appropriate.

i'm wondering about swap-prefetch:

  mm-implement-swap-prefetching.patch
  swap-prefetch-avoid-repeating-entry.patch
  add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated-swap-prefetch.patch

The swap-prefetch feature is relatively compact:

   10 files changed, 745 insertions(+), 1 deletion(-)

it is contained mostly to itself:

   mm/swap_prefetch.c            |  581 ++++++++++++++++++++++++++++++++

i've reviewed it once again and in the !CONFIG_SWAP_PREFETCH case it's a 
clear NOP, while in the CONFIG_SWAP_PREFETCH=y case all the feedback 
i've seen so far was positive. Time to have this upstream and time for a 
desktop-oriented distro to pick it up.

I think this has been held back way too long. It's .config selectable 
and it is as ready for integration as it ever is going to be. So it's a 
win/win scenario.

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
