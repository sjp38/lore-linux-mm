Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5836B0039
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:31:17 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2300974eae.41
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:31:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b44si12497211eez.245.2014.01.10.14.31.16
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 14:31:16 -0800 (PST)
Message-ID: <52D07472.7020601@redhat.com>
Date: Fri, 10 Jan 2014 17:30:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 6/9] mm + fs: store shadow entries in page cache
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org> <1389377443-11755-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-7-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/10/2014 01:10 PM, Johannes Weiner wrote:
> Reclaim will be leaving shadow entries in the page cache radix tree
> upon evicting the real page.  As those pages are found from the LRU,
> an iput() can lead to the inode being freed concurrently.  At this
> point, reclaim must no longer install shadow pages because the inode
> freeing code needs to ensure the page tree is really empty.
> 
> Add an address_space flag, AS_EXITING, that the inode freeing code
> sets under the tree lock before doing the final truncate.  Reclaim
> will check for this flag before installing shadow pages.
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
