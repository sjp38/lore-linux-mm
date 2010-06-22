Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A96B56B01AF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 22:59:46 -0400 (EDT)
Date: Tue, 22 Jun 2010 10:59:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: your mail
Message-ID: <20100622025941.GA6147@localhost>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276706031-29421-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> - use tagging also for WB_SYNC_NONE writeback - there's problem with an
>   interaction with wbc->nr_to_write. If we tag all dirty pages, we can
>   spend too much time tagging when we write only a few pages in the end
>   because of nr_to_write. If we tag only say nr_to_write pages, we may
>   not have enough pages tagged because some pages are written out by
>   someone else and so we would have to restart and tagging would become

This could be addressed by ignoring nr_to_write for the WB_SYNC_NONE
writeback triggered by sync(). write_cache_pages() already ignored
nr_to_write for WB_SYNC_ALL.

>   essentially useless. So my option is - switch to tagging for WB_SYNC_NONE
>   writeback if we can get rid of nr_to_write. But that's a story for
>   a different patch set.

Besides introducing overheads, it will be a policy change in which the
system loses control to somehow "throttle" writeback of huge files.

So it may be safer to enlarge nr_to_write instead of canceling it totally.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
