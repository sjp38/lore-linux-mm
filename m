Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73F056B6D83
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:25:11 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so7722498edr.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:25:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12si560717edf.296.2018.12.03.23.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:25:10 -0800 (PST)
Date: Tue, 4 Dec 2018 08:25:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm/vmscan: Enable kswapd to reclaim low-protected
 memory
Message-ID: <20181204072508.GU31738@dhcp22.suse.cz>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-2-xlpang@linux.alibaba.com>
 <20181203115646.GP31738@dhcp22.suse.cz>
 <54a3f0a6-6e7d-c620-97f2-ac567c057bc2@linux.alibaba.com>
 <20181203172007.GG31738@dhcp22.suse.cz>
 <a77ed2a6-ed9b-4c1b-e2e9-fb9a5108c1f9@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a77ed2a6-ed9b-4c1b-e2e9-fb9a5108c1f9@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 04-12-18 10:40:29, Xunlei Pang wrote:
> On 2018/12/4 AM 1:22, Michal Hocko wrote:
> > On Mon 03-12-18 23:20:31, Xunlei Pang wrote:
> >> On 2018/12/3 下午7:56, Michal Hocko wrote:
> >>> On Mon 03-12-18 16:01:18, Xunlei Pang wrote:
> >>>> There may be cgroup memory overcommitment, it will become
> >>>> even common in the future.
> >>>>
> >>>> Let's enable kswapd to reclaim low-protected memory in case
> >>>> of memory pressure, to mitigate the global direct reclaim
> >>>> pressures which could cause jitters to the response time of
> >>>> lantency-sensitive groups.
> >>>
> >>> Please be more descriptive about the problem you are trying to handle
> >>> here. I haven't actually read the patch but let me emphasise that the
> >>> low limit protection is important isolation tool. And allowing kswapd to
> >>> reclaim protected memcgs is going to break the semantic as it has been
> >>> introduced and designed.
> >>
> >> We have two types of memcgs: online groups(important business)
> >> and offline groups(unimportant business). Online groups are
> >> all configured with MAX low protection, while offline groups
> >> are not at all protected(with default 0 low).
> >>
> >> When offline groups are overcommitted, the global memory pressure
> >> suffers. This will cause the memory allocations from online groups
> >> constantly go to the slow global direct reclaim in order to reclaim
> >> online's page caches, as kswap is not able to reclaim low-protection
> >> memory. low is not hard limit, it's reasonable to be reclaimed by
> >> kswapd if there's no other reclaimable memory.
> > 
> > I am sorry I still do not follow. What role do offline cgroups play.
> > Those are certainly not low mem protected because mem_cgroup_css_offline
> > will reset them to 0.
> > 
> 
> Oh, I meant "offline groups" to be "offline-business groups", memcgs
> refered to here are all "online state" from kernel's perspective.

What is offline-business group? Please try to explain the actual problem
in much more details and do not let us guess.

-- 
Michal Hocko
SUSE Labs
