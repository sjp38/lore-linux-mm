Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 971536B006C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:42:59 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so6495549pdj.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:42:59 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id f6si21112275pds.59.2015.06.15.22.42.57
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 22:42:58 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:45:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 5/6] mm, compaction: skip compound pages by order in free
 scanner
Message-ID: <20150616054505.GE12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:33AM +0200, Vlastimil Babka wrote:
> The compaction free scanner is looking for PageBuddy() pages and skipping all
> others.  For large compound pages such as THP or hugetlbfs, we can save a lot
> of iterations if we skip them at once using their compound_order(). This is
> generally unsafe and we can read a bogus value of order due to a race, but if
> we are careful, the only danger is skipping too much.
> 
> When tested with stress-highalloc from mmtests on 4GB system with 1GB hugetlbfs
> pages, the vmstat compact_free_scanned count decreased by at least 15%.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>


Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
