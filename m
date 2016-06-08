Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50BF16B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:23:05 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id y7so6345961obt.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:23:05 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 1si456046itz.48.2016.06.08.00.23.04
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 00:23:04 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:24:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 03/10] mm: fold and remove lru_cache_add_anon() and
 lru_cache_add_file()
Message-ID: <20160608072409.GC28155@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-4-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-4-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:29PM -0400, Johannes Weiner wrote:
> They're the same function, and for the purpose of all callers they are
> equivalent to lru_cache_add().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
