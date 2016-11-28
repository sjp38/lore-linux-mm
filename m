Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A29576B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:06:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so37340952wma.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:06:54 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e1si54649418wjy.159.2016.11.28.06.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:06:53 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so19127020wmu.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:06:52 -0800 (PST)
Date: Mon, 28 Nov 2016 15:06:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20161128140651.GL14788@dhcp22.suse.cz>
References: <20160728071711.GB31860@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
 <20160803143419.GC1490@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com>
 <20160812123242.GH3639@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608131323550.3291@file01.intranet.prod.int.rdu2.redhat.com>
 <20160814103409.GC9248@dhcp22.suse.cz>
 <alpine.LRH.2.02.1611231558420.31481@file01.intranet.prod.int.rdu2.redhat.com>
 <20161124132916.GF20668@dhcp22.suse.cz>
 <alpine.LRH.2.02.1611241158250.9110@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1611241158250.9110@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Douglas Anderson <dianders@chromium.org>, shli@kernel.org, Dmitry Torokhov <dmitry.torokhov@gmail.com>

On Thu 24-11-16 12:10:08, Mikulas Patocka wrote:
> 
> 
> On Thu, 24 Nov 2016, Michal Hocko wrote:
[...]
> > Please note that even
> > GFP_NOWAIT allocations will wake up kspwad which should clean up that
> 
> The mempool is also using GFP_NOIO allocations - so do you claim that it 
> should not use GFP_NOIO too?

No, I am not claiming that. The last time I have asked the throttling
didn't seem to serious enough to cause any problems. If the memory
reclaim throttling is serious enough then let's measure and evaluate it.

> You should provide a clear API that the block device drivers should use to 
> allocate memory - not to apply band aid to vm throttling problems as they 
> are being discovered.

This is easier said than done, I am afraid. We have been using GFP_NOIO
in mempool for years and there were no major complains.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
