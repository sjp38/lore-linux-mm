Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C90096B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:33:01 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so38164509qgf.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:33:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si16801363qcl.3.2015.03.18.07.33.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 07:33:01 -0700 (PDT)
Message-ID: <55098C99.9040104@redhat.com>
Date: Wed, 18 Mar 2015 10:32:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in page_cache_read
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426687766-518-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/18/2015 10:09 AM, Michal Hocko wrote:

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 968cd8e03d2e..26f62ba79f50 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1752,7 +1752,7 @@ static int page_cache_read(struct file *file, pgoff_t offset)
>  	int ret;
>  
>  	do {
> -		page = page_cache_alloc_cold(mapping);
> +		page = __page_cache_alloc(GFP_KERNEL|__GFP_COLD);
>  		if (!page)
>  			return -ENOMEM;

Won't this break on highmem systems, by failing to
allocate the page cache from highmem, where previously
it would?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
