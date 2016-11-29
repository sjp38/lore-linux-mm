Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 046A06B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:38:10 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id s68so171686286ywg.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:38:10 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id e72si16162805ybh.19.2016.11.29.08.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 08:38:09 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id a10so12666303ywa.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:38:09 -0800 (PST)
Date: Tue, 29 Nov 2016 11:38:07 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161129163807.GB19454@htj.duckdns.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
 <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129072507.GA31671@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue, Nov 29, 2016 at 08:25:07AM +0100, Michal Hocko wrote:
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -246,7 +246,7 @@ struct vm_area_struct;
>  #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
>  #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
>  #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
> -#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
> +#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM|__GFP_NOWARN)
>  #define GFP_NOIO	(__GFP_RECLAIM)
>  #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
>  #define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
> 
> this will not catch users who are doing gfp & ~__GFP_DIRECT_RECLAIM but
> I would rather not make warn_alloc() even more cluttered with checks.

Yeah, FWIW, looks good to me.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
