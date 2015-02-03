Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9062C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 01:53:41 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so92404538pab.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 22:53:41 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fc3si1384017pad.15.2015.02.02.22.53.39
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 22:53:40 -0800 (PST)
Date: Tue, 3 Feb 2015 15:55:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH v3 3/3] mm/compaction: enhance compaction finish
 condition
Message-ID: <20150203065521.GB9822@js1304-P5Q-DELUXE>
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1422861348-5117-3-git-send-email-iamjoonsoo.kim@lge.com>
 <54CF4F61.3070905@suse.cz>
 <BLU436-SMTP200D06EB86F21EF7A29CE57833C0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU436-SMTP200D06EB86F21EF7A29CE57833C0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Feb 02, 2015 at 09:51:01PM +0800, Zhang Yanfei wrote:
> Hello,
> 
> At 2015/2/2 18:20, Vlastimil Babka wrote:
> > On 02/02/2015 08:15 AM, Joonsoo Kim wrote:
> >> Compaction has anti fragmentation algorithm. It is that freepage
> >> should be more than pageblock order to finish the compaction if we don't
> >> find any freepage in requested migratetype buddy list. This is for
> >> mitigating fragmentation, but, there is a lack of migratetype
> >> consideration and it is too excessive compared to page allocator's anti
> >> fragmentation algorithm.
> >>
> >> Not considering migratetype would cause premature finish of compaction.
> >> For example, if allocation request is for unmovable migratetype,
> >> freepage with CMA migratetype doesn't help that allocation and
> >> compaction should not be stopped. But, current logic regards this
> >> situation as compaction is no longer needed, so finish the compaction.
> > 
> > This is only for order >= pageblock_order, right? Perhaps should be told explicitly.
> 
> I might be wrong. If we applied patch1, so after the system runs for some time,
> there must be no MIGRATE_CMA free pages in the system, right? If so, the
> example above doesn't exist anymore.

Hello,

Compaction could migrate all pages on MIGRATE_CMA pageblock, and,
in this case, order >= pageblock_order could be true. And, cma freepages
are used only for fallback so even if applying patch1, it could be possible.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
