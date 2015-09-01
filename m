Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 91A536B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 14:52:00 -0400 (EDT)
Received: by qkcj187 with SMTP id j187so55719310qkc.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 11:52:00 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 11si15297326qgg.24.2015.09.01.11.51.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 11:52:00 -0700 (PDT)
Received: by qkcj187 with SMTP id j187so55718790qkc.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 11:51:59 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:51:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150901185157.GD18956@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
 <20150828174140.GN26785@mtj.duckdns.org>
 <20150901124459.GC8810@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901124459.GC8810@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello,

On Tue, Sep 01, 2015 at 02:44:59PM +0200, Michal Hocko wrote:
> The runtime overhead is not negligible and I do not see why everybody
> should be paying that price by default. I can definitely see the reason why
> somebody would want to enable the kmem accounting but many users will
> probably never care because the kernel footprint would be in the noise
> wrt. user memory.

We said the same thing about hierarchy support.  Sure, it's not the
same but I think it's wiser to keep the architectural decisions at a
higher level.  I don't think kmem overhead is that high but if this
actually is a problem we'd need a per-cgroup knob anyway.

> > We wanna put all memory consumptions under the same roof by default.
> 
> But I am not sure we will ever achieve this. E.g. hugetlb memory is way
> too different to be under the same charging by default IMO. Also all
> the random drivers calling into the page allocator directly in the user
> context would need to charge explicitly.

Oh I meant the big ones.  I don't think we'll achieve 100% coverage
either but even just catching the major ones, kmem and tcp socket
buffers, should remove most ambiguities around memory consumption.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
