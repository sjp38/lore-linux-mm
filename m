Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 897A86B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 04:23:56 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id j35so142855701qge.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 01:23:56 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0148.outbound.protection.outlook.com. [157.55.234.148])
        by mx.google.com with ESMTPS id b124si21445925qhd.126.2016.04.04.01.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 01:23:55 -0700 (PDT)
Date: Mon, 4 Apr 2016 11:23:43 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
Message-ID: <20160404082343.GD6610@esperanza>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1450203586-10959-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1450203586-10959-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 15, 2015 at 07:19:44PM +0100, Michal Hocko wrote:
...
> @@ -2592,17 +2589,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  						&nr_soft_scanned);
>  			sc->nr_reclaimed += nr_soft_reclaimed;
>  			sc->nr_scanned += nr_soft_scanned;
> -			if (nr_soft_reclaimed)
> -				reclaimable = true;
>  			/* need some check for avoid more shrink_zone() */
>  		}
>  
> -		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
> -			reclaimable = true;
> -
> -		if (global_reclaim(sc) &&
> -		    !reclaimable && zone_reclaimable(zone))
> -			reclaimable = true;
> +		shrink_zone(zone, sc, zone_idx(zone));

Shouldn't it be

		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);

?

>  	}
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
