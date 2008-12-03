Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB37JPRe017635
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Dec 2008 16:19:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75BFD45DD7E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:19:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E278645DD78
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:19:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 739CA1DB8037
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:19:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 635711DB804A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 16:19:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][V7]make get_user_pages interruptible
In-Reply-To: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
Message-Id: <20081203161834.1D4A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Dec 2008 16:19:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

> From: Ying Han <yinghan@google.com>
> 
> make get_user_pages interruptible
> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
> return immediately. This patch includes:
> 
> 1. add the case that the SIGKILL is sent by user processes. The process can
> try to get_user_pages() unlimited memory even if a user process has sent a
> SIGKILL to it(maybe a monitor find the process exceed its memory limit and
> try to kill it). In the old implementation, the SIGKILL won't be handled
> until the get_user_pages() returns.
> 
> 2. change the return value to be ERESTARTSYS. It makes no sense to return
> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
> Considering the general convention for a system call interrupted by a
> signal is ERESTARTNOSYS, so the current return value is consistant to that.
> 
> Signed-off-by:	Paul Menage <menage@google.com>
> Signed-off-by:	Ying Han <yinghan@google.com>

looks good to me.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thnaks, Ying!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
