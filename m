Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E536F6B0089
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:51:17 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [resend][PATCH 3/4] move cred_guard_mutex from task_struct to
	signal_struct
In-Reply-To: Oleg Nesterov's message of  Monday, 25 October 2010 19:42:20 +0200 <20101025174220.GA21375@redhat.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com>
	<20101025122801.9170.A69D9226@jp.fujitsu.com>
	<20101025172657.A9EC9C9E3C@blackie.sf.frob.com>
	<20101025174220.GA21375@redhat.com>
Message-Id: <20101025175113.963CCC9E3C@blackie.sf.frob.com>
Date: Mon, 25 Oct 2010 13:51:13 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Except: I am not sure about -stable. At least, this patch should
> not go into the <2.6.35 kernels, it relies on misc changes which
> changed the scope of task->signal. Before 2.6.35 almost any user
> of ->cred_guard_mutex can race with exit and hit ->signal == NULL.

I see no justification for a change like this in any -stable tree.  It's
just a cleanup, right?  If it's a prerequisite for the fix we like for an
"important" bug, then that's a different story.  In its own right, it's
clearly not appropriate for backporting.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
