Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9DCF6B0338
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 12:59:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b19so9374022wmb.8
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 09:59:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v63si7403051wme.197.2017.06.18.09.59.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Jun 2017 09:59:54 -0700 (PDT)
Date: Sun, 18 Jun 2017 18:59:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mmzone: simplify zone_intersects()
Message-ID: <20170618165951.GG18660@dhcp22.suse.cz>
References: <20170616092335.5177-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616092335.5177-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 16-06-17 17:23:34, Wei Yang wrote:
> To make sure a range intersects a zone, only two comparison is necessary.
> 
> This patch simplifies the function a little.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0176a2933c61..7e8f100cb56d 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -541,15 +541,11 @@ static inline bool zone_intersects(struct zone *zone,
>  {
>  	if (zone_is_empty(zone))
>  		return false;
> -	if (start_pfn >= zone_end_pfn(zone))
> +	if (start_pfn >= zone_end_pfn(zone) ||
> +	    start_pfn + nr_pages <= zone->zone_start_pfn)
>  		return false;
>  
> -	if (zone->zone_start_pfn <= start_pfn)
> -		return true;
> -	if (start_pfn + nr_pages > zone->zone_start_pfn)
> -		return true;
> -
> -	return false;
> +	return true;
>  }
>  
>  /*
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
