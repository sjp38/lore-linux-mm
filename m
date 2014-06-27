Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 320566B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 17:05:17 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so4577959qaq.12
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 14:05:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c36si15498553qgd.64.2014.06.27.14.05.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jun 2014 14:05:16 -0700 (PDT)
Date: Fri, 27 Jun 2014 17:05:12 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm/hwpoison-inject.c: remove unnecessary null test
 before debugfs_remove_recursive
Message-ID: <20140627210512.GA18026@nhori.bos.redhat.com>
References: <1403902696-12162-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403902696-12162-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 27, 2014 at 10:58:16PM +0200, Fabian Frederick wrote:
> Fix checkpatch warning:
> "WARNING: debugfs_remove_recursive(NULL) is safe this check is probably not required"
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Looks good to me, thank you.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hwpoison-inject.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> index 95487c7..329caf5 100644
> --- a/mm/hwpoison-inject.c
> +++ b/mm/hwpoison-inject.c
> @@ -72,8 +72,7 @@ DEFINE_SIMPLE_ATTRIBUTE(unpoison_fops, NULL, hwpoison_unpoison, "%lli\n");
>  
>  static void pfn_inject_exit(void)
>  {
> -	if (hwpoison_dir)
> -		debugfs_remove_recursive(hwpoison_dir);
> +	debugfs_remove_recursive(hwpoison_dir);
>  }
>  
>  static int pfn_inject_init(void)
> -- 
> 1.8.4.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
