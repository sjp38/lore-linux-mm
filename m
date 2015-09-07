Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B4DB56B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 07:03:17 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so79742800wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:03:17 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id bk4si15077844wib.2.2015.09.07.04.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 04:03:16 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so41535143wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:03:16 -0700 (PDT)
Date: Mon, 7 Sep 2015 13:03:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150907110315.GF6022@dhcp22.suse.cz>
References: <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
 <20150901185157.GD18956@htj.dyndns.org>
 <20150904133038.GC8220@dhcp22.suse.cz>
 <20150904153810.GD13699@esperanza>
 <20150907093905.GD6022@dhcp22.suse.cz>
 <20150907100110.GA31800@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150907100110.GA31800@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon 07-09-15 13:01:10, Vladimir Davydov wrote:
> On Mon, Sep 07, 2015 at 11:39:06AM +0200, Michal Hocko wrote:
> ...
> > > > I might be wrong here of course but if the default should be switched it
> > > > would deserve a better justification with some numbers so that people
> > > > can see the possible drawbacks.
> > > 
> > > Personally, I'd prefer to have it switched on by default, because it
> > > would force people test it and report bugs and performance degradation.
> > > If one finds it really crappy, he/she should be able to disable it.
> > 
> > I do not think this is the way of introducing new functionality. You do
> > not want to force users to debug your code and go let it disable if it
> > is too crappy.
> 
> One must first enable CONFIG_KMEM, which is off by default.

Yes, but let's be realistic here. People tend to use distribution
kernels and so the config option will have to be enabled.
 
> Anyway, we aren't talking about enabling it by default in the legacy
> hierarchy, only in the unified hierarchy, which must be explicitly
> enabled by passing __DEVEL__save_behavior. I think that's enough.

But once it is set like that in default then it will stay even when the
__DEVEL__ part is dropped. 
 
> > > > I agree that the per-cgroup knob is better than the global one. We
> > > 
> > > Not that sure :-/
> > 
> > Why?
> 
> I'm not sure there is use cases which need having kmem acct enabled in
> one cgroup and disabled in another.

What would be the downside though? It is true that all the static keys
will be enabled in these configurations so even the non-enabled path
would pay some overhead but that should be still close to unmeasurable
(I haven't measured that so I might be wrong here).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
