Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D69E5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 05:40:06 -0500 (EST)
Subject: Re: [BUG??] Deadlock between kswapd and
 sys_inotify_add_watch(lockdep  report)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com>
References: <20090202101735.GA12757@barrios-desktop>
	 <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 11:40:02 +0100
Message-Id: <1233571202.4787.124.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-02 at 19:25 +0900, MinChan Kim wrote:
> But, I am not sure whether it's real bug or not.

Me neither, inode life-times are tricky, but on first sight it looks
real enough.

> I always suffer from reading lockdep report's result. :(
> It would be better to have a document about lockdep report analysis.

I've never found them hard to read, so I'm afraid you'll have to be more
explicit about what is unclear to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
