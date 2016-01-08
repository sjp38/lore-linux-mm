Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F16C7828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 17:17:38 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so15386187pfn.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 14:17:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b27si7650005pfd.114.2016.01.08.14.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 14:17:38 -0800 (PST)
Date: Fri, 8 Jan 2016 14:17:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mlock.c: change can_do_mlock return value type to
 boolean
Message-Id: <20160108141737.76ccd8c350a028c47afc9c2f@linux-foundation.org>
In-Reply-To: <20160108203823.348f2a17@debian>
References: <20160108203823.348f2a17@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 8 Jan 2016 20:38:23 +0800 Wang Xiaoqiang <wangxq10@lzu.edu.cn> wrote:

> Since can_do_mlock only return 1 or 0, so make it boolean.
> 
> No functional change.
> 
> ...
>
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -24,13 +24,13 @@
>  
>  #include "internal.h"
>  
> -int can_do_mlock(void)
> +bool can_do_mlock(void)
>  {
>  	if (rlimit(RLIMIT_MEMLOCK) != 0)
> -		return 1;
> +		return true;
>  	if (capable(CAP_IPC_LOCK))
> -		return 1;
> -	return 0;
> +		return true;
> +	return false;
>  }
>  EXPORT_SYMBOL(can_do_mlock);

Please never send untested patches.  Ever.

--- a/include/linux/mm.h~mm-mlockc-change-can_do_mlock-return-value-type-to-boolean-fix
+++ a/include/linux/mm.h
@@ -1100,7 +1100,7 @@ static inline bool shmem_mapping(struct
 }
 #endif
 
-extern int can_do_mlock(void);
+extern bool can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
 extern void user_shm_unlock(size_t, struct user_struct *);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
