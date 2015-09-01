Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 71B496B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 08:45:02 -0400 (EDT)
Received: by wicjd9 with SMTP id jd9so31832385wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:45:02 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id wh5si33092471wjb.69.2015.09.01.05.45.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 05:45:01 -0700 (PDT)
Received: by wicjd9 with SMTP id jd9so31831690wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:45:00 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:44:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150901124459.GC8810@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828174140.GN26785@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri 28-08-15 13:41:40, Tejun Heo wrote:
> On Fri, Aug 28, 2015 at 07:14:38PM +0200, Michal Hocko wrote:
> > On Fri 28-08-15 19:49:18, Vladimir Davydov wrote:
> > > On Fri, Aug 28, 2015 at 11:25:30AM -0400, Tejun Heo wrote:
> > > > On the default hierarchy, all memory consumption will be accounted
> > > > together and controlled by the same set of limits.  Always enable
> > > > kmemcg on the default hierarchy.
> > > 
> > > IMO we should introduce a boot time knob for disabling it, because kmem
> > > accounting is still not perfect, besides some users might prefer to go
> > > w/o it for performance reasons.
> > 
> > I would even argue for opt-in rather than opt-out.
> 
> Definitely not. 

The runtime overhead is not negligible and I do not see why everybody
should be paying that price by default. I can definitely see the reason why
somebody would want to enable the kmem accounting but many users will
probably never care because the kernel footprint would be in the noise
wrt. user memory.

> We wanna put all memory consumptions under the same roof by default.

But I am not sure we will ever achieve this. E.g. hugetlb memory is way
too different to be under the same charging by default IMO. Also all
the random drivers calling into the page allocator directly in the user
context would need to charge explicitly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
