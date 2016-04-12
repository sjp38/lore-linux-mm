Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE256B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:51:39 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id n3so31687670wmn.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:51:39 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e7si34715231wjp.33.2016.04.12.07.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 07:51:38 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n3so6070310wmn.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:51:38 -0700 (PDT)
Date: Tue, 12 Apr 2016 16:51:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm woes, mainly compaction
Message-ID: <20160412145136.GA4387@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
 <20160412121020.GC10771@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160412121020.GC10771@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 12-04-16 14:10:20, Michal Hocko wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d1da0ceaf1e..d80c9755ffc7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3030,8 +3030,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	 * failure could be caused by weak migration mode.
>  	 */
>  	if (compaction_failed(compact_result)) {
> -		if (*migrate_mode == MIGRATE_ASYNC) {
> -			*migrate_mode = MIGRATE_SYNC_LIGHT;
> +		if (*migrate_mode < MIGRATE_SYNC) {
> +			*migrate_mode++;
>  			return true;

this should be (*migrate_mode)++ of course.

>  		}
>  		return false;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
