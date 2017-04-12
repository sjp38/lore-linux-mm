Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE23A6B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 07:48:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d80so6788499qke.13
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:48:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 29si19313677qtn.48.2017.04.12.04.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 04:48:20 -0700 (PDT)
Date: Wed, 12 Apr 2017 13:48:16 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test
 in warn_alloc().
Message-ID: <20170412114754.GA15135@redhat.com>
References: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170412102341.GA13958@redhat.com>
 <20170412105951.GB7157@dhcp22.suse.cz>
 <20170412112154.GB14892@redhat.com>
 <20170412113528.GC7157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412113528.GC7157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Apr 12, 2017 at 01:35:28PM +0200, Michal Hocko wrote:
> OK, I see. That is a rather weird feature and the naming is more than
> surprising. But put that aside. Then it means that the check should be
> pulled out to 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6632256ef170..1e5f3b5cdb87 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3941,7 +3941,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto retry;
>  	}
>  fail:
> -	warn_alloc(gfp_mask, ac->nodemask,
> +	if (!debug_guardpage_minorder())
> +		warn_alloc(gfp_mask, ac->nodemask,
>  			"page allocation failure: order:%u", order);
>  got_pg:
>  	return page;

Looks good to me assuming it will be applied on top of Tetsuo's patch.

Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
