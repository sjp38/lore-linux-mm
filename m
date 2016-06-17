Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8046B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:53:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so138476139ioj.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:53:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a17si11055654pfc.220.2016.06.17.00.53.23
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 00:53:24 -0700 (PDT)
Date: Fri, 17 Jun 2016 16:55:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 7/7] mm/page_alloc: introduce post allocation
 processing on page allocator
Message-ID: <20160617075538.GD810@js1304-P5Q-DELUXE>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com>
 <21ab870c-7470-bb28-d8db-4dba25077854@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21ab870c-7470-bb28-d8db-4dba25077854@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2016 at 05:21:45PM +0200, Vlastimil Babka wrote:
> On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >This patch is motivated from Hugh and Vlastimil's concern [1].
> >
> >There are two ways to get freepage from the allocator. One is using
> >normal memory allocation API and the other is __isolate_free_page() which
> >is internally used for compaction and pageblock isolation. Later usage is
> >rather tricky since it doesn't do whole post allocation processing
> >done by normal API.
> >
> >One problematic thing I already know is that poisoned page would not be
> >checked if it is allocated by __isolate_free_page(). Perhaps, there would
> >be more.
> >
> >We could add more debug logic for allocated page in the future and this
> >separation would cause more problem. I'd like to fix this situation
> >at this time. Solution is simple. This patch commonize some logic
> >for newly allocated page and uses it on all sites. This will solve
> >the problem.
> >
> >[1] http://marc.info/?i=alpine.LSU.2.11.1604270029350.7066%40eggly.anvils%3E
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Yes that's much better. Hopefully introducing a function call into
> prep_new_page() (or can compiler still inline it there?) doesn't
> impact the fast paths though.

Looks like it is already inlined in my build environment but I will
add inline attribute.

> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
