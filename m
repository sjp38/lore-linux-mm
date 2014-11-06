Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 623536B0095
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 09:33:05 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so1327363wgh.41
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 06:33:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si9739926wje.51.2014.11.06.06.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 06:33:04 -0800 (PST)
Date: Thu, 6 Nov 2014 15:33:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106143303.GH7202@dhcp22.suse.cz>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
 <20141106090845.GA17744@dhcp22.suse.cz>
 <20141106092849.GC4839@esperanza>
 <20141106140514.GG7202@dhcp22.suse.cz>
 <20141106143008.GE4839@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106143008.GE4839@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu 06-11-14 17:30:09, Vladimir Davydov wrote:
> On Thu, Nov 06, 2014 at 03:05:15PM +0100, Michal Hocko wrote:
> > > BTW what do you think about the whole patch set that introduced it -
> > > https://lkml.org/lkml/2014/11/3/781 - w/o diving deeply into details,
> > > just by looking at the general idea described in the cover letter?
> > 
> > The series is still stuck in my inbox and I plan to review your shrinker
> > code first. I hope to get to it ASAP but not sooner than Monday as I
> > will be off until Sunday.
> 
> OK, then I think we'd better drop it and concentrate on the shrinkers

That would help, because there is way too much going on on memcg front
this cycle.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
