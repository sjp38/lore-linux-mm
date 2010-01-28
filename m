Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 010746B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 02:16:56 -0500 (EST)
Date: Wed, 27 Jan 2010 23:16:49 -0800 (PST)
From: Steve VanDeBogart <vandebo-lkml@NerdBox.Net>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
 pages, too
In-Reply-To: <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
Message-ID: <alpine.DEB.1.00.1001272300120.2909@abydos.NerdBox.Net>
References: <20100120215536.GN27212@frostnet.net>  <20100121054734.GC24236@localhost> <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Chris Frost <frost@cs.ucla.edu>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010, Minchan Kim wrote:

> This patch effect happens when inactive file list is small, I think.
> It means it's high memory pressure. so if we move ra pages into

This patch does the same thing regardless of memory pressure - it
doesn't just apply in high memory pressure situations.  Is your concern
that in high memory pressure situations this patch with make things worse?

> head of inactive list, other application which require free page urgently
> suffer from latency or are killed.

I don't think this patch will affect the number of pages reclaimed, only
which pages are reclaimed.  In extreme cases it could increase the time
needed to reclaim that many pages, but the inactive list would have to be
very short.

> If VM don't have this patch, of course ra pages are discarded and
> then I/O performance would be bad. but as I mentioned, it's time
> high memory pressure. so I/O performance low makes system
> natural throttling. It can help out of  system memory pressure.

Even in low memory situations, improving I/O performance can help the
overall system performance.  For example if most of the inactive list 
is dirty, needlessly discarding pages, just to refetch them will clog
I/O and increase the time needed to write out the dirty pages.

> In summary I think it's good about viewpoint of I/O but I am not sure
> it's good about viewpoint of system.

In this case, I think what's good for I/O is good for the system.
Please help me understand if I am missing something.  Thanks

--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
