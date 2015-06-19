Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B518F6B0088
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 09:41:46 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so19534899wic.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 06:41:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u3si19909530wje.160.2015.06.19.06.41.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 06:41:45 -0700 (PDT)
Date: Fri, 19 Jun 2015 14:41:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] mm, compaction: more robust check for scanners
 meeting
Message-ID: <20150619134139.GA11809@suse.de>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1433928754-966-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:29AM +0200, Vlastimil Babka wrote:
> Compaction should finish when the migration and free scanner meet, i.e. they
> reach the same pageblock. Currently however, the test in compact_finished()
> simply just compares the exact pfns, which may yield a false negative when the
> free scanner position is in the middle of a pageblock and the migration scanner
> reaches the beginning of the same pageblock.
> 
> This hasn't been a problem until commit e14c720efdd7 ("mm, compaction: remember
> position within pageblock in free pages scanner") allowed the free scanner
> position to be in the middle of a pageblock between invocations.  The hot-fix
> 1d5bfe1ffb5b ("mm, compaction: prevent infinite loop in compact_zone")
> prevented the issue by adding a special check in the migration scanner to
> satisfy the current detection of scanners meeting.
> 
> However, the proper fix is to make the detection more robust. This patch
> introduces the compact_scanners_met() function that returns true when the free
> scanner position is in the same or lower pageblock than the migration scanner.
> The special case in isolate_migratepages() introduced by 1d5bfe1ffb5b is
> removed.
> 
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
