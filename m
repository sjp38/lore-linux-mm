Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDF2B6B02C3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 04:49:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b65so18289271wrd.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 01:49:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si4013323wra.101.2017.08.18.01.49.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 01:49:13 -0700 (PDT)
Date: Fri, 18 Aug 2017 10:49:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
Message-ID: <20170818084912.GA18513@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I am getting 
mm/compaction.c: In function 'isolate_freepages_block':
mm/compaction.c:469:4: error: implicit declaration of function 'pageblock_skip_persistent' [-Werror=implicit-function-declaration]
    if (pageblock_skip_persistent(page, order)) {
    ^
mm/compaction.c:470:5: error: implicit declaration of function 'set_pageblock_skip' [-Werror=implicit-function-declaration]
     set_pageblock_skip(page);

when compaction is disabled because isolate_freepages_block is defined
also when CONFIG_COMPACTION=n. I haven't checked how to fix this
properly yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
