Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8630A6B00BF
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 19:47:24 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oA3NlKdh028033
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 16:47:20 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe17.cbf.corp.google.com with ESMTP id oA3NkR5T007936
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 16:47:19 -0700
Received: by pwj6 with SMTP id 6so498688pwj.18
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 16:47:19 -0700 (PDT)
Date: Wed, 3 Nov 2010 16:47:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <1288827804.2725.0.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1288827804.2725.0.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 2010, Figo.zhang wrote:

> CAP_SYS_RESOURCE also had better get 3% bonus for protection.
> 

Would you like to elaborate as to why?

> Signed-off-by: Figo.zhang <figo1802@gmail.com>
> --- 
> mm/oom_kill.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4029583..30b24b9 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -198,7 +198,8 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	 * Root processes get 3% bonus, just like the __vm_enough_memory()
>  	 * implementation used by LSMs.
>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
>  		points -= 30;
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
