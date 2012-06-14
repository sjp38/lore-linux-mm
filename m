Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 810C06B0072
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:21:26 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3398934dak.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:21:25 -0700 (PDT)
Message-ID: <4FDA0F82.2030708@gmail.com>
Date: Thu, 14 Jun 2012 12:21:22 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: compaction: add /proc/vmstat entry for rescued
 MIGRATE_UNMOVABLE pageblocks
References: <201206141802.50075.b.zolnierkie@samsung.com>
In-Reply-To: <201206141802.50075.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

(6/14/12 12:02 PM), Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Subject: [PATCH] mm: compaction: add /proc/vmstat entry for rescued MIGRATE_UNMOVABLE pageblocks
>
> compact_rescued_unmovable_blocks shows the number of MIGRATE_UNMOVABLE
> pageblocks converted back to MIGRATE_MOVABLE type by the memory compaction
> code.  Non-zero values indicate that large kernel-originated allocations
> of MIGRATE_UNMOVABLE type happen in the system and need special handling
> from the memory compaction code.
>
> This new vmstat entry is optional but useful for development and understanding
> the system.

This description don't describe why admin need this stat and how to use it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
