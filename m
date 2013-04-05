Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 9A4E56B0111
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 15:52:27 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl13so2212036pab.18
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 12:52:26 -0700 (PDT)
Date: Fri, 5 Apr 2013 12:52:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] THP: fix comment about memory barrier
In-Reply-To: <1365149799-839-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.02.1304051252100.21173@chino.kir.corp.google.com>
References: <1365149799-839-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, 5 Apr 2013, Minchan Kim wrote:

> Now, memory barrier in __do_huge_pmd_anonymous_page doesn't work.
> Because lru_cache_add_lru uses pagevec so it could miss spinlock
> easily so above rule was broken so user might see inconsistent data.
> 
> I was not first person who pointed out the problem. Mel and Peter
> pointed out a few months ago and Peter pointed out further that
> even spin_lock/unlock can't make sure it.
> http://marc.info/?t=134333512700004
> 
> 	In particular:
> 
>         	*A = a;
>         	LOCK
>         	UNLOCK
>         	*B = b;
> 
> 	may occur as:
> 
>         	LOCK, STORE *B, STORE *A, UNLOCK
> 
> At last, Hugh pointed out that even we don't need memory barrier
> in there because __SetPageUpdate already have done it from
> Nick's [1] explicitly.
> 
> So this patch fixes comment on THP and adds same comment for
> do_anonymous_page, too because everybody except Hugh was missing
> that. It means we needs COMMENT about that.
> 
> [1] 0ed361dec "mm: fix PageUptodate data race"
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
