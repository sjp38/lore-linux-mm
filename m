Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C19396B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 09:04:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9QD4rIS024726
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 Oct 2010 22:04:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 04BAC45DE52
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:04:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D113545DE4E
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:04:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B5D481DB803C
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:04:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B3641DB8038
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:04:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 3/4] move cred_guard_mutex from task_struct to signal_struct
In-Reply-To: <20101025175113.963CCC9E3C@blackie.sf.frob.com>
References: <20101025174220.GA21375@redhat.com> <20101025175113.963CCC9E3C@blackie.sf.frob.com>
Message-Id: <20101026220314.B7DD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Oct 2010 22:04:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

> > Except: I am not sure about -stable. At least, this patch should
> > not go into the <2.6.35 kernels, it relies on misc changes which
> > changed the scope of task->signal. Before 2.6.35 almost any user
> > of ->cred_guard_mutex can race with exit and hit ->signal == NULL.
> 
> I see no justification for a change like this in any -stable tree.  It's
> just a cleanup, right?  If it's a prerequisite for the fix we like for an
> "important" bug, then that's a different story.  In its own right, it's
> clearly not appropriate for backporting.

Because [4/4] depend on [3/4] and I hope to backport it. Do you dislike it
too?


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
