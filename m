Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 4A9B56B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 20:37:48 -0400 (EDT)
Date: Tue, 2 Apr 2013 09:37:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] THP: Use explicit memory barrier
Message-ID: <20130402003746.GA30444@blaptop>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
 <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, Apr 01, 2013 at 04:35:38PM -0700, David Rientjes wrote:
> On Mon, 1 Apr 2013, Minchan Kim wrote:
> 
> > __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> > spinlock for making sure that clear_huge_page write become visible
> > after set set_pmd_at() write.
> > 
> > But lru_cache_add_lru uses pagevec so it could miss spinlock
> > easily so above rule was broken so user may see inconsistent data.
> > 
> > This patch fixes it with using explict barrier rather than depending
> > on lru spinlock.
> > 
> 
> Is this the same issue that Andrea responded to in the "thp and memory 
> barrier assumptions" thread at http://marc.info/?t=134333512700004 ?

Yes and Peter pointed out further step.
Thanks for pointing out.
Not that I know that Andrea alreay noticed it, I don't care about this
patch.

Remaining question is Kame's one.
Isn't there anyone could answer it?

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
