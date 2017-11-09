Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D660440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 08:42:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 5so915709wmk.0
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 05:42:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r13si1390123edk.420.2017.11.09.05.42.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 05:42:44 -0800 (PST)
Date: Thu, 9 Nov 2017 14:42:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: make it possible to offline
 blocks with reserved pages
Message-ID: <20171109134241.4dz6wchxzx27dgsr@dhcp22.suse.cz>
References: <20171108130155.25499-1-vkuznets@redhat.com>
 <20171108142528.vsrkkqw6fihxdjio@dhcp22.suse.cz>
 <87y3nglqyi.fsf@vitty.brq.redhat.com>
 <20171108155740.z7fwptk3jg6rc7mv@dhcp22.suse.cz>
 <87po8slp9o.fsf@vitty.brq.redhat.com>
 <20171109131612.wjjwwvnxo2yxgswx@dhcp22.suse.cz>
 <8760ajlgut.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8760ajlgut.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Alex Ng <alexng@microsoft.com>

On Thu 09-11-17 14:30:18, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
[...]
> > How realistic is that the host gives only such a small amount of memory
> > btw?
> 
> It happens all the time, Hyper-V host will gradually increase guest's
> memory when Dynamic Memory is enabled. Moreover, there's a manual
> interface when host's admin can hotplug memory to guests (starting
> WS2016) with 2M granularity.

Sigh, this sounds quite insane but whatever. I am not sure we want to
make the generic hotplug code more complicated for this single usecase.
So I suspect you might be better off by implementing this feature on top
of hotplug. Just keep track of the partial sections and make the memory
which is not onlined yet reserved and unusable by the kernel. It sucks,
I know, but as long as there is not a wider demand for sub section
memory hotplug I would be rather reluctant to make the fragile code even
more complicated. Mem section granularity is hardcoded in way too many
places I am afraid.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
