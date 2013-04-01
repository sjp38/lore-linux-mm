Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CAC2F6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:35:41 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id um15so1415717pbc.22
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 16:35:41 -0700 (PDT)
Date: Mon, 1 Apr 2013 16:35:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] THP: Use explicit memory barrier
In-Reply-To: <1364773535-26264-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, 1 Apr 2013, Minchan Kim wrote:

> __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> spinlock for making sure that clear_huge_page write become visible
> after set set_pmd_at() write.
> 
> But lru_cache_add_lru uses pagevec so it could miss spinlock
> easily so above rule was broken so user may see inconsistent data.
> 
> This patch fixes it with using explict barrier rather than depending
> on lru spinlock.
> 

Is this the same issue that Andrea responded to in the "thp and memory 
barrier assumptions" thread at http://marc.info/?t=134333512700004 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
