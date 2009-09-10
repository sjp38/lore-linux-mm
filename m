Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8327C6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 14:05:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CE32182C401
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 14:06:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jJf0nVw-lV3z for <linux-mm@kvack.org>;
	Thu, 10 Sep 2009 14:06:24 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2384D82C479
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 14:06:14 -0400 (EDT)
Date: Thu, 10 Sep 2009 14:03:55 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <20090910083340.9CB7.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0909101402340.13682@V090114053VZO-1>
References: <20090909131945.0CF5.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0909091005010.28070@V090114053VZO-1> <20090910083340.9CB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009, KOSAKI Motohiro wrote:

> How about this?
>   - pass 1-2,  lru_add_drain_all_async()
>   - pass 3-10, lru_add_drain_all()
>
> this scheme might save RT-thread case and never cause regression. (I think)

Sounds good.

> The last remain problem is, if RT-thread binding cpu's pagevec has migrate
> targetted page, migration still face the same issue.
> but we can't solve it...
> RT-thread must use /proc/sys/vm/drop_caches properly.

A system call "sys_os_quiet_down" may be useful. It would drain all
caches, fold counters etc etc so that there will be no OS activities
needed for those things later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
