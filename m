Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 62DF86B00EA
	for <linux-mm@kvack.org>; Fri, 25 May 2012 03:17:28 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so629076lbj.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 00:17:26 -0700 (PDT)
Date: Fri, 25 May 2012 10:17:16 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1/2] vmevent: don't leak unitialized data to userspace
In-Reply-To: <201205230927.58802.b.zolnierkie@samsung.com>
Message-ID: <alpine.LFD.2.02.1205251017090.3897@tux.localdomain>
References: <201205230927.58802.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

On Wed, 23 May 2012, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] vmevent: don't leak unitialized data to userspace
> 
> Remember to initialize all attrs[nr] fields in vmevent_setup_watch().
> 
> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/vmevent.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Index: b/mm/vmevent.c
> ===================================================================
> --- a/mm/vmevent.c	2012-05-22 17:51:13.195231958 +0200
> +++ b/mm/vmevent.c	2012-05-22 17:51:40.991231956 +0200
> @@ -350,7 +350,10 @@
>  
>  		attrs = new;
>  
> -		attrs[nr++].type = attr->type;
> +		attrs[nr].type = attr->type;
> +		attrs[nr].value = 0;
> +		attrs[nr].state = 0;
> +		nr++;
>  	}
>  
>  	watch->sample_attrs	= attrs;

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
