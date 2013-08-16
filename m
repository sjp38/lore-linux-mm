Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7B7356B0033
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 00:37:30 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id x14so2794860ief.12
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:37:29 -0700 (PDT)
Date: Fri, 16 Aug 2013 13:37:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compaction: Do not compact pgdat for order-0
Message-ID: <20130816043721.GB6216@gmail.com>
References: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
 <20130815104727.GT2296@suse.de>
 <20130815134139.GC8437@gmail.com>
 <20130815135627.GX2296@suse.de>
 <20130815141004.GD8437@gmail.com>
 <20130815153927.GZ2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815153927.GZ2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Aug 15, 2013 at 04:39:27PM +0100, Mel Gorman wrote:
> If kswapd was reclaiming for a high order and resets it to 0 due to
> fragmentation it will still call compact_pgdat. For the most part, this will
> fail a compaction_suitable() test and not compact but it is unnecessarily
> sloppy. It could be fixed in the caller but fix it in the API instead.
> 
> [dhillf@gmail.com: Pointed out that it was a potential problem]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
