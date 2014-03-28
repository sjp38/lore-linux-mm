Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 233206B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 06:04:31 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x12so3336025wgg.6
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 03:04:30 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id w2si1499107wiz.57.2014.03.28.03.04.28
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 03:04:29 -0700 (PDT)
Date: Fri, 28 Mar 2014 10:04:06 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 1/4] kmemleak: free internal objects only if there're
 no leaks to be reported
Message-ID: <20140328100403.GA21330@arm.com>
References: <5335384A.2000000@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5335384A.2000000@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 28, 2014 at 08:52:26AM +0000, Li Zefan wrote:
> Currently if you disabling kmemleak after stopping kmemleak thread,
> kmemleak objects will be freed and so you won't be able to check
> previously reported leaks.
> 
> With this patch, kmemleak objects won't be freed if there're leaks
> that can be reported.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Some nitpicks below:

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 31f01c5..be7ecc0 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -218,7 +218,8 @@ static int kmemleak_stack_scan = 1;
>  static DEFINE_MUTEX(scan_mutex);
>  /* setting kmemleak=on, will set this var, skipping the disable */
>  static int kmemleak_skip_disable;
> -
> +/* If there're leaks that can be reported */

"If there are ..." (easier to read ;)).

> +static bool kmemleak_has_leaks;

Better "kmemleak_found_leaks" to avoid confusion.

Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
