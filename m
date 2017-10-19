Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 463D66B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 10:32:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 198so3662809wmx.2
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:32:55 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id f51si5462504edf.124.2017.10.19.07.32.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 07:32:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 7BF8999306
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:32:53 +0000 (UTC)
Date: Thu, 19 Oct 2017 15:32:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 8/8] mm: Remove __GFP_COLD
Message-ID: <20171019143252.bviqsb7qxppzz32j@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-9-mgorman@techsingularity.net>
 <f6505442-98a9-12e4-b2cd-0fa83874c159@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f6505442-98a9-12e4-b2cd-0fa83874c159@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 19, 2017 at 03:42:12PM +0200, Vlastimil Babka wrote:
> From b002266c1a826805a50087db851f93e7a87ceb2f Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Tue, 17 Oct 2017 16:03:02 +0200
> Subject: [PATCH] mm, page_alloc: simplify list handling in rmqueue_bulk()
> 
> The rmqueue_bulk() function fills an empty pcplist with pages from the free
> list. It tries to preserve increasing order by pfn to the caller, because it
> leads to better performance with some I/O controllers, as explained in
> e084b2d95e48 ("page-allocator: preserve PFN ordering when __GFP_COLD is set").
> 
> To preserve the order, it's sufficient to add pages to the tail of the list
> as they are retrieved. The current code instead adds to the head of the list,
> but then updates the list head pointer to the last added page, in each step.
> This does result in the same order, but is needlessly confusing and potentially
> wasteful, with no apparent benefit. This patch simplifies the code and adjusts
> comment accordingly.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
