Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B917F5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:09:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E1E7482C341
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:18:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5jg5u+uZqhqV for <linux-mm@kvack.org>;
	Tue,  7 Apr 2009 17:18:52 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4B2B982C35D
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 17:18:46 -0400 (EDT)
Date: Tue, 7 Apr 2009 17:04:17 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/3] cpuset,mm: fix memory spread bug
In-Reply-To: <49DB306A.8070407@cn.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0904071703340.12192@qirst.com>
References: <49DB306A.8070407@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Interesting patch set but I cannot find parts 2 and 3. The locking changes
get rid of the generation scheme in cpusets which is a good thing if it
works right.

On Tue, 7 Apr 2009, Miao Xie wrote:

> The kernel still allocated the page caches on old node after modifying its
> cpuset's mems when 'memory_spread_page' was set, or it didn't spread the page
> cache evenly over all the nodes that faulting task is allowed to usr after
> memory_spread_page was set. it is caused by the old mem_allowed and flags
> of the task, the current kernel doesn't updates them unless some function
> invokes cpuset_update_task_memory_state(), it is too late sometimes.We must
> update the mem_allowed and the flags of the tasks in time.
>
> Slab has the same problem.
>
> The following patches fix this bug by updating tasks' mem_allowed and spread
> flag after its cpuset's mems or spread flag is changed.
>
> patch 1: restructure the function cpuset_update_task_memory_state()
> patch 2: update tasks' page/slab spread flags in time
> patch 3: update tasks' mems_allowed in time
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
