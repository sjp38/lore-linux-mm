Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7CB2F6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 23:25:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M3PYFb012593
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Oct 2010 12:25:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9445F45DE55
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:25:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 691BA45DE52
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:25:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 253301DB8051
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:25:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C98D6E38002
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:25:32 +0900 (JST)
Date: Fri, 22 Oct 2010 12:20:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] nommu: add anonymous page memcg accounting
Message-Id: <20101022122010.793bebac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
References: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 07:28:08 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:

> Add the necessary calls to track VM anonymous page usage (only).
> 
> V3 changes:
> * Use vma->vm_mm instead of current->mm when charging pages, for clarity
> * Document that reclaim is not possible with only anonymous page accounting
>   so the OOM-killer is invoked when a limit is exceeded
> * Add TODO to implement file cache (reclaim) support or optimize away
>   page_cgroup->lru
> 
> V2 changes:
> * Added update of memory cgroup documentation
> * Clarify use of 'file' to distinguish anonymous mappings
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Thanks,

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, have you tried oom_notifier+NOMMU memory limit oom-killer ?
It may be a chance to implement a custom OOM-Killer in userland on
EMBEDED systems.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
