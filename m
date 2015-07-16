Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 246C4280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:04:00 -0400 (EDT)
Received: by ietj16 with SMTP id j16so66403636iet.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:03:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id co1si2896526igb.16.2015.07.16.16.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:03:59 -0700 (PDT)
Date: Thu, 16 Jul 2015 16:03:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-Id: <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
In-Reply-To: <20150716225639.GA11131@cmpxchg.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
	<1436958885-18754-2-git-send-email-mhocko@kernel.org>
	<20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
	<20150716071948.GC3077@dhcp22.suse.cz>
	<20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
	<20150716225639.GA11131@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Jul 2015 18:56:39 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Jul 16, 2015 at 02:34:33PM -0700, Andrew Morton wrote:
> > On Thu, 16 Jul 2015 09:19:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > I agree with Johannes who originally suggested to expose mem_cgroup that
> > > it will allow for a better code later.
> > 
> > Sure, but how *much* better?  Are there a significant number of
> > fastpath functions involved?
> > 
> > From a maintainability/readability point of view, this is quite a bad
> > patch.  It exposes a *lot* of stuff to the whole world.  We need to get
> > a pretty good runtime benefit from doing this to ourselves.  I don't
> > think that saving 376 bytes on a fatconfig build is sufficient
> > justification?
> 
> It's not a performance issue for me.  Some stuff is hard to read when
> you have memcg functions with klunky names interrupting the code flow
> to do something trivial to a struct mem_cgroup member, like
> mem_cgroup_lruvec_online() and mem_cgroup_get_lru_size().
> 
> Maybe we can keep thresholds private and encapsulate the softlimit
> tree stuff in mem_cgroup_per_zone into something private as well, as
> this is not used - and unlikely to be used - outside of memcg proper.
> 
> But otherwise, I think struct mem_cgroup should have mm-scope.

Meaning a new mm/memcontrol.h?  That's a bit better I suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
