Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E34926B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 02:29:58 -0500 (EST)
Date: Mon, 18 Jan 2010 18:29:46 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] oom: OOM-Killed process don't invoke pagefault-oom
Message-ID: <20100118072946.GA10052@laptop>
References: <20100114191940.6749.A69D9226@jp.fujitsu.com>
 <20100114130257.GB8381@laptop>
 <20100115085146.6EC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100115085146.6EC0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 15, 2010 at 03:21:40PM +0900, KOSAKI Motohiro wrote:
> > Hi,
> > 
> > I don't think this should be required, because the oom killer does not
> > kill a new task if there is already one in memdie state.
> > 
> > If you have any further tweaks to the heuristic (such as a fatal signal
> > pending), then it should probably go in select_bad_process() or
> > somewhere like that.
> 
> I see, I misunderstood. very thanks.

Well, it *might* be a good idea to check for fatal signal pending
similar your patch. Because I think there could be large latency between
the signal and the task moving to exit state if the process is waiting
uninterruptible in the kernel for a while.

But if you do it in select_bad_process() then it would work for all
classes of oom kill.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
