Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1DC6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:01:42 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so9614062eak.11
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:01:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s42si737096eew.98.2013.12.02.13.01.40
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 13:01:41 -0800 (PST)
Message-ID: <529CF4ED.6040108@redhat.com>
Date: Mon, 02 Dec 2013 16:00:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/9] fs: cachefiles: use add_to_page_cache_lru()
References: <1386012108-21006-1-git-send-email-hannes@cmpxchg.org> <1386012108-21006-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1386012108-21006-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 12/02/2013 02:21 PM, Johannes Weiner wrote:
> This code used to have its own lru cache pagevec up until a0b8cab3
> ("mm: remove lru parameter from __pagevec_lru_add and remove parts of
> pagevec API").  Now it's just add_to_page_cache() followed by
> lru_cache_add(), might as well use add_to_page_cache_lru() directly.
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
