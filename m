Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2A36B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:31:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so10474343wmz.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:31:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f191si18573223wmf.73.2016.06.06.06.31.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 06:31:24 -0700 (PDT)
Subject: Re: [PATCH v2 3/7] mm/page_owner: copy last_migrate_reason in
 copy_page_owner()
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <edbe82ce-36ab-125c-a0d2-ddf004c7e699@suse.cz>
Date: Mon, 6 Jun 2016 15:31:21 +0200
MIME-Version: 1.0
In-Reply-To: <1464230275-25791-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Currently, copy_page_owner() doesn't copy all the owner information.
> It skips last_migrate_reason because copy_page_owner() is used for
> migration and it will be properly set soon. But, following patch
> will use copy_page_owner() and this skip will cause the problem that
> allocated page has uninitialied last_migrate_reason. To prevent it,
> this patch also copy last_migrate_reason in copy_page_owner().
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_owner.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index c6cda3e..73e202f 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -118,6 +118,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
>
>  	new_ext->order = old_ext->order;
>  	new_ext->gfp_mask = old_ext->gfp_mask;
> +	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
>  	new_ext->nr_entries = old_ext->nr_entries;
>
>  	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
