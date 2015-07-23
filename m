Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECAA6B025A
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:20:07 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so79945208pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:20:06 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id zi5si9072111pac.113.2015.07.22.22.20.05
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 22:20:06 -0700 (PDT)
Date: Thu, 23 Jul 2015 14:24:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm: rename and move get/set_freepage_migratetype
Message-ID: <20150723052431.GD4449@js1304-P5Q-DELUXE>
References: <55969822.9060907@suse.cz>
 <1437483218-18703-1-git-send-email-vbabka@suse.cz>
 <1437483218-18703-2-git-send-email-vbabka@suse.cz>
 <55AF8C94.6020406@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55AF8C94.6020406@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jul 22, 2015 at 02:29:08PM +0200, Vlastimil Babka wrote:
> On 07/21/2015 02:53 PM, Vlastimil Babka wrote:
> > The pair of get/set_freepage_migratetype() functions are used to cache
> > pageblock migratetype for a page put on a pcplist, so that it does not have
> > to be retrieved again when the page is put on a free list (e.g. when pcplists
> > become full). Historically it was also assumed that the value is accurate for
> > pages on freelists (as the functions' names unfortunately suggest), but that
> > cannot be guaranteed without affecting various allocator fast paths. It is in
> > fact not needed and all such uses have been removed.
> > 
> > The last remaining (but pointless) usage related to pages of freelists is in
> > move_freepages(), which this patch removes.
> 
> I realized there's one more callsite that can be removed. Here's
> whole updated patch due to different changelog and to cope with
> context changed by the fixlet to patch 1/2.
> 
> ------8<------
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 2 Jul 2015 16:37:06 +0200
> Subject: mm: rename and move get/set_freepage_migratetype
> 
> The pair of get/set_freepage_migratetype() functions are used to cache
> pageblock migratetype for a page put on a pcplist, so that it does not have
> to be retrieved again when the page is put on a free list (e.g. when pcplists
> become full). Historically it was also assumed that the value is accurate for
> pages on freelists (as the functions' names unfortunately suggest), but that
> cannot be guaranteed without affecting various allocator fast paths. It is in
> fact not needed and all such uses have been removed.
> 
> The last two remaining (but pointless) usages related to pages of freelists
> are removed by this patch:
> - move_freepages() which operates on pages already on freelists
> - __free_pages_ok() which puts a page directly to freelist, bypassing pcplists
> 
> To prevent further confusion, rename the functions to
> get/set_pcppage_migratetype() and expand their description. Since all the
> users are now in mm/page_alloc.c, move the functions there from the shared
> header.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
