Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 29A8B6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:53:49 -0400 (EDT)
Received: by qkfm62 with SMTP id m62so42451343qkf.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:53:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g123si9093341qhc.125.2015.10.21.10.53.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 10:53:48 -0700 (PDT)
Date: Wed, 21 Oct 2015 13:53:43 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 5/12] mm: correct a couple of page migration comments
Message-ID: <20151021175342.GA14968@t510.redhat.com>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182154320.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510182154320.2481@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Sun, Oct 18, 2015 at 09:55:56PM -0700, Hugh Dickins wrote:
> It's migrate.c not migration,c, and nowadays putback_movable_pages()
> not putback_lru_pages().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/migrate.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- migrat.orig/mm/migrate.c	2015-10-18 17:53:14.326325730 -0700
> +++ migrat/mm/migrate.c	2015-10-18 17:53:17.579329434 -0700
> @@ -1,5 +1,5 @@
>  /*
> - * Memory Migration functionality - linux/mm/migration.c
> + * Memory Migration functionality - linux/mm/migrate.c
>   *
>   * Copyright (C) 2006 Silicon Graphics, Inc., Christoph Lameter
>   *
> @@ -1113,7 +1113,7 @@ out:
>   *
>   * The function returns after 10 attempts or if no pages are movable any more
>   * because the list has become empty or no retryable pages exist any more.
> - * The caller should call putback_lru_pages() to return pages to the LRU
> + * The caller should call putback_movable_pages() to return pages to the LRU
>   * or free list only if ret != 0.
>   *
>   * Returns the number of pages that were not migrated, or an error code.
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
