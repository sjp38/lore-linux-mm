Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3211B6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 04:27:03 -0500 (EST)
Received: by wmec201 with SMTP id c201so123392058wme.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 01:27:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si22510661wmg.50.2015.11.10.01.27.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Nov 2015 01:27:01 -0800 (PST)
Subject: Re: [PATCH] mm/mlock.c: drop unneeded initialization in
 munlock_vma_pages_range()
References: <1447114962-31834-1-git-send-email-klimov.linux@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5641B864.2020709@suse.cz>
Date: Tue, 10 Nov 2015 10:27:00 +0100
MIME-Version: 1.0
In-Reply-To: <1447114962-31834-1-git-send-email-klimov.linux@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Klimov <klimov.linux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, emunson@akamai.com

On 11/10/2015 01:22 AM, Alexey Klimov wrote:
> Before usage page pointer initialized by NULL is reinitialized by
> follow_page_mask(). Drop useless init of page pointer in the beginning
> of loop.
>
> Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/mlock.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 339d9e0..9cb87cb 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -425,7 +425,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>   	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
>
>   	while (start < end) {
> -		struct page *page = NULL;
> +		struct page *page;
>   		unsigned int page_mask;
>   		unsigned long page_increm;
>   		struct pagevec pvec;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
