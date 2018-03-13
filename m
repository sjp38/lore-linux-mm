Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD9456B0279
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:45:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p128so5317762pga.19
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 07:45:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si207712pgv.487.2018.03.13.07.45.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 07:45:38 -0700 (PDT)
Date: Tue, 13 Mar 2018 15:45:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory-failure: fix section mismatch
Message-ID: <20180313144536.GC4811@dhcp22.suse.cz>
References: <20180304071613.16899-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180304071613.16899-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 03-03-18 23:16:11, Nick Desaulniers wrote:
> Clang complains when a variable is declared extern twice, but with two
> different sections. num_poisoned_pages is marked extern and __read_mostly
> in include/linux/swapops.h, but only extern in include/linux/mm.h. Some
> c source files must include both, and thus see the conflicting
> declarations.

Why do we need declarations in both places? This sounds like a mess to
me.

> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
> ---
>  include/linux/mm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..bd4bd59f02c1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
>  extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
> -extern atomic_long_t num_poisoned_pages;
> +extern atomic_long_t num_poisoned_pages __read_mostly;
>  extern int soft_offline_page(struct page *page, int flags);
>  
>  
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs
