Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B7B0C6B006C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:36:00 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so6330605pdb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:36:00 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id w9si13969801pbs.163.2015.06.15.22.35.58
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 22:36:00 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:38:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/6] mm, compaction: simplify handling restart position
 in free pages scanner
Message-ID: <20150616053807.GB12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:30AM +0200, Vlastimil Babka wrote:
> Handling the position where compaction free scanner should restart (stored in
> cc->free_pfn) got more complex with commit e14c720efdd7 ("mm, compaction:
> remember position within pageblock in free pages scanner"). Currently the
> position is updated in each loop iteration of isolate_freepages(), although it
> should be enough to update it only when breaking from the loop. There's also
> an extra check outside the loop updates the position in case we have met the
> migration scanner.
> 
> This can be simplified if we move the test for having isolated enough from the
> for loop header next to the test for contention, and determining the restart
> position only in these cases. We can reuse the isolate_start_pfn variable for
> this instead of setting cc->free_pfn directly. Outside the loop, we can simply
> set cc->free_pfn to current value of isolate_start_pfn without any extra check.
> 
> Also add a VM_BUG_ON to catch possible mistake in the future, in case we later
> add a new condition that terminates isolate_freepages_block() prematurely
> without also considering the condition in isolate_freepages().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
