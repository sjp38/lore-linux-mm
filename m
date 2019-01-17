Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91AE78E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:36:08 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j30so4678823wre.16
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:36:08 -0800 (PST)
Received: from delany.relativists.org (delany.relativists.org. [176.31.98.17])
        by mx.google.com with ESMTPS id f15si49037140wrt.372.2019.01.17.02.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 02:36:06 -0800 (PST)
Date: Thu, 17 Jan 2019 07:36:02 -0300
From: Adeodato =?utf-8?B?U2ltw7M=?= <dato@net.com.org.es>
Subject: Re: [PATCH 1/3] mm: add include files so that function definitions
 have a prototype
Message-ID: <20190117103602.GA6243@relativists.org>
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org

Hello,

Any chance these three patches of mine (reviewed by Mike Rapoport) 
will get merged?

Thanks for considering,

-d

P.S.: If they already got merged, I apologize—I couldn't find a 
repo for mm. (I checked master and next.)

On Tue, Dec 4, 2018 at 02:14 -0300, Adeodato Simó <dato@net.com.org.es> wrote:
> Previously, rodata_test(), usercopy_warn(), and usercopy_abort() were
> defined without a matching prototype. Detected by -Wmissing-prototypes
> GCC flag.
> 
> Signed-off-by: Adeodato Simó <dato@net.com.org.es>
> ---
> I started poking at this after kernel-janitors got the suggestion[1]
> to look into the -Wmissing-prototypes warnings.
> 
> Thanks for considering!
> 
> [1]: https://www.spinics.net/lists/linux-kernel-janitors/msg43981.html
> 
>  mm/rodata_test.c | 1 +
>  mm/usercopy.c    | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/mm/rodata_test.c b/mm/rodata_test.c
> index d908c8769b48..01306defbd1b 100644
> --- a/mm/rodata_test.c
> +++ b/mm/rodata_test.c
> @@ -11,6 +11,7 @@
>   */
>  #define pr_fmt(fmt) "rodata_test: " fmt
>  
> +#include <linux/rodata_test.h>
>  #include <linux/uaccess.h>
>  #include <asm/sections.h>
>  
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 852eb4e53f06..f487ba4888df 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -20,6 +20,7 @@
>  #include <linux/sched/task.h>
>  #include <linux/sched/task_stack.h>
>  #include <linux/thread_info.h>
> +#include <linux/uaccess.h>
>  #include <linux/atomic.h>
>  #include <linux/jump_label.h>
>  #include <asm/sections.h>
> -- 
> 2.19.2
> 
