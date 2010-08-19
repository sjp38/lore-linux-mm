Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B283A6B0201
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:06:50 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100819220338.5FD5.A69D9226@jp.fujitsu.com>
References: <20100819220338.5FD5.A69D9226@jp.fujitsu.com>
Subject: Re: oom: __task_cred() need rcu_read_lock()
Date: Thu, 19 Aug 2010 16:06:34 +0100
Message-ID: <7682.1282230394@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: dhowells@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> dump_tasks() can call __task_cred() safely because we are holding
> tasklist_lock. but rcu lock validator don't have enough knowledge and
> it makes following annoying warning.

No, it can't.  The tasklist_lock is not protection against the creds changing
on another CPU.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
