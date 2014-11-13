Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 62EFE6B00DC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 21:55:48 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id u7so9223874qaz.25
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 18:55:48 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id c90si44467602qgf.111.2014.11.12.18.55.47
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 18:55:47 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id DAEA5101383
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 21:55:43 -0500 (EST)
Date: Wed, 12 Nov 2014 20:55:44 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zswap: add __init to some functions in zswap
Message-ID: <20141113025544.GB9068@medulla.variantweb.net>
References: <1415535832-4822-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415535832-4822-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Nov 09, 2014 at 08:23:52PM +0800, Mahendran Ganesh wrote:
> zswap_cpu_init/zswap_comp_exit/zswap_entry_cache_create is only
> called by __init init_zswap()

Thanks for the cleanup!

Acked-by: Seth Jennings <sjennings@variantweb.net>

> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  mm/zswap.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 51a2c45..2e621fa 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -149,7 +149,7 @@ static int __init zswap_comp_init(void)
>  	return 0;
>  }
>  
> -static void zswap_comp_exit(void)
> +static void __init zswap_comp_exit(void)
>  {
>  	/* free percpu transforms */
>  	if (zswap_comp_pcpu_tfms)
> @@ -206,7 +206,7 @@ static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
>  **********************************/
>  static struct kmem_cache *zswap_entry_cache;
>  
> -static int zswap_entry_cache_create(void)
> +static int __init zswap_entry_cache_create(void)
>  {
>  	zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
>  	return zswap_entry_cache == NULL;
> @@ -389,7 +389,7 @@ static struct notifier_block zswap_cpu_notifier_block = {
>  	.notifier_call = zswap_cpu_notifier
>  };
>  
> -static int zswap_cpu_init(void)
> +static int __init zswap_cpu_init(void)
>  {
>  	unsigned long cpu;
>  
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
