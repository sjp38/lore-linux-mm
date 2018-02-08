Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5862E6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:16:41 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g69so5825934ita.9
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:16:41 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r77si447968ioe.254.2018.02.08.11.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 11:16:38 -0800 (PST)
Subject: Re: [PATCH] mm/swap.c: make functions and their kernel-doc agree
 (again)
References: <1518116946-20947-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <931229b3-cf82-0999-ac85-c19578a6ee2a@infradead.org>
Date: Thu, 8 Feb 2018 11:16:29 -0800
MIME-Version: 1.0
In-Reply-To: <1518116946-20947-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On 02/08/2018 11:09 AM, Mike Rapoport wrote:
> There was a conflict between the commit e02a9f048ef7 ("mm/swap.c: make
> functions and their kernel-doc agree") and the commit f144c390f905 ("mm:
> docs: fix parameter names mismatch") that both tried to fix mismatch
> betweeen pagevec_lookup_entries() parameter names and their description.
> 
> Since nr_entries is a better name for the parameter, fix the description
> again.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks, I hadn't noticed.

Acked-by: Randy Dunlap <rdunlap@infradead.org>


> ---
>  mm/swap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 567a7b96e41d..6d7b8bc58003 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -913,7 +913,7 @@ EXPORT_SYMBOL(__pagevec_lru_add);
>   * @pvec:	Where the resulting entries are placed
>   * @mapping:	The address_space to search
>   * @start:	The starting entry index
> - * @nr_pages:	The maximum number of pages
> + * @nr_entries:	The maximum number of pages
>   * @indices:	The cache indices corresponding to the entries in @pvec
>   *
>   * pagevec_lookup_entries() will search for and return a group of up
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
