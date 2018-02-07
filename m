Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08E3C6B02AE
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 19:38:40 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t18so2610739plo.9
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 16:38:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s11-v6si177626plj.318.2018.02.06.16.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 16:38:38 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: swap: make pointer swap_avail_heads static
References: <20180206215836.12366-1-colin.king@canonical.com>
Date: Wed, 07 Feb 2018 08:38:36 +0800
In-Reply-To: <20180206215836.12366-1-colin.king@canonical.com> (Colin King's
	message of "Tue, 6 Feb 2018 21:58:36 +0000")
Message-ID: <87o9l11vn7.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> The pointer swap_avail_heads is local to the source and does not need
> to be in global scope, so make it static.
>
> Cleans up sparse warning:
> mm/swapfile.c:88:19: warning: symbol 'swap_avail_heads' was not
> declared. Should it be static?
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
>  mm/swapfile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 006047b16814..0d00471af98b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -85,7 +85,7 @@ PLIST_HEAD(swap_active_head);
>   * is held and the locking order requires swap_lock to be taken
>   * before any swap_info_struct->lock.
>   */
> -struct plist_head *swap_avail_heads;
> +static struct plist_head *swap_avail_heads;
>  static DEFINE_SPINLOCK(swap_avail_lock);
>  
>  struct swap_info_struct *swap_info[MAX_SWAPFILES];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
