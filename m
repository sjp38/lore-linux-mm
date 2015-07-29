Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C27C36B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:57:40 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so27559815wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:57:40 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id xt4si43995900wjc.19.2015.07.29.06.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 06:57:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id D5CF59895A
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 13:57:37 +0000 (UTC)
Date: Wed, 29 Jul 2015 14:57:35 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: rename and move get/set_freepage_migratetype
Message-ID: <20150729135735.GH19352@techsingularity.net>
References: <55969822.9060907@suse.cz>
 <1437483218-18703-1-git-send-email-vbabka@suse.cz>
 <1437483218-18703-2-git-send-email-vbabka@suse.cz>
 <55AF8C94.6020406@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55AF8C94.6020406@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jul 22, 2015 at 02:29:08PM +0200, Vlastimil Babka wrote:
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

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
