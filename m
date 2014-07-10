Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 618DF6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:44:12 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so1056421wgg.16
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:44:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ft19si12497979wic.27.2014.07.10.05.44.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:44:11 -0700 (PDT)
Date: Thu, 10 Jul 2014 13:44:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] mm: page_alloc: Abort fair zone allocation policy
 when remotes nodes are encountered
Message-ID: <20140710124407.GH10819@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-6-git-send-email-mgorman@suse.de>
 <20140710121419.GM29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140710121419.GM29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, Jul 10, 2014 at 08:14:19AM -0400, Johannes Weiner wrote:
> On Wed, Jul 09, 2014 at 09:13:07AM +0100, Mel Gorman wrote:
> > The purpose of numa_zonelist_order=zone is to preserve lower zones
> > for use with 32-bit devices. If locality is preferred then the
> > numa_zonelist_order=node policy should be used. Unfortunately, the fair
> > zone allocation policy overrides this by skipping zones on remote nodes
> > until the lower one is found. While this makes sense from a page aging
> > and performance perspective, it breaks the expected zonelist policy. This
> > patch restores the expected behaviour for zone-list ordering.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> 32-bit NUMA? :-)

I'm tempted to just say "it can go on fire" but realistically speaking
they should be configured to use node ordering. I was very tempted to
always force node ordering but I didn't have good data on how often lowmem
allocations are required on NUMA machines.

> Anyway, this change also cuts down the fair pass
> overhead on bigger NUMA machines, so I'm all for it.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks for the reviews!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
