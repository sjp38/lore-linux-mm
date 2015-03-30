Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 23B796B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:20:12 -0400 (EDT)
Received: by patj18 with SMTP id j18so22516318pat.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 14:20:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c1si16380420pde.169.2015.03.30.14.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 14:20:11 -0700 (PDT)
Date: Mon, 30 Mar 2015 14:20:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: move lazy free pages to inactive list
Message-Id: <20150330142010.5d14fbc07e05180cc3ecce5c@linux-foundation.org>
In-Reply-To: <20150330053502.GB3008@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
	<1426036838-18154-3-git-send-email-minchan@kernel.org>
	<20150320154358.51bcf3cbceeb8fbbdb2b58e5@linux-foundation.org>
	<20150330053502.GB3008@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Mon, 30 Mar 2015 14:35:02 +0900 Minchan Kim <minchan@kernel.org> wrote:

> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -866,6 +866,13 @@ void deactivate_file_page(struct page *page)
>  	}
>  }
>  
> +/**
> + * deactivate_page - deactivate a page
> + * @page: page to deactivate
> + *
> + * This function moves @page to inactive list if @page was on active list and
> + * was not unevictable page to accelerate to reclaim @page.
> + */
>  void deactivate_page(struct page *page)
>  {
>  	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {

Thanks.

deactivate_page() doesn't look at or alter PageReferenced().  Should it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
