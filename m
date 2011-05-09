Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 31D956B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:40:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E35693EE0AE
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:40:00 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B484445DF43
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:40:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BC1B45DEE6
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:40:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CFECE08002
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:40:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FC41DB8037
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:40:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] mm: export get_vma_policy()
In-Reply-To: <1303947349-3620-2-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-2-git-send-email-wilsons@start.ca>
Message-Id: <20110509164143.1650.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 16:39:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 31ac26c..c2f6032 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -199,6 +199,9 @@ void mpol_free_shared_policy(struct shared_policy *p);
>  struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
>  					    unsigned long idx);
>  
> +struct mempolicy *get_vma_policy(struct task_struct *tsk,
> +		struct vm_area_struct *vma, unsigned long addr);
> +
>  extern void numa_default_policy(void);
>  extern void numa_policy_init(void);
>  extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 959a8b8..5bfb03e 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1489,7 +1489,7 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
>   * freeing by another task.  It is the caller's responsibility to free the
>   * extra reference for shared policies.
>   */
> -static struct mempolicy *get_vma_policy(struct task_struct *task,
> +struct mempolicy *get_vma_policy(struct task_struct *task,
>  		struct vm_area_struct *vma, unsigned long addr)

Looks reasonable to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
