Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4BA76B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 20:08:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cx13so104541793pac.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 17:08:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c83si859362pfd.8.2016.07.03.17.08.41
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 17:08:41 -0700 (PDT)
Date: Mon, 4 Jul 2016 09:09:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 7/8] mm/zsmalloc: add __init,__exit attribute
Message-ID: <20160704000924.GF19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-7-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-7-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:05PM +0800, Ganesh Mahendran wrote:
> Add __init,__exit attribute for function that is only called in
> module init/exit

                   to save memory.

> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 6fc631a..1c7460b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1349,7 +1349,7 @@ static void zs_unregister_cpu_notifier(void)
>  	cpu_notifier_register_done();
>  }
>  
> -static void init_zs_size_classes(void)
> +static void __init init_zs_size_classes(void)
>  {
>  	int nr;
>  
> @@ -1896,7 +1896,7 @@ static struct file_system_type zsmalloc_fs = {
>  	.kill_sb	= kill_anon_super,
>  };
>  
> -static int zsmalloc_mount(void)
> +static int __init zsmalloc_mount(void)
>  {
>  	int ret = 0;
>  
> @@ -1907,7 +1907,7 @@ static int zsmalloc_mount(void)
>  	return ret;
>  }
>  
> -static void zsmalloc_unmount(void)
> +static void __exit zsmalloc_unmount(void)
>  {
>  	kern_unmount(zsmalloc_mnt);
>  }

Couldn't we do it for zs_[un]register_cpu_notifier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
