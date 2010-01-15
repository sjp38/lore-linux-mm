Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B4CE6B007B
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 01:21:47 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0F6LiBu014977
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 15 Jan 2010 15:21:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 83CAC45DE4E
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 15:21:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 666F545DE4C
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 15:21:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 495051DB8037
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 15:21:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EE2AB1DB8038
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 15:21:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: OOM-Killed process don't invoke pagefault-oom
In-Reply-To: <20100114130257.GB8381@laptop>
References: <20100114191940.6749.A69D9226@jp.fujitsu.com> <20100114130257.GB8381@laptop>
Message-Id: <20100115085146.6EC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Jan 2010 15:21:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> I don't think this should be required, because the oom killer does not
> kill a new task if there is already one in memdie state.
> 
> If you have any further tweaks to the heuristic (such as a fatal signal
> pending), then it should probably go in select_bad_process() or
> somewhere like that.

I see, I misunderstood. very thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
