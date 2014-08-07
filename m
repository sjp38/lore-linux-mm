Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 828626B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 09:39:23 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id f8so1032170wiw.3
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:39:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bm8si6917134wjb.103.2014.08.07.06.39.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 06:39:21 -0700 (PDT)
Date: Thu, 7 Aug 2014 15:39:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/4] mm: memcontrol: add memory.current and memory.high
 to default hierarchy
Message-ID: <20140807133920.GD12730@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-3-git-send-email-hannes@cmpxchg.org>
 <20140807133614.GC12730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140807133614.GC12730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 07-08-14 15:36:14, Michal Hocko wrote:
> On Mon 04-08-14 17:14:55, Johannes Weiner wrote:
> [...]
> > @@ -132,6 +137,19 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
> >  u64 res_counter_uncharge_until(struct res_counter *counter,
> >  			       struct res_counter *top,
> >  			       unsigned long val);
> > +
> > +static inline unsigned long long res_counter_high(struct res_counter *cnt)
> 
> soft limit used res_counter_soft_limit_excess which has quite a long
> name but at least those two should be consistent.
> I will post two helper patches which I have used to make this and other
> operations on res counter easier as a reply to this.

These two are sleeping in my queue for quite some time. I didn't get to
post them yet but if you think they will make sense I can try to rebase
them on the current tree and post.
---
