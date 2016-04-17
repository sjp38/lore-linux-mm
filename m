Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D54F6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:13:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t124so282153348pfb.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:13:22 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id g1si15713224pfd.0.2016.04.17.07.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 07:13:21 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id r187so14674343pfr.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:13:21 -0700 (PDT)
Date: Mon, 18 Apr 2016 00:11:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3 07/16] zsmalloc: remove page_mapcount_reset
Message-ID: <20160417151103.GC575@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello,

On (03/30/16 16:12), Minchan Kim wrote:
> We don't use page->_mapcount any more so no need to reset.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  mm/zsmalloc.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 4dd72a803568..0f6cce9b9119 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -922,7 +922,6 @@ static void reset_page(struct page *page)
>  	set_page_private(page, 0);
>  	page->mapping = NULL;
>  	page->freelist = NULL;
> -	page_mapcount_reset(page);
>  }
>  
>  static void free_zspage(struct page *first_page)
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
