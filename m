Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7394C6B01E3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg6Rh012501
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3673845DE7A
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 086C945DE80
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99681E3800B
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC811E38014
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 14/18] oom: move sysctl declarations to oom.h
In-Reply-To: <alpine.DEB.2.00.1006061526260.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526260.32225@chino.kir.corp.google.com>
Message-Id: <20100608203733.7678.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The three oom killer sysctl variables (sysctl_oom_dump_tasks,
> sysctl_oom_kill_allocating_task, and sysctl_panic_on_oom) are better
> declared in include/linux/oom.h rather than kernel/sysctl.c.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/oom.h |    5 +++++
>  kernel/sysctl.c     |    4 +---
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -44,5 +44,10 @@ static inline void oom_killer_enable(void)
>  {
>  	oom_killer_disabled = false;
>  }
> +
> +/* sysctls */
> +extern int sysctl_oom_dump_tasks;
> +extern int sysctl_oom_kill_allocating_task;
> +extern int sysctl_panic_on_oom;
>  #endif /* __KERNEL__*/
>  #endif /* _INCLUDE_LINUX_OOM_H */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -55,6 +55,7 @@
>  #include <linux/perf_event.h>
>  #include <linux/kprobes.h>
>  #include <linux/pipe_fs_i.h>
> +#include <linux/oom.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/processor.h>
> @@ -87,9 +88,6 @@
>  /* External variables not in a header file. */
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
> -extern int sysctl_panic_on_oom;
> -extern int sysctl_oom_kill_allocating_task;
> -extern int sysctl_oom_dump_tasks;
>  extern int max_threads;
>  extern int core_uses_pid;
>  extern int suid_dumpable;

pulled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
