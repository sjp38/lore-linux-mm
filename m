Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 317D26B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 17:05:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so51669218lfd.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 14:05:42 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id wp4si7227807wjb.173.2016.05.04.14.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 14:05:40 -0700 (PDT)
Date: Wed, 4 May 2016 14:05:39 -0700
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
Message-ID: <20160504210539.GM13997@two.firstfloor.org>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
 <1462309239.21143.6.camel@linux.intel.com>
 <20160504124535.GJ29978@dhcp22.suse.cz>
 <1462381986.30611.28.camel@linux.intel.com>
 <20160504194901.GG21490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504194901.GG21490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

> In order this to work other quite intrusive changes to the current
> reclaim decisions would have to be made though. This is what I tried to
> say. Look at get_scan_count() on how we are making many steps to ignore
> swappiness or prefer the page cache. Even when we make swapout scale it
> won't help much if we do not swap out that often. That's why I claim

But if you made swapout to scale you would need some equivalent
of Tim's patches for the swap path... So you need them in case.

> that we really should think more long term and maybe reconsider these
> decisions which were based on the rotating rust for the swap devices.

Sure that makes sense, but why not start with low hanging fruit
in basic performance, like Tim did? Usually that is how Linux
changes work, steady evolution, not revolution.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
