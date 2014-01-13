Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 02CB36B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 20:16:33 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so2769326pdi.34
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 17:16:33 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id o7si14085624pbb.100.2014.01.12.17.16.31
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 17:16:32 -0800 (PST)
Date: Mon, 13 Jan 2014 10:17:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/9] fs: cachefiles: use add_to_page_cache_lru()
Message-ID: <20140113011709.GM1992@bbox>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389377443-11755-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 01:10:35PM -0500, Johannes Weiner wrote:
> This code used to have its own lru cache pagevec up until a0b8cab3
> ("mm: remove lru parameter from __pagevec_lru_add and remove parts of
> pagevec API").  Now it's just add_to_page_cache() followed by
> lru_cache_add(), might as well use add_to_page_cache_lru() directly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
