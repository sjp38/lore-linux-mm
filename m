Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A26C6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 19:02:50 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so127213172pac.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 16:02:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p6si20629693pfi.102.2016.07.29.16.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 16:02:49 -0700 (PDT)
Date: Fri, 29 Jul 2016 16:02:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs: wipe off the compiler warn
Message-Id: <20160729160247.564e27525f04416ef714ddd4@linux-foundation.org>
In-Reply-To: <1469803600-44293-1-git-send-email-zhongjiang@huawei.com>
References: <1469803600-44293-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 29 Jul 2016 22:46:39 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> when compile the kenrel code, I happens to the following warn.
> fs/reiserfs/ibalance.c:1156:2: warning: ___new_insert_key___ may be used
> uninitialized in this function.
> memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
> ^
> The patch just fix it to avoid the warn.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  fs/reiserfs/ibalance.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/reiserfs/ibalance.c b/fs/reiserfs/ibalance.c
> index b751eea..512ce95 100644
> --- a/fs/reiserfs/ibalance.c
> +++ b/fs/reiserfs/ibalance.c
> @@ -818,7 +818,7 @@ int balance_internal(struct tree_balance *tb,
>  	int order;
>  	int insert_num, n, k;
>  	struct buffer_head *S_new;
> -	struct item_head new_insert_key;
> +	struct item_head uninitialized_var(new_insert_key);
>  	struct buffer_head *new_insert_ptr = NULL;
>  	struct item_head *new_insert_key_addr = insert_key;

How do we know this isn't a real bug?  It isn't obvious to me that this
warning is a false positive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
