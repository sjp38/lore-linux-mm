Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id EB8C08D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:59:37 -0400 (EDT)
Date: Thu, 8 Aug 2013 14:59:36 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 1/2] mm: make vmstat_update periodic run conditional
In-Reply-To: <CAOtvUMe=QQni4Ouu=P_vh8QSb4ZdnaX_fW1twn3QFcOjYgJBGA@mail.gmail.com>
Message-ID: <000001405e70a92f-3b2a0b89-f807-45d7-af70-9e7292156dd4-000000@email.amazonses.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com> <1371672168-9869-1-git-send-email-gilad@benyossef.com> <0000013f61e7609b-a8d1907b-8169-4f77-ab83-a624a8d0ab4a-000000@email.amazonses.com>
 <CAOtvUMe=QQni4Ouu=P_vh8QSb4ZdnaX_fW1twn3QFcOjYgJBGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, 8 Aug 2013, Gilad Ben-Yossef wrote:

> vmstat_update runs from the vmstat work queue item by the workqueue
> kernel thread.
>
> If this code is running, it means there are at least two schedulable tasks:
> 1. The workqueue kernel thread, because it is running.
> 2. At least one more task, otherwise were were in idle and the
> workqueue kernel thread
> would not execute this work item.
>
> Unfortunately, having two schedulable tasks means we're not running
> tickless, so the check
> will never trigger - or have I've missed something obvious?

The vmstat update is deferrable work. As such it is not required to run
and can be pushed off. It will not be considered for the calculation of
the next timer interupt. See __next_timer_interrupt().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
