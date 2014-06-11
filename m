Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9803B6B0138
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:41:05 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so6708965pdj.6
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:41:05 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id c8si4925697pat.56.2014.06.10.19.41.03
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 19:41:04 -0700 (PDT)
Date: Wed, 11 Jun 2014 11:41:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 07/10] mm: rename allocflags_to_migratetype for clarity
Message-ID: <20140611024109.GG15630@bbox>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
 <1402305982-6928-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402305982-6928-7-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 09, 2014 at 11:26:19AM +0200, Vlastimil Babka wrote:
> From: David Rientjes <rientjes@google.com>
> 
> The page allocator has gfp flags (like __GFP_WAIT) and alloc flags (like
> ALLOC_CPUSET) that have separate semantics.
> 
> The function allocflags_to_migratetype() actually takes gfp flags, not alloc
> flags, and returns a migratetype.  Rename it to gfpflags_to_migratetype().
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I was one of person who got confused sometime.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
