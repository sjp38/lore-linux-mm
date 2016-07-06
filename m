Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87DCC828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 04:20:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so497078660pfx.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 01:20:12 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id ud9si2767852pab.247.2016.07.06.01.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 01:20:11 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id us13so20472801pab.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 01:20:11 -0700 (PDT)
Date: Wed, 6 Jul 2016 16:20:05 +0800
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH v3 6/8] mm/zsmalloc: add __init,__exit attribute
Message-ID: <20160706082005.GA3922@leo-test>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
 <1467786233-4481-6-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467786233-4481-6-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Wed, Jul 06, 2016 at 02:23:51PM +0800, Ganesh Mahendran wrote:
> Add __init,__exit attribute for function that only called in
> module init/exit to save memory.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ----
> v3:
>     revert change in v2 - Sergey
> v2:
>     add __init/__exit for zs_register_cpu_notifier/zs_unregister_cpu_notifier
> ---
>  mm/zsmalloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index ded312b..46526b9 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1344,7 +1344,7 @@ static void zs_unregister_cpu_notifier(void)
>  	cpu_notifier_register_done();
>  }
>  
> -static void init_zs_size_classes(void)
> +static void __init init_zs_size_classes(void)
>  {
>  	int nr;
>  
> @@ -1887,7 +1887,7 @@ static struct file_system_type zsmalloc_fs = {
>  	.kill_sb	= kill_anon_super,
>  };
>  
> -static int zsmalloc_mount(void)
> +static int __init zsmalloc_mount(void)
>  {
>  	int ret = 0;
>  
> @@ -1898,7 +1898,7 @@ static int zsmalloc_mount(void)
>  	return ret;
>  }
>  
> -static void zsmalloc_unmount(void)
> +static void __exit zsmalloc_unmount(void)
>  {
>  	kern_unmount(zsmalloc_mnt);
>  }

Sorry, the __exit zsmalloc_umount is called in __init zs_init.

updated patch is :

---
