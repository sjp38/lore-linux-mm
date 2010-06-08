Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D38D6B01E3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg1nN008040
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7781E45DE56
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A02845DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6391DB8043
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4DD21DB8037
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 10/18] oom: enable oom tasklist dump by default
In-Reply-To: <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com>
Message-Id: <20100608203540.766C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The oom killer tasklist dump, enabled with the oom_dump_tasks sysctl, is
> very helpful information in diagnosing why a user's task has been killed.
> It emits useful information such as each eligible thread's memory usage
> that can determine why the system is oom, so it should be enabled by
> default.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/sysctl/vm.txt |    2 +-
>  mm/oom_kill.c               |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -511,7 +511,7 @@ information may not be desired.
>  If this is set to non-zero, this information is shown whenever the
>  OOM killer actually kills a memory-hogging task.
>  
> -The default value is 0.
> +The default value is 1 (enabled).
>  
>  ==============================================================
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ef048c1..833de48 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -32,7 +32,7 @@
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> -int sysctl_oom_dump_tasks;
> +int sysctl_oom_dump_tasks = 1;
>  static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  

pulled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
