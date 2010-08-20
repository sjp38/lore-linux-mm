Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2839A6B0201
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:08:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K08snI030060
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 20 Aug 2010 09:08:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 73ADA45DE4F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:08:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AFD145DE54
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:08:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 137211DB803C
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:08:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B068DE08003
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:08:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom: __task_cred() need rcu_read_lock()
In-Reply-To: <7682.1282230394@redhat.com>
References: <20100819220338.5FD5.A69D9226@jp.fujitsu.com> <7682.1282230394@redhat.com>
Message-Id: <20100820084820.5FDB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Aug 2010 09:08:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > dump_tasks() can call __task_cred() safely because we are holding
> > tasklist_lock. but rcu lock validator don't have enough knowledge and
> > it makes following annoying warning.
> 
> No, it can't.  The tasklist_lock is not protection against the creds changing
> on another CPU.

Thank you for correction.

I suppose you mean I missed CONFIG_TREE_PREEMPT_RCU, right?
As far as my grepping, other rcu implementation and spinlock use 
preempt_disable(). In other word, Can I assume usual distro user 
don't hit this issue?

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
