Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 861066B0268
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:12:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so6438421pfi.2
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:12:59 -0800 (PST)
Received: from out0-219.mail.aliyun.com (out0-219.mail.aliyun.com. [140.205.0.219])
        by mx.google.com with ESMTPS id o30si4165319pgn.211.2017.12.07.11.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:12:57 -0800 (PST)
Subject: Re: [PATCH 4/8] vfs: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-4-git-send-email-yang.s@alibaba-inc.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <0bfadf85-b499-5d2f-f0d2-20d229ba7fe2@alibaba-inc.com>
Date: Fri, 08 Dec 2017 03:12:52 +0800
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-4-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>

Hi folks,

Any comment on this one?

Thanks,
Yang


On 11/17/17 3:02 PM, Yang Shi wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by vfs at all.
> 
> So, remove the unused hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> ---
>   fs/dcache.c     | 1 -
>   fs/file_table.c | 1 -
>   2 files changed, 2 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index f901413..9340e8c 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -32,7 +32,6 @@
>   #include <linux/swap.h>
>   #include <linux/bootmem.h>
>   #include <linux/fs_struct.h>
> -#include <linux/hardirq.h>
>   #include <linux/bit_spinlock.h>
>   #include <linux/rculist_bl.h>
>   #include <linux/prefetch.h>
> diff --git a/fs/file_table.c b/fs/file_table.c
> index 61517f5..dab099e 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -23,7 +23,6 @@
>   #include <linux/sysctl.h>
>   #include <linux/percpu_counter.h>
>   #include <linux/percpu.h>
> -#include <linux/hardirq.h>
>   #include <linux/task_work.h>
>   #include <linux/ima.h>
>   #include <linux/swap.h>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
