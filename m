Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 366646B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:33:03 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so17136157pad.10
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:33:02 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id q5si786207pdl.41.2015.01.27.00.33.01
        for <linux-mm@kvack.org>;
        Tue, 27 Jan 2015 00:33:02 -0800 (PST)
Date: Tue, 27 Jan 2015 17:34:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper
 buddy list when steal
Message-ID: <20150127083419.GF11358@js1304-P5Q-DELUXE>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com>
 <54856F88.8090300@suse.cz>
 <20141210063840.GC13371@js1304-P5Q-DELUXE>
 <54C73FB5.30000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C73FB5.30000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 27, 2015 at 08:35:17AM +0100, Vlastimil Babka wrote:
> On 12/10/2014 07:38 AM, Joonsoo Kim wrote:
> > After your patch is merged, I will resubmit these on top of it.
> 
> Hi Joonsoo,
> 
> my page stealing patches are now in -mm so are you planning to resubmit this? At
> least patch 1 is an obvious bugfix, and patch 4 a clear compaction overhead
> reduction. Those don't need to wait for the rest of the series. If you are busy
> with other stuff, I can also resend those two myself if you want.

Hello,

I've noticed that your patches are merged. :)
If you are in hurry, you can resend them. I'm glad if you handle it.
If not, I will resend them, maybe, on end of this week.

In fact, I'm testing your stealing patches on my add-hoc fragmentation
benchmark. It would be finished soon and, after that, I can resend this
patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
