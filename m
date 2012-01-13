Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 83C4D6B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 22:12:31 -0500 (EST)
Received: by iafj26 with SMTP id j26so4836384iaf.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 19:12:30 -0800 (PST)
Date: Fri, 13 Jan 2012 12:12:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120113031221.GA6473@barrios-desktop>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
 <20120112080311.GA30634@barrios-desktop.redhat.com>
 <20120112114835.GI4118@suse.de>
 <20120113005026.GA2614@barrios-desktop.redhat.com>
 <4F0F987E.1080001@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F0F987E.1080001@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Jan 13, 2012 at 10:35:42AM +0800, Huang Shijie wrote:
> Hi,
> >I think simple patch is returning "return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;"
> >It's very clear and readable, I think.
> >In this patch, what's the problem you think?
> >
> sorry for the wrong thread, please read the following thread:
> http://marc.info/?l=linux-mm&m=132532266130861&w=2

Huang, Thanks for notice that thread.
I read and if I understand correctly, the point is that Mel want to see tracepoint
"trace_mm_compaction_migratepages" and account "count_vm_event(COMPACTBLOCKS);"
My patch does accounting COMPACTBLOCKS so it's not a problem.
The problem is my patch doesn't emit trace of "trace_mm_compaction_migratepages".
But doesn't it matter? When we doesn't isolate any page at all, both argument in
trace_mm_compaction_migratepages are always zero. Is it meaningful tracepoint?
Do we really want it?

> 
> Best Regards
> Huang Shijie
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
