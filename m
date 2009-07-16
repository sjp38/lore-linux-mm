Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9E316B009C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:21:25 -0400 (EDT)
Date: Thu, 16 Jul 2009 09:21:29 -0700
From: Jesse Barnes <jesse.barnes@intel.com>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
Message-ID: <20090716092129.1dbb0138@jbarnes-g45>
In-Reply-To: <20090716133454.GA20550@localhost>
References: <20090716133454.GA20550@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009 06:34:55 -0700
"Wu, Fengguang" <fengguang.wu@intel.com> wrote:

> global_lru_pages() / zone_lru_pages() can be used in two ways:
> - to estimate max reclaimable pages in determine_dirtyable_memory()  
> - to calculate the slab scan ratio
> 
> When swap is full or not present, the anon lru lists are not
> reclaimable and thus won't be scanned. So the anon pages shall not be
> counted. Also rename the function names to reflect the new meaning.
> 
> It can greatly (and correctly) increase the slab scan rate under high
> memory pressure (when most file pages have been reclaimed and swap is
> full/absent), thus avoid possible false OOM kills.
> 
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/vmstat.h |   11 +--------
>  mm/page-writeback.c    |    5 ++--
>  mm/vmscan.c            |   44 +++++++++++++++++++++++++++++----------
>  3 files changed, 38 insertions(+), 22 deletions(-)
> 

Looks nice to me, including the naming.  FWIW (given that it's been
years since I did any serious VM work):

Reviewed-by: Jesse Barnes <jbarnes@virtuousgeek.org>

-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
