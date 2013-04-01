Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 30F066B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 00:45:16 -0400 (EDT)
Date: Mon, 1 Apr 2013 13:45:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] THP: Use explicit memory barrier
Message-ID: <20130401044514.GC26497@blaptop>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
 <5158DC7D.2040607@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5158DC7D.2040607@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

Hey Kame,

On Mon, Apr 01, 2013 at 10:01:49AM +0900, Kamezawa Hiroyuki wrote:
> (2013/04/01 8:45), Minchan Kim wrote:
> > __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> > spinlock for making sure that clear_huge_page write become visible
> > after set set_pmd_at() write.
> > 
> > But lru_cache_add_lru uses pagevec so it could miss spinlock
> > easily so above rule was broken so user may see inconsistent data.
> > This patch fixes it with using explict barrier rather than depending
> > on lru spinlock.
> > 
> 
> Hmm...how about do_anonymous_page() ? there are no comments/locks/barriers.
> Users can see non-zero value after page fault in theory ?

Maybe, but as you know well, we didn't see any report about that until now
so I'm not sure. Ccing people in this thread could have clear answer rather
than me.

In THP, I just found inconsistency between Andrea's comment and code.
That's why I sent a patch.

If your concern turns out truth, Ya, you might find ancient bug. :)
Thanks.

> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
