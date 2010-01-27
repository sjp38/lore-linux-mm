Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8A6AE6B007E
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 02:09:42 -0500 (EST)
Received: by pwj10 with SMTP id 10so4412384pwj.6
        for <linux-mm@kvack.org>; Tue, 26 Jan 2010 23:09:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100121054734.GC24236@localhost>
References: <20100120215536.GN27212@frostnet.net>
	 <20100121054734.GC24236@localhost>
Date: Wed, 27 Jan 2010 16:09:40 +0900
Message-ID: <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chris Frost <frost@cs.ucla.edu>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

Hi, Wu.

I have missed this thread until now.
Before review, first of all, Thanks for adding to good feature, Chris and Wu.
I have some questions.

2010/1/21 Wu Fengguang <fengguang.wu@intel.com>:

> Years ago I wrote a similar function, which can be called for both
> in-kernel-readahead (when it decides not to bring in new pages, but
> only retain existing pages) and fadvise-readahead (where it want to
> read new pages as well as retain existing pages).

Why doesn't it merged into mainline?
It's private patch or has some problem?

Actually I am worried about this patch.
That's because it makes shortcut promotion in reclaim exceptionally.

Of course If readahead is working well, this patch effect also would
be good. But let's think about it.

This patch effect happens when inactive file list is small, I think.
It means it's high memory pressure. so if we move ra pages into
head of inactive list, other application which require free page urgently
suffer from latency or are killed.

If VM don't have this patch, of course ra pages are discarded and
then I/O performance would be bad. but as I mentioned, it's time
high memory pressure. so I/O performance low makes system
natural throttling. It can help out of  system memory pressure.

In summary I think it's good about viewpoint of I/O but I am not sure
it's good about viewpoint of system.

I will review this patch after my concern is solved. :)
Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
