Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1159F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:37:27 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id w62so4113286wes.22
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:37:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hx1si17584574wjb.169.2014.07.25.05.37.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:37:26 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:37:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 12/15] mm: rename allocflags_to_migratetype for clarity
Message-ID: <20140725123722.GG10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-13-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-13-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:20PM +0200, Vlastimil Babka wrote:
> From: David Rientjes <rientjes@google.com>
> 
> The page allocator has gfp flags (like __GFP_WAIT) and alloc flags (like
> ALLOC_CPUSET) that have separate semantics.
> 
> The function allocflags_to_migratetype() actually takes gfp flags, not alloc
> flags, and returns a migratetype.  Rename it to gfpflags_to_migratetype().
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
