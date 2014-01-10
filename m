Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBDF6B0036
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:52:10 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id en1so217307wid.3
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:52:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ib3si4522148wjb.48.2014.01.10.14.52.09
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 14:52:09 -0800 (PST)
Message-ID: <52D07966.4000205@redhat.com>
Date: Fri, 10 Jan 2014 17:51:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 7/9] mm: thrash detection-based file cache sizing
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org> <1389377443-11755-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-8-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/10/2014 01:10 PM, Johannes Weiner wrote:

> This patch solves one half of the problem by decoupling the ability to
> detect working set changes from the inactive list size.  By
> maintaining a history of recently evicted file pages it can detect
> frequently used pages with an arbitrarily small inactive list size,
> and subsequently apply pressure on the active list based on actual
> demand for cache, not just overall eviction speed.
> 
> Every zone maintains a counter that tracks inactive list aging speed.
> When a page is evicted, a snapshot of this counter is stored in the
> now-empty page cache radix tree slot.  On refault, the minimum access
> distance of the page can be assessed, to evaluate whether the page
> should be part of the active list or not.
> 
> This fixes the VM's blindness towards working set changes in excess of
> the inactive list.  And it's the foundation to further improve the
> protection ability and reduce the minimum inactive list size of 50%.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
