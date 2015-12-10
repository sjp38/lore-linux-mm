Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 454C36B0254
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:25:51 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id u63so31143060wmu.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:25:51 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id n126si20512886wmf.19.2015.12.10.08.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 08:25:50 -0800 (PST)
Received: by wmec201 with SMTP id c201so32179654wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:25:49 -0800 (PST)
Date: Thu, 10 Dec 2015 17:25:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] mm: memcontrol: account "kmem" consumers in cgroup2
 memory controller
Message-ID: <20151210162548.GC11778@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-8-git-send-email-hannes@cmpxchg.org>
 <20151209113037.GS11488@esperanza>
 <20151210132833.GM19496@dhcp22.suse.cz>
 <20151210151627.GB1431@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210151627.GB1431@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 10-12-15 10:16:27, Johannes Weiner wrote:
> On Thu, Dec 10, 2015 at 02:28:33PM +0100, Michal Hocko wrote:
> > On Wed 09-12-15 14:30:38, Vladimir Davydov wrote:
> > > From: Vladimir Davydov <vdavydov@virtuozzo.com>
> > > Subject: [PATCH] mm: memcontrol: allow to disable kmem accounting for cgroup2
> > > 
> > > Kmem accounting might incur overhead that some users can't put up with.
> > > Besides, the implementation is still considered unstable. So let's
> > > provide a way to disable it for those users who aren't happy with it.
> > 
> > Yes there will be users who do not want to pay an additional overhead
> > and still accoplish what they need.
> > I haven't measured the overhead lately - especially after the opt-out ->
> > opt-in change so it might be much lower than my previous ~5% for kbuild
> > load.
> 
> I think switching from accounting *all* slab allocations to accounting
> a list of, what, less than 20 select slabs, counts as a change
> significant enough to entirely invalidate those measurements and never
> bring up that number again in the context of kmem cost, don't you think?

Yes, as I've said the numbers are expected to be much lower. That is
one of the reasons I have acknowledged kmem enabled as a reasonable
default.  There will always be _special_ loads where numbers might look
differently, though, and having a disabling knob is a reasonable thing
to offer with a minimum maintenance overhead. And this is the argument
for the inclusion of the patch from Vladimir.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
