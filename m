Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8476B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:49:56 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id qs7so36754056wjc.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:49:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si1712262wjs.173.2016.12.28.08.49.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 08:49:55 -0800 (PST)
Date: Wed, 28 Dec 2016 17:49:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161228164952.GG11470@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <d957d4c5-3b58-c61f-0c95-c59e0326528c@gmail.com>
 <20161228160029.GF11470@dhcp22.suse.cz>
 <1a8baddb-842d-31d0-dede-3fb04ed5d9ae@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a8baddb-842d-31d0-dede-3fb04ed5d9ae@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <n.borisov.lkml@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 28-12-16 18:40:16, Nikolay Borisov wrote:
[...]
> "
> It is useful to know whether the list is active or inactive, since we
> are using the same function to isolate pages from both of them and it's
> hard to distinguish otherwise.
> "

OK, updated. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
