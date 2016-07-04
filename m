Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E81536B0253
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 04:45:28 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so336704650pat.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 01:45:28 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id zo9si4342391pac.196.2016.07.04.01.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 01:45:28 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id hf6so15367862pac.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 01:45:28 -0700 (PDT)
Date: Mon, 4 Jul 2016 17:45:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 8/8] mm/zsmalloc: use helper to clear page->flags bit
Message-ID: <20160704084514.GH898@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-8-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-8-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
> Date: Mon,  4 Jul 2016 14:49:59 +0800
> From: Ganesh Mahendran <opensource.ganesh@gmail.com>
> To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
> Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org,
>  sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com,
>  Ganesh Mahendran <opensource.ganesh@gmail.com>
> Subject: [PATCH v2 8/8] mm/zsmalloc: use helper to clear page->flags bit
> X-Mailer: git-send-email 1.9.1
> 
> user ClearPagePrivate/ClearPagePrivate2 helper to clear
> PG_private/PG_private_2 in page->flags
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ----
> v2: none
> ---
>  mm/zsmalloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 756f839..297f25b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -940,8 +940,8 @@ static void unpin_tag(unsigned long handle)
>  static void reset_page(struct page *page)
>  {
>  	__ClearPageMovable(page);
> -	clear_bit(PG_private, &page->flags);
> -	clear_bit(PG_private_2, &page->flags);
> +	ClearPagePrivate(page);
> +	ClearPagePrivate2(page);
>  	set_page_private(page, 0);
>  	page_mapcount_reset(page);
>  	ClearPageHugeObject(page);
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
