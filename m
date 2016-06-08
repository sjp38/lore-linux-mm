Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5F9B6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:13:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w9so161578646oia.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:13:38 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p73si387347iod.206.2016.06.08.00.13.37
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 00:13:37 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:14:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 02/10] mm: swap: unexport __pagevec_lru_add()
Message-ID: <20160608071441.GB28155@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-3-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-3-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:28PM -0400, Johannes Weiner wrote:
> There is currently no modular user of this function. We used to have
> filesystems that open-coded the page cache instantiation, but luckily
> they're all streamlined, and we don't want this to come back.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
