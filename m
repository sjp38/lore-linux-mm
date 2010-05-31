Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 771536B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 19:49:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4VNmxK0013116
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 08:48:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9017E45DE4F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:48:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E06245DE4E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:48:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50A621DB8040
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:48:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 06C551DB8038
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:48:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] oom: the points calculation of child processes must use find_lock_task_mm() too
In-Reply-To: <20100531165658.GC9991@redhat.com>
References: <20100531183636.184C.A69D9226@jp.fujitsu.com> <20100531165658.GC9991@redhat.com>
Message-Id: <20100601084807.242D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 08:48:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> And, I think we need another patch on top of this one. Note that
> this list_for_each_entry(p->children) can only see the tasks forked
> by p, it can't see other children forked by its sub-threads.
> 
> IOW, we need
> 
> 	do {
> 		list_for_each_entry(c, &t->children, sibling) {
> 			...
> 		}
> 	} while_each_thread(p, t);
> 
> Probably the same for oom_kill_process().
> 
> What do you think?

Makes perfectly sense. I have to do it!

Thanks good reviewing!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
