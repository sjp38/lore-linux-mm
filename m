Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0D976B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 18:38:11 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y64so22624itd.4
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 15:38:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k144sor22134ita.81.2018.03.01.15.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 15:38:10 -0800 (PST)
Date: Thu, 1 Mar 2018 15:38:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd
 fails
In-Reply-To: <20180301152737.62b78dcb129339a3261a9820@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1803011535280.173043@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com> <20180301152737.62b78dcb129339a3261a9820@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Mar 2018, Andrew Morton wrote:

> On Thu, 1 Mar 2018 03:42:04 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > It's possible for buddy pages to become stranded on pcps that, if drained,
> > could be merged with other buddy pages on the zone's free area to form
> > large order pages, including up to MAX_ORDER.
> 
> I grabbed this as-is.  Perhaps you could send along a new changelog so
> that others won't be asking the same questions as Vlastimil?
> 
> The patch has no reviews or acks at this time...
> 

Thanks.

As mentioned in my response to Vlastimil, I think the case could also be 
made that we should do drain_all_pages(zone) in try_to_compact_pages() 
when we defer for direct compactors.  It would be great to have feedback 
from those on the cc on that point, the patch in general, and then I can 
send an update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
