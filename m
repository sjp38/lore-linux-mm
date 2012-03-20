Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 521B96B004D
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 14:21:33 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by node6.dwd.de (Postfix) with ESMTP id 22852C58121
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 18:21:32 +0000 (UTC)
Received: from node6.dwd.de ([127.0.0.1])
	by localhost (node6.csg-cluster.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id lHHGlJ3fQeBN for <linux-mm@kvack.org>;
	Tue, 20 Mar 2012 18:21:31 +0000 (UTC)
Date: Tue, 20 Mar 2012 18:21:29 +0000 (GMT)
From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <4F68795E.9030304@kernel.org>
Message-ID: <alpine.LRH.2.02.1203201812260.18801@diagnostix.dwd.de>
References: <4F68795E.9030304@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

Hello,

just tested this patch and this solves my problem where I have very
long boot times and even some timeout problems.

Regards,
Holger


On Tue, 20 Mar 2012, Shaohua Li wrote:

>
> Even don't add discard option, swapon will do discard, this sounds buggy,
> especially when discard is slow or buggy.
>
> Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  mm/swapfile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2012-03-20 20:11:59.222767526 +0800
> +++ linux/mm/swapfile.c	2012-03-20 20:13:25.362767387 +0800
> @@ -2105,7 +2105,7 @@ SYSCALL_DEFINE2(swapon, const char __use
> 			 p->flags |= SWP_SOLIDSTATE;
> 			 p->cluster_next = 1 + (random32() % p->highest_bit);
> 		}
> -		if (discard_swap(p) == 0 && (swap_flags & SWAP_FLAG_DISCARD))
> +		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
> 	 		p->flags |= SWP_DISCARDABLE;
> 	 }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
