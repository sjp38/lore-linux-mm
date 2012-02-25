Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 18D016B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 22:27:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1F3093EE0AE
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 12:27:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0507645DE4F
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 12:27:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DFECD45DE4D
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 12:27:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E611DB8037
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 12:27:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C1011DB802F
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 12:27:15 +0900 (JST)
Date: Sat, 25 Feb 2012 12:25:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm, oom: force oom kill on sysrq+f
Message-Id: <20120225122533.b621f78f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 22 Feb 2012 16:03:42 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> The oom killer chooses not to kill a thread if:
> 
>  - an eligible thread has already been oom killed and has yet to exit,
>    and
> 
>  - an eligible thread is exiting but has yet to free all its memory and
>    is not the thread attempting to currently allocate memory.
> 
> SysRq+F manually invokes the global oom killer to kill a memory-hogging
> task.  This is normally done as a last resort to free memory when no
> progress is being made or to test the oom killer itself.
> 
> For both uses, we always want to kill a thread and never defer.  This
> patch causes SysRq+F to always kill an eligible thread and can be used to
> force a kill even if another oom killed thread has failed to exit.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Seems nice!.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
