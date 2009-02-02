Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F4D75F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 05:25:28 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 36so450813yxh.26
        for <linux-mm@kvack.org>; Mon, 02 Feb 2009 02:25:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090202101735.GA12757@barrios-desktop>
References: <20090202101735.GA12757@barrios-desktop>
Date: Mon, 2 Feb 2009 19:25:27 +0900
Message-ID: <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com>
Subject: Re: [BUG??] Deadlock between kswapd and sys_inotify_add_watch(lockdep
	report)
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>
Cc: linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

But, I am not sure whether it's real bug or not.
I always suffer from reading lockdep report's result. :(
It would be better to have a document about lockdep report analysis.
-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
