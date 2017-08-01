Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E09D6B0515
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:31:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y206so1952700wmd.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:31:39 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id x64si971097wmf.17.2017.08.01.03.31.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 03:31:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id CECFC99493
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:31:37 +0000 (UTC)
Date: Tue, 1 Aug 2017 11:31:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 2/4] mm: make tlb_flush_pending global
Message-ID: <20170801103137.xoql7o6tuytaivtz@techsingularity.net>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1501566977-20293-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Nadav Amit <nadav.amit@gmail.com>

On Tue, Aug 01, 2017 at 02:56:15PM +0900, Minchan Kim wrote:
> Currently, tlb_flush_pending is used only for CONFIG_[NUMA_BALANCING|
> COMPACTION] but upcoming patches to solve subtle TLB flush bacting

s/bacting/batching/

> problem will use it regardless of compaction/numa so this patch
> doesn't remove the dependency.
> 
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
