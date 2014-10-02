Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 967896B006C
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:54:48 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id u20so2081777oif.2
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:54:48 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id ek10si7986002obb.96.2014.10.02.08.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:54:47 -0700 (PDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so2437458obc.1
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:54:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412264685-3368-1-git-send-email-paulmcquad@gmail.com>
References: <1412264685-3368-1-git-send-email-paulmcquad@gmail.com>
Date: Thu, 2 Oct 2014 19:54:46 +0400
Message-ID: <CAMo8BfKvvGg7QAH1GqGH98Qsw9v8=Ok0cV+uxKL5RP97p--KpQ@mail.gmail.com>
Subject: Re: [PATCH] mm: highmem remove 3 errors
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 2, 2014 at 7:44 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
> pointers should be foo *bar or (foo *)
>
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
> ---
>  mm/highmem.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/highmem.c b/mm/highmem.c
> index 123bcd3..f6dae74 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -130,7 +130,7 @@ unsigned int nr_free_highpages (void)
>  static int pkmap_count[LAST_PKMAP];
>  static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
>
> -pte_t * pkmap_page_table;
> +pte_t *pkmap_page_table;
>
>  /*
>   * Most architectures have no use for kmap_high_get(), so let's abstract
> @@ -291,7 +291,7 @@ void *kmap_high(struct page *page)
>         pkmap_count[PKMAP_NR(vaddr)]++;
>         BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
>         unlock_kmap();
> -       return (void*) vaddr;
> +       return (void *) vaddr;

checkpatch suggests that
CHECK: No space is necessary after a cast

>  }
>
>  EXPORT_SYMBOL(kmap_high);
> @@ -318,7 +318,7 @@ void *kmap_high_get(struct page *page)
>                 pkmap_count[PKMAP_NR(vaddr)]++;
>         }
>         unlock_kmap_any(flags);
> -       return (void*) vaddr;
> +       return (void *) vaddr;

Here as well.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
