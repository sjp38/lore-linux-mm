Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9771A6B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 03:21:25 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I8LMpv029173
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 17:21:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B4072AEA8E
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 17:21:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B69F1EF0A4
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 17:21:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DC07E38009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 17:21:22 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F5AE38003
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 17:21:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: OOM-Killed process don't invoke pagefault-oom
In-Reply-To: <20100118072946.GA10052@laptop>
References: <20100115085146.6EC0.A69D9226@jp.fujitsu.com> <20100118072946.GA10052@laptop>
Message-Id: <20100118172032.5F1C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Jan 2010 17:21:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Jan 15, 2010 at 03:21:40PM +0900, KOSAKI Motohiro wrote:
> > > Hi,
> > > 
> > > I don't think this should be required, because the oom killer does not
> > > kill a new task if there is already one in memdie state.
> > > 
> > > If you have any further tweaks to the heuristic (such as a fatal signal
> > > pending), then it should probably go in select_bad_process() or
> > > somewhere like that.
> > 
> > I see, I misunderstood. very thanks.
> 
> Well, it *might* be a good idea to check for fatal signal pending
> similar your patch. Because I think there could be large latency between
> the signal and the task moving to exit state if the process is waiting
> uninterruptible in the kernel for a while.
> 
> But if you do it in select_bad_process() then it would work for all
> classes of oom kill.

Thank you for good advise. I'll make next version so :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
