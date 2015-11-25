Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3046B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:29:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so175970743wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:29:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t206si5092909wmt.109.2015.11.25.03.29.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 03:29:52 -0800 (PST)
Date: Wed, 25 Nov 2015 11:29:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: fix swapped Movable and Reclaimable in
 /proc/pagetypeinfo
Message-ID: <20151125112949.GQ19677@suse.de>
References: <1448295734-14072-1-git-send-email-vbabka@suse.cz>
 <1448297590-19088-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1448297590-19088-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 23, 2015 at 05:53:10PM +0100, Vlastimil Babka wrote:
> Commit 016c13daa5c9 ("mm, page_alloc: use masks and shifts when converting GFP
> flags to migrate types") has swapped MIGRATE_MOVABLE and MIGRATE_RECLAIMABLE
> in the enum definition. However, migratetype_names wasn't updated to reflect
> that. As a result, the file /proc/pagetypeinfo shows the counts for Movable as
> Reclaimable and vice versa.
> 
> Additionally, commit 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for
> high-order atomic allocations on demand") introduced MIGRATE_HIGHATOMIC, but
> did not add a letter to distinguish it into show_migration_types(), so it
> doesn't appear in the listing of free areas during page alloc failures or oom
> kills.
> 
> This patch fixes both problems. The atomic reserves will show with a letter
> 'H' in the free areas listings.
> 
> Fixes: 016c13daa5c9e4827eca703e2f0621c131f2cca3
> Fixes: 0aaa29a56e4fb0fc9e24edb649e2733a672ca099
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Thanks

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
