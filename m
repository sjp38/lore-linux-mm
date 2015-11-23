Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 113476B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:24:56 -0500 (EST)
Received: by wmww144 with SMTP id w144so108243627wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 10:24:55 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b9si19050464wmf.44.2015.11.23.10.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 10:24:55 -0800 (PST)
Date: Mon, 23 Nov 2015 13:24:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151123182447.GF13000@cmpxchg.org>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
 <20151120090626.GB16698@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511201523520.10092@chino.kir.corp.google.com>
 <20151123094106.GD21050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123094106.GD21050@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Nov 23, 2015 at 10:41:06AM +0100, Michal Hocko wrote:
> @@ -3197,8 +3197,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		unsigned long target;
>  
>  		reclaimable = zone_reclaimable_pages(zone) +
> -			      zone_page_state(zone, NR_ISOLATED_FILE) +
> -			      zone_page_state(zone, NR_ISOLATED_ANON);
> +			      zone_page_state(zone, NR_ISOLATED_FILE);
> +		if (get_nr_swap_pages() > 0)
> +			reclaimable += zone_page_state(zone, NR_ISOLATED_ANON);

Can you include the isolated counts in zone_reclaimable_pages()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
