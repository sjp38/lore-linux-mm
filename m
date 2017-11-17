Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 537B46B0253
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 12:58:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n89so2929501pfk.17
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 09:58:27 -0800 (PST)
Received: from out0-207.mail.aliyun.com (out0-207.mail.aliyun.com. [140.205.0.207])
        by mx.google.com with ESMTPS id t1si3094932pgc.703.2017.11.17.09.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 09:58:26 -0800 (PST)
Subject: Re: [PATCH v2] mm: filemap: remove include of hardirq.h
References: <1509985319-38633-1-git-send-email-yang.s@alibaba-inc.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <43348133-9c30-4c4f-8bc9-498841a01bd6@alibaba-inc.com>
Date: Sat, 18 Nov 2017 01:58:15 +0800
MIME-Version: 1.0
In-Reply-To: <1509985319-38633-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, willy@infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi folks,

Any comment on this patch? The quick build test passed on the latest 
Linus's tree.

Thanks,
Yang


On 11/6/17 8:21 AM, Yang Shi wrote:
> in_atomic() has been moved to include/linux/preempt.h, and the filemap.c
> doesn't use in_atomic() directly at all, so it sounds unnecessary to
> include hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
> v1 --> v2:
> * Removed the wrong message about kernel size change
> 
>   mm/filemap.c | 1 -
>   1 file changed, 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 594d73f..57238f4 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -31,7 +31,6 @@
>   #include <linux/blkdev.h>
>   #include <linux/security.h>
>   #include <linux/cpuset.h>
> -#include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>   #include <linux/hugetlb.h>
>   #include <linux/memcontrol.h>
>   #include <linux/cleancache.h>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
