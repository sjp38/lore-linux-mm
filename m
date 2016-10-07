Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2026280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:20:59 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so21514808pac.6
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:20:59 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id ah3si16270586pad.176.2016.10.07.01.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 01:20:59 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id 128so915648pfz.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:20:59 -0700 (PDT)
Date: Fri, 7 Oct 2016 10:20:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slab: fix kmemcg cache creation delayed issue
Message-ID: <20161007082055.GH18439@dhcp22.suse.cz>
References: <002b01d21fea$fb0bab60$f1230220$@net>
 <20161007051400.GA7294@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161007051400.GA7294@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Doug Smythies <dsmythies@telus.net>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri 07-10-16 14:14:01, Joonsoo Kim wrote:
> On Thu, Oct 06, 2016 at 09:02:00AM -0700, Doug Smythies wrote:
> > It was my (limited) understanding that the subsequent 2 patch set
> > superseded this patch. Indeed, the 2 patch set seems to solve
> > both the SLAB and SLUB bug reports.
> 
> It would mean that patch 1 solves both the SLAB and SLUB bug reports
> since patch 2 is only effective for SLUB.
> 
> Reason that I send this patch is that although patch 1 fixes the
> issue that too many kworkers are created, kmem_cache creation/destory
> is still slowed by synchronize_sched() and it would cause kmemcg
> usage counting delayed. I'm not sure how bad it is but it's generally
> better to start accounting as soon as possible. With patch 2 for SLUB
> and this patch for SLAB, performance of kmem_cache
> creation/destory would recover.

OK, so do we really want/need it for stable as well. I am not opposing
that but the effect doesn't seem to be a clear cut.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
