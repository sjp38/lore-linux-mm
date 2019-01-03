Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA99A8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:23:42 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so34383909edc.9
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:23:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si426116edv.186.2019.01.03.11.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:23:41 -0800 (PST)
Date: Thu, 3 Jan 2019 20:23:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
Message-ID: <20190103192339.GA31793@dhcp22.suse.cz>
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190103101215.GH31793@dhcp22.suse.cz>
 <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
 <20190103181329.GW31793@dhcp22.suse.cz>
 <6f43e926-3bb5-20d1-2e39-1d30bf7ad375@linux.alibaba.com>
 <20190103185333.GX31793@dhcp22.suse.cz>
 <d610c665-890f-3bf0-1e2a-437150b6ddfb@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d610c665-890f-3bf0-1e2a-437150b6ddfb@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 11:10:00, Yang Shi wrote:
> 
> 
> On 1/3/19 10:53 AM, Michal Hocko wrote:
> > On Thu 03-01-19 10:40:54, Yang Shi wrote:
> > > 
> > > On 1/3/19 10:13 AM, Michal Hocko wrote:
[...]
> > > > Is there any reason for your scripts to be strictly sequential here? In
> > > > other words why cannot you offload those expensive operations to a
> > > > detached context in _userspace_?
> > > I would say it has not to be strictly sequential. The above script is just
> > > an example to illustrate the pattern. But, sometimes it may hit such pattern
> > > due to the complicated cluster scheduling and container scheduling in the
> > > production environment, for example the creation process might be scheduled
> > > to the same CPU which is doing force_empty. I have to say I don't know too
> > > much about the internals of the container scheduling.
> > In that case I do not see a strong reason to implement the offloding
> > into the kernel. It is an additional code and semantic to maintain.
> 
> Yes, it does introduce some additional code and semantic, but IMHO, it is
> quite simple and very straight forward, isn't it? Just utilize the existing
> css offline worker. And, that a couple of lines of code do improve some
> throughput issues for some real usecases.

I do not really care it is few LOC. It is more important that it is
conflating force_empty into offlining logic. There was a good reason to
remove reparenting/emptying the memcg during the offline. Considering
that you can offload force_empty from userspace trivially then I do not
see any reason to implement it in the kernel.

> > I think it is more important to discuss whether we want to introduce
> > force_empty in cgroup v2.
> 
> We would prefer have it in v2 as well.

Then bring this up in a separate email thread please.
-- 
Michal Hocko
SUSE Labs
