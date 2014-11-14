Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EE4106B00CC
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:58:44 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id hz1so6340478pad.13
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 04:58:44 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id yk2si28282314pbc.140.2014.11.14.04.58.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 04:58:43 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so2705600pad.17
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 04:58:43 -0800 (PST)
Date: Fri, 14 Nov 2014 21:59:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 2/3] mm/zsmalloc: add __init/__exit to zs_init/zs_exit
Message-ID: <20141114125900.GA1007@swordfish>
References: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
 <1415885857-5283-2-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415885857-5283-2-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/13/14 21:37), Mahendran Ganesh wrote:
> After patch [1], the zs_exit is only called in module exit.
> So add __init/__exit to zs_init/zs_exit.
> 
>   [1] mm/zsmalloc: avoid unregister a NOT-registered zsmalloc zpool driver
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>

makes sense.

	-ss

> ---
>  mm/zsmalloc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 3d2bb36..92af030 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -881,7 +881,7 @@ static struct notifier_block zs_cpu_nb = {
>  	.notifier_call = zs_cpu_notifier
>  };
>  
> -static void zs_exit(void)
> +static void __exit zs_exit(void)
>  {
>  	int cpu;
>  
> @@ -898,7 +898,7 @@ static void zs_exit(void)
>  	cpu_notifier_register_done();
>  }
>  
> -static int zs_init(void)
> +static int __init zs_init(void)
>  {
>  	int cpu, ret;
>  
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
