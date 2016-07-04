Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54A5E6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 20:04:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so362528985pfb.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 17:04:34 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id vo6si762274pab.224.2016.07.03.17.04.32
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 17:04:33 -0700 (PDT)
Date: Mon, 4 Jul 2016 09:05:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 6/8] mm/zsmalloc: keep comments consistent with code
Message-ID: <20160704000516.GE19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-6-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-6-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:04PM +0800, Ganesh Mahendran wrote:
> some minor change of comments:
> 1). update zs_malloc(),zs_create_pool() function header
> 2). update "Usage of struct page fields"
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 2690914..6fc631a 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -20,6 +20,7 @@
>   *	page->freelist(index): links together all component pages of a zspage
>   *		For the huge page, this is always 0, so we use this field
>   *		to store handle.
> + *	page->units: first object index in a subpage of zspage

Hmm, I want to use offset instead of index.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
