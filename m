Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id A487F6B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:25:03 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id cl4so95440917igb.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:25:03 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c6si18267325igx.58.2016.03.30.01.25.02
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:25:03 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:27:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/2] mm: rename _count, field of the struct page, to
 _refcount
Message-ID: <20160330082701.GG1678@js1304-P5Q-DELUXE>
References: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459146601-11448-2-git-send-email-iamjoonsoo.kim@lge.com>
 <56FA4A93.6090502@suse.cz>
 <20160329122313.3c24964faab99f46c960b19b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160329122313.3c24964faab99f46c960b19b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 29, 2016 at 12:23:13PM -0700, Andrew Morton wrote:
> On Tue, 29 Mar 2016 11:27:47 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > > v2: change more _count usages to _refcount
> > 
> > There's also
> > Documentation/vm/transhuge.txt talking about ->_count
> > include/linux/mm.h:      * requires to already have an elevated page->_count.
> > include/linux/mm_types.h:                        * Keep _count separate from slub cmpxchg_double data.
> > include/linux/mm_types.h:                        * slab_lock but _count is not.
> > include/linux/pagemap.h: * If the page is free (_count == 0), then _count is untouched, and 0
> > include/linux/pagemap.h: * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
> > include/linux/pagemap.h: * this allows allocators to use a synchronize_rcu() to stabilize _count.
> > include/linux/pagemap.h: * Remove-side that cares about stability of _count (eg. reclaim) has the
> > mm/huge_memory.c:        * tail_page->_count is zero and not changing from under us. But
> > mm/huge_memory.c:       /* Prevent deferred_split_scan() touching ->_count */
> > mm/internal.h: * Turn a non-refcounted page (->_count == 0) into refcounted with
> > mm/page_alloc.c:                bad_reason = "nonzero _count";
> > mm/page_alloc.c:                bad_reason = "nonzero _count";
> > mm/page_alloc.c:                 * because their page->_count is zero at all time.
> > mm/slub.c:       * as page->_count.  If we assign to ->counters directly
> > mm/slub.c:       * we run the risk of losing updates to page->_count, so
> > mm/vmscan.c:     * load is not satisfied before that of page->_count.
> > mm/vmscan.c: * The downside is that we have to touch page->_count against each page.
> > 
> > I've arrived at the following command to find this:
> > git grep "[^a-zA-Z0-9_]_count[^_]"
> > 
> > Not that many false positives in the output :)
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-rename-_count-field-of-the-struct-page-to-_refcount-fix
> 
> fix comments, per Vlastimil

Andrew and Vlastimil, great thanks!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
