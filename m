Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC4C6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:35:38 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so6369819pdj.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:35:38 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id b7si15320720pat.208.2015.06.15.22.35.36
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 22:35:37 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:37:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/6] mm, compaction: more robust check for scanners
 meeting
Message-ID: <20150616053743.GA12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

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

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
