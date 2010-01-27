Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F7996B0071
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 07:22:08 -0500 (EST)
Date: Wed, 27 Jan 2010 20:21:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100127122157.GA4545@localhost>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost> <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Frost <frost@cs.ucla.edu>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

On Wed, Jan 27, 2010 at 09:09:40AM +0200, Minchan Kim wrote:
> Hi, Wu.
> 
> I have missed this thread until now.
> Before review, first of all, Thanks for adding to good feature, Chris and Wu.
> I have some questions.
> 
> 2010/1/21 Wu Fengguang <fengguang.wu@intel.com>:
> 
> > Years ago I wrote a similar function, which can be called for both
> > in-kernel-readahead (when it decides not to bring in new pages, but
> > only retain existing pages) and fadvise-readahead (where it want to
> > read new pages as well as retain existing pages).
> 
> Why doesn't it merged into mainline?
> It's private patch or has some problem?

It's part of the early adaptive readahead patchset, which is too
complex to be acceptable to mainline.

> Actually I am worried about this patch.
> That's because it makes shortcut promotion in reclaim exceptionally.
> 
> Of course If readahead is working well, this patch effect also would
> be good. But let's think about it.
> 
> This patch effect happens when inactive file list is small, I think.
> It means it's high memory pressure. so if we move ra pages into
> head of inactive list, other application which require free page urgently
> suffer from latency or are killed.
> 
> If VM don't have this patch, of course ra pages are discarded and
> then I/O performance would be bad. but as I mentioned, it's time
> high memory pressure. so I/O performance low makes system
> natural throttling. It can help out of  system memory pressure.
> 
> In summary I think it's good about viewpoint of I/O but I am not sure
> it's good about viewpoint of system.
> 
> I will review this patch after my concern is solved. :)

That's legitimate concern. I'm now including this patch in a bigger
patchset to do adaptive (wrt. thrashing safety) readahead, which will
automatically back off readahead size when thrashing happened. I hope
that would address your concern.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
