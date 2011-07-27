Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5291C6B00EE
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 20:35:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 94E903EE0AE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:35:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED3D45DE56
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:35:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 59CD945DE58
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:35:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D5FB1DB8051
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:35:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 188AE1DB804C
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:35:44 +0900 (JST)
Message-ID: <4E2F5D5D.10901@jp.fujitsu.com>
Date: Wed, 27 Jul 2011 09:35:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] oom: avoid killing kthreads if they assume the oom killed
 thread's mm
References: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

(2011/07/26 9:12), David Rientjes wrote:
> After selecting a task to kill, the oom killer iterates all processes and
> kills all other threads that share the same mm_struct in different thread
> groups.  It would not otherwise be helpful to kill a thread if its memory
> would not be subsequently freed.
> 
> A kernel thread, however, may assume a user thread's mm by using
> use_mm().  This is only temporary and should not result in sending a
> SIGKILL to that kthread.
> 
> This patch ensures that only user threads and not kthreads are sent a
> SIGKILL if they share the same mm_struct as the oom killed task.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
