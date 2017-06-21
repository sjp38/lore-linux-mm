Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 283B76B03D1
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:22:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 91so47467804qkq.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:22:24 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id w32si14485873qtb.44.2017.06.21.03.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 03:22:23 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id v20so37397934qtg.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:22:23 -0700 (PDT)
Message-ID: <1498040539.4735.3.camel@redhat.com>
Subject: Re: [PATCH][mm-next] mm: clean up build warning with unused
 variable ret2
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 21 Jun 2017 06:22:19 -0400
In-Reply-To: <20170621101433.9847-1-colin.king@canonical.com>
References: <20170621101433.9847-1-colin.king@canonical.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Dave Chinner <dchinner@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2017-06-21 at 11:14 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable ret2 is unused and should be removed. Cleans up
> build warning:
> 
> warning: unused variable 'ret2' [-Wunused-variable]
> 
> Fixes: 4118ba44fa2cd040e ("mm: clean up error handling in write_one_page")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  mm/page-writeback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 64b75bd996a4..0b60cc7ddac2 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2377,7 +2377,7 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
>  int write_one_page(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
> -	int ret = 0, ret2;
> +	int ret = 0;
>  	struct writeback_control wbc = {
>  		.sync_mode = WB_SYNC_ALL,
>  		.nr_to_write = 1,


Thanks. I just squashed the same fix into the original patch this
morning after seeing the mail from Stephen. Tomorrow's linux-next pull
should pick up the corrected version.
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
