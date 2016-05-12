Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25575828E2
	for <linux-mm@kvack.org>; Thu, 12 May 2016 12:21:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so154143411pfy.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:21:51 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id dd4si10913618pad.34.2016.05.12.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 09:21:50 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so16751362wme.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:21:49 -0700 (PDT)
Date: Thu, 12 May 2016 18:20:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
Message-ID: <20160512162043.GA4261@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-7-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:56, Vlastimil Babka wrote:
[...]
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 570383a41853..0cb09714d960 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -256,8 +256,7 @@ struct vm_area_struct;
>  #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>  #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
>  #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> -			 ~__GFP_RECLAIM)
> +			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)

I am not sure this is the right thing to do. I think we should keep
__GFP_NORETRY and clear it where we want a stronger semantic. This is
just too suble that all callsites are doing the right thing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
