Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260596B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:21:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so63183417pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:21:29 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id t18si11547525pfa.44.2016.07.19.15.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:21:28 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id fi15so11057920pac.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:21:28 -0700 (PDT)
Date: Tue, 19 Jul 2016 15:21:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/8] mm, compaction: don't isolate PageWriteback pages
 in MIGRATE_SYNC_LIGHT mode
In-Reply-To: <20160718112302.27381-2-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1607191520580.19940@chino.kir.corp.google.com>
References: <20160718112302.27381-1-vbabka@suse.cz> <20160718112302.27381-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, 18 Jul 2016, Vlastimil Babka wrote:

> From: Hugh Dickins <hughd@google.com>
> 
> At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
> isolate a PageWriteback page, which __unmap_and_move() then rejects
> with -EBUSY: of course the writeback might complete in between, but
> that's not what we usually expect, so probably better not to isolate it.
> 
> When tested by stress-highalloc from mmtests, this has reduced the number of
> page migrate failures by 60-70%.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
