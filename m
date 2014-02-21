Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4094E6B00C0
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 07:35:06 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id l18so750636wgh.4
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 04:35:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cc14si2684126wib.54.2014.02.21.04.35.03
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 04:35:04 -0800 (PST)
Date: Fri, 21 Feb 2014 09:34:56 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] fs/proc/meminfo: meminfo_proc_show(): fix typo in comment
Message-ID: <20140221123456.GB10170@localhost.localdomain>
References: <20140218170027.00bcf592@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140218170027.00bcf592@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, akpm@linux-foundation.org, james.leddy@redhat.com

On Tue, Feb 18, 2014 at 05:00:27PM -0500, Luiz Capitulino wrote:
> It should read "reclaimable slab" and not "reclaimable swap".
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---
>  fs/proc/meminfo.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 136e548..7445af0 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -73,7 +73,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  	available += pagecache;
>  
>  	/*
> -	 * Part of the reclaimable swap consists of items that are in use,
> +	 * Part of the reclaimable slab consists of items that are in use,
>  	 * and cannot be freed. Cap this estimate at the low watermark.
>  	 */
>  	available += global_page_state(NR_SLAB_RECLAIMABLE) -
> -- 
> 1.8.1.4

Acked-by: Rafael Aquini <aquini@redhat.com>

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
