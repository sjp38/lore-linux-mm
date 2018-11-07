Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB616B04D3
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 04:05:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 6-v6so2686962edz.10
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 01:05:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17-v6si194672eji.74.2018.11.07.01.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 01:05:00 -0800 (PST)
Subject: Re: [PATCH v2 3/4] mm: convert totalram_pages and totalhigh_pages
 variables to atomic
References: <1541521310-28739-1-git-send-email-arunks@codeaurora.org>
 <1541521310-28739-4-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5edc432c-b475-5d2e-6a87-700c32a8fad9@suse.cz>
Date: Wed, 7 Nov 2018 10:04:59 +0100
MIME-Version: 1.0
In-Reply-To: <1541521310-28739-4-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, mhocko@kernel.org, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com

On 11/6/18 5:21 PM, Arun KS wrote:
> totalram_pages and totalhigh_pages are made static inline function.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

One bug (probably) below:

> diff --git a/mm/highmem.c b/mm/highmem.c
> index 59db322..02a9a4b 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -105,9 +105,7 @@ static inline wait_queue_head_t *get_pkmap_wait_queue_head(unsigned int color)
>  }
>  #endif
>  
> -unsigned long totalhigh_pages __read_mostly;
> -EXPORT_SYMBOL(totalhigh_pages);

I think you still need to export _totalhigh_pages so that modules can
use the inline accessors.

> -
> +atomic_long_t _totalhigh_pages __read_mostly;
>  
>  EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
>  
