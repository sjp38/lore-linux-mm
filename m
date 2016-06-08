Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84DE36B025F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:27:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so45460215pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:27:20 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y4si13559779pfa.149.2016.06.08.00.27.18
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 00:27:19 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:28:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 04/10] mm: fix LRU balancing effect of new transparent
 huge pages
Message-ID: <20160608072823.GD28155@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-5-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-5-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:30PM -0400, Johannes Weiner wrote:
> Currently, THP are counted as single pages until they are split right
> before being swapped out. However, at that point the VM is already in
> the middle of reclaim, and adjusting the LRU balance then is useless.
> 
> Always account THP by the number of basepages, and remove the fixup
> from the splitting path.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
