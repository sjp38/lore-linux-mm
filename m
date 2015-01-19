Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ABB6A6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:12:29 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so36706696pab.6
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:12:29 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id be6si1312630pbd.160.2015.01.18.22.12.26
        for <linux-mm@kvack.org>;
        Sun, 18 Jan 2015 22:12:28 -0800 (PST)
Date: Mon, 19 Jan 2015 15:13:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 2/5] mm/compaction: enhance tracepoint output for
 compaction begin/end
Message-ID: <20150119061312.GA11473@js1304-P5Q-DELUXE>
References: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1421307673-24084-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20150115171627.91b51c2e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115171627.91b51c2e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 15, 2015 at 05:16:27PM -0800, Andrew Morton wrote:
> On Thu, 15 Jan 2015 16:41:10 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > We now have tracepoint for begin event of compaction and it prints
> > start position of both scanners, but, tracepoint for end event of
> > compaction doesn't print finish position of both scanners. It'd be
> > also useful to know finish position of both scanners so this patch
> > add it. It will help to find odd behavior or problem on compaction
> > internal logic.
> > 
> > And, mode is added to both begin/end tracepoint output, since
> > according to mode, compaction behavior is quite different.
> > 
> > And, lastly, status format is changed to string rather than
> > status number for readability.
> > 
> > ...
> >
> > +	TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
> > +		__entry->zone_start,
> > +		__entry->migrate_pfn,
> > +		__entry->free_pfn,
> > +		__entry->zone_end,
> > +		__entry->sync ? "sync" : "async",
> > +		compaction_status_string[__entry->status])
> >  );
> >  
> >  #endif /* _TRACE_COMPACTION_H */
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 546e571..2d86a20 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -19,6 +19,14 @@
> >  #include "internal.h"
> >  
> >  #ifdef CONFIG_COMPACTION
> > +char *compaction_status_string[] = {
> > +	"deferred",
> > +	"skipped",
> > +	"continue",
> > +	"partial",
> > +	"complete",
> > +};
> 
> compaction_status_string[] is unreferenced if tracing is disabled -
> more ifdeffery is needed?

Hello,

Yes, I sent fixed version patchset, v4, a while ago.
And, there is some build failure reports from kbuild test bot so please
take v4 rather than v3.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
