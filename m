Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 47BDA6B012E
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 03:29:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q7TYR8004475
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Aug 2009 16:29:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFD5745DE51
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:29:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A107E45DE4F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:29:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89F251DB8038
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:29:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 484071DB803E
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:29:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: move oom_killer_enable()/oom_killer_disable to where they belong
In-Reply-To: <20090821191925.GA5367@x200.localdomain>
References: <20090821191925.GA5367@x200.localdomain>
Message-Id: <20090826162812.3964.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Aug 2009 16:29:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---

Please write proper patch description...

However, I think the code itself is right.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 
>  include/linux/gfp.h    |   12 ------------
>  include/linux/oom.h    |   11 +++++++++++
>  kernel/power/process.c |    1 +
>  3 files changed, 12 insertions(+), 12 deletions(-)
> 
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -336,18 +336,6 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
>  void drain_all_pages(void);
>  void drain_local_pages(void *dummy);
>  
> -extern bool oom_killer_disabled;
> -
> -static inline void oom_killer_disable(void)
> -{
> -	oom_killer_disabled = true;
> -}
> -
> -static inline void oom_killer_enable(void)
> -{
> -	oom_killer_disabled = false;
> -}
> -
>  extern gfp_t gfp_allowed_mask;
>  
>  static inline void set_gfp_allowed_mask(gfp_t mask)
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -30,5 +30,16 @@ extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
>  
> +extern bool oom_killer_disabled;
> +
> +static inline void oom_killer_disable(void)
> +{
> +	oom_killer_disabled = true;
> +}
> +
> +static inline void oom_killer_enable(void)
> +{
> +	oom_killer_disabled = false;
> +}
>  #endif /* __KERNEL__*/
>  #endif /* _INCLUDE_LINUX_OOM_H */
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -9,6 +9,7 @@
>  #undef DEBUG
>  
>  #include <linux/interrupt.h>
> +#include <linux/oom.h>
>  #include <linux/suspend.h>
>  #include <linux/module.h>
>  #include <linux/syscalls.h>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
