Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 47D5B6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:00:14 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so54346545pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:00:14 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id z4si468699par.49.2015.11.25.03.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 03:00:13 -0800 (PST)
Received: by padhx2 with SMTP id hx2so54459783pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:00:13 -0800 (PST)
Date: Wed, 25 Nov 2015 03:00:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, vmscan: consider isolated pages in
 zone_reclaimable_pages
In-Reply-To: <1448366100-11023-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511250259590.32374@chino.kir.corp.google.com>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org> <1448366100-11023-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 24 Nov 2015, Michal Hocko wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
