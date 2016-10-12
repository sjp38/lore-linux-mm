Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE5326B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:34:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b201so5310013wmb.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:34:53 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q6si9016456wjy.190.2016.10.12.01.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 01:34:52 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id b80so1243473wme.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:34:52 -0700 (PDT)
Date: Wed, 12 Oct 2016 10:34:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 3/4] mm: try to exhaust highatomic reserve before the
 OOM
Message-ID: <20161012083449.GD17128@dhcp22.suse.cz>
References: <1476259429-18279-1-git-send-email-minchan@kernel.org>
 <1476259429-18279-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476259429-18279-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

Looks much better. Thanks! I am wondering whether we want to have this
marked for stable. The patch is quite non-intrusive and fires only when
we are really OOM. It is definitely better to try harder than go and
disrupt the system by the OOM killer. So I would add
Fixes: 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for high-order atomic allocations on demand")
Cc: stable # 4.4+

The backport will look slightly different for kernels prior 4.6 because
we do not have should_reclaim_retry yet but the check might hook right
before __alloc_pages_may_oom.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
