Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 686506B0075
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:44:28 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so62953108pac.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:44:28 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id p12si11615377pdn.147.2015.06.18.07.44.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 07:44:27 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so62952808pac.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:44:27 -0700 (PDT)
Date: Thu, 18 Jun 2015 23:43:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150618144343.GA12441@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20150618121314.GA518@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618121314.GA518@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/18/15 21:13), Sergey Senozhatsky wrote:
> @@ -645,10 +645,11 @@ static void insert_zspage(struct page *page, struct size_class *class,
>  		 * We want to see more ZS_FULL pages and less almost
>  		 * empty/full. Put pages with higher ->inuse first.
>  		 */
> -		if (page->inuse < (*head)->inuse)
> -			list_add_tail(&page->lru, &(*head)->lru);
> -		else
> +		if (fullness == ZS_ALMOST_FULL ||
> +				(page->inuse >= (*head)->inuse))
>  			list_add(&page->lru, &(*head)->lru);
> +		else
> +			list_add_tail(&page->lru, &(*head)->lru);
>  	}
>  
>  	*head = page;

oh, dear. what I was thinking of. this is just stupid. please ignore
this part.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
