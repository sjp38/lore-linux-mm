Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 339B9440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 11:59:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e8so2623628wmc.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 08:59:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si3863660edc.360.2017.11.08.08.59.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 08:59:47 -0800 (PST)
Date: Wed, 8 Nov 2017 16:59:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, truncate: remove all exceptional entries from
 pagevec under one lock -fix
Message-ID: <20171108165946.3psvkgya5xq5srrf@suse.de>
References: <20171108164226.26788-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171108164226.26788-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Nov 08, 2017 at 05:42:26PM +0100, Jan Kara wrote:
> Patch "mm, truncate: remove all exceptional entries from pagevec" had a
> problem that truncate_exceptional_pvec_entries() didn't remove exceptional
> entries that were beyond end of truncated range from the pagevec. As a result
> pagevec_release() oopsed trying to treat exceptional entry as a page pointer.
> This can be reproduced by running xfstests generic/269 in a loop while
> applying memory pressure until the bug triggers.
> 
> Rip out fragile passing of index of the first exceptional entry in the
> pagevec and scan the full pagevec instead. Additional pagevec pass doesn't
> have measurable overhead and the code is more robust that way.
> 
> This is a fix to the mmotm patch
> mm-truncate-remove-all-exceptional-entries-from-pagevec-under-one-lock.patch
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> 

Acked-by: Mel Gorman <mgorman@suse.com>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
