Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF7716B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:59:29 -0400 (EDT)
Received: by padck2 with SMTP id ck2so151113831pad.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:59:29 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fm4si7545503pab.148.2015.07.22.22.59.27
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 22:59:29 -0700 (PDT)
Date: Thu, 23 Jul 2015 15:03:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
Message-ID: <20150723060348.GF4449@js1304-P5Q-DELUXE>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

Hello,

On Thu, Jul 09, 2015 at 02:53:27PM -0700, David Rientjes wrote:
 
> The slub allocator does try to allocate its high-order memory with 
> __GFP_WAIT before falling back to lower orders if possible.  I would think 
> that this would be the greatest sign of on-demand memory compaction being 
> a problem, especially since CONFIG_SLUB is the default, but I haven't seen 
> such reports.

In fact, some of our product had trouble with slub's high order
allocation 5 months ago. At that time, compaction didn't make high order
page and compaction attempts are frequently deferred. It also causes many
reclaim to make high order page so I suggested masking out __GFP_WAIT
and adding __GFP_NO_KSWAPD when trying slub's high order allocation to
reduce reclaim/compaction overhead. Although using high order page in slub
has some gains that reducing internal fragmentation and reducing management
overhead, benefit is marginal compared to the cost at making high order
page. This solution improves system response time for our case. I planned
to submit the patch but it is delayed due to my laziness. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
