Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8C46B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 11:04:08 -0500 (EST)
Received: by lfs39 with SMTP id 39so25486245lfs.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:04:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l138si12929162lfg.228.2015.11.24.08.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 08:04:05 -0800 (PST)
Date: Tue, 24 Nov 2015 11:03:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm, vmscan: consider isolated pages in
 zone_reclaimable_pages
Message-ID: <20151124160352.GA9598@cmpxchg.org>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
 <1448366100-11023-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448366100-11023-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 24, 2015 at 12:54:59PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> zone_reclaimable_pages counts how many pages are reclaimable in
> the given zone. This currently includes all pages on file lrus and
> anon lrus if there is an available swap storage. We do not consider
> NR_ISOLATED_{ANON,FILE} counters though which is not correct because
> these counters reflect temporarily isolated pages which are still
> reclaimable because they either get back to their LRU or get freed
> either by the page reclaim or page migration.
> 
> The number of these pages might be sufficiently high to confuse users of
> zone_reclaimable_pages (e.g. mbind can migrate large ranges of memory at
> once).
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
