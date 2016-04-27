Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20AF36B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:31:25 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so93580152iod.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:31:25 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id io7si5076146wjb.27.2016.04.27.08.31.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 08:31:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 63D1398A65
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:31:23 +0000 (UTC)
Date: Wed, 27 Apr 2016 16:31:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
Message-ID: <20160427153121.GK2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
 <5720C753.2000804@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5720C753.2000804@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 27, 2016 at 04:06:11PM +0200, Vlastimil Babka wrote:
> From afdefd87f2d8d07cba4bd2a2f3531dc8bb0b7a19 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 27 Apr 2016 15:47:29 +0200
> Subject: [PATCH] mm, page_alloc: uninline the bad page part of
>  check_new_page()
> 
> Bad pages should be rare so the code handling them doesn't need to be inline
> for performance reasons. Put it to separate function which returns void.
> This also assumes that the initial page_expected_state() result will match the
> result of the thorough check, i.e. the page doesn't become "good" in the
> meanwhile. This matches the same expectations already in place in
> free_pages_check().
> 
> !DEBUG_VM bloat-o-meter:
> 
> add/remove: 1/0 grow/shrink: 0/1 up/down: 134/-274 (-140)
> function                                     old     new   delta
> check_new_page_bad                             -     134    +134
> get_page_from_freelist                      3468    3194    -274
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Andrew, if you pick up v2 of of the follow-up series then can you also
add this patch on top if it's convenient please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
