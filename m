Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8AD456B0082
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:48:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 09FED3EE0C0
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:48:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D120045DE54
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:48:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68DB645DE4F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:48:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 553321DB8040
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:48:34 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06F6F1DB803B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:48:34 +0900 (JST)
Message-ID: <515E9DC5.4050402@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 18:47:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] THP: fix comment about memory barrier
References: <1365149799-839-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1365149799-839-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

(2013/04/05 17:16), Minchan Kim wrote:
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
>          	*A = a;
>          	LOCK
>          	UNLOCK
>          	*B = b;
> 
> 	may occur as:
> 
>          	LOCK, STORE *B, STORE *A, UNLOCK
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

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
