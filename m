Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E811BC072B1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEAEF2070D
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:22:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="v5k5yiAE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEAEF2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44EA96B027F; Tue, 28 May 2019 21:22:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FFEC6B0282; Tue, 28 May 2019 21:22:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A0026B0286; Tue, 28 May 2019 21:22:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E58B96B027F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 21:22:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d125so619220pfd.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 18:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=7hiqTDVHP7ycUHBATDRFOTjH/h1L38jFsXVu8jDFuS0=;
        b=Jo79xd821kD5O+zzfrqqgFM77RuUCRLOOhFAj9/bLJU6yq3oyo7jG9pyn2NXZPYtrh
         wyiUfFF8jEl90BzyUaLu1xtowsuVvU8EIHMsV1FFPFMywbhn3fS5ZgpIMB0DHVq8FG+i
         b7jZ7W3KuHRe39Tld17pxHN91NeqMcbQuTGoUHRzLG3wxJO+amJ+MTQ3dRauwImrWxUm
         H4HWLUyMGqQUC6O1fVDQjLKyL88LCOnspiADxlkIl1JtXzYh2L5CSqnas3duqE9kY2VD
         oCVma2UWq+88AqdjGW84sQnFska8VPLQ9kxwLxatM0Ex+BYJbbdadn9rk0QzTkqXa0+F
         rI3w==
X-Gm-Message-State: APjAAAUftFBU/kb3pTYd7xAGX1B/QwEUyGT083ms0Ya+WkEP9/RtHH5O
	E/B/zpsHWhU6Vlhnw9KpVddYdOLDhRv0go8RUYsACkHs8afbFqKrlZVppZ96D7mc68gVbeBLhJG
	AVNhrdpj2jvbWpvWygtyKk4+kEGSIhET9A/z4KfJLeak0NBDa5NRogx4Hf26tr86qKw==
X-Received: by 2002:a63:2d0:: with SMTP id 199mr77754455pgc.188.1559092972418;
        Tue, 28 May 2019 18:22:52 -0700 (PDT)
X-Received: by 2002:a63:2d0:: with SMTP id 199mr77754413pgc.188.1559092971494;
        Tue, 28 May 2019 18:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559092971; cv=none;
        d=google.com; s=arc-20160816;
        b=FnUAKLvZhOIC/S7iQGBEl/b3IEoDsfRipbePtM5V96lDC4iFsiBtQyOy+NQfpaJIaM
         K6ffQnO0QaBiV6irlEFFxQnys/mn79I6TOsX6A71zPtVjp/hH2bg+76vudaAh8Vs5Szo
         Z/s1mRUF69imkZwK4nerUU3qxcr/96/ZVP6K1wx7Vl8k1Upa11TSZl1LzB6JDl3V1yT3
         Q3FDNHnA4M8RgF9yXtfTvAeOaoaVKbv6vQgCNIlYS8KuEMyTwj5hvV+xgBaOiLBbscuU
         R0hY6qDf+fSnMK3NjUypmo6T+ycTde5kpV9dJx+z742JEEu32ehlsYN9CI04JBbzqojL
         HLOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=7hiqTDVHP7ycUHBATDRFOTjH/h1L38jFsXVu8jDFuS0=;
        b=0mS5/bFCeJ3Yn3eN1zkWMbo/BLGKQFgvyPMG79riaNNcrsYjSfoIwR85hIc66ykf4r
         sofOOmnWyruGMWB/h023Ce/bkhAOCziP2GJygwkBF/vGY2FjfwJRnEzYfT2KtQYf1C5k
         UrctgDTDqTlP1NUarSscVq7gbb8e+57w8SqT+StZzIJaUnNQpCO9SIYNwYLFkroJ5PeF
         3lQTAdtw20eg6QlXJ2PuH7FxpeSIF2PUJAjOf7xvZ9DMbyXXtNqbRMAzkGE+0gjPIPOU
         L2rAw4w7MBEGasWIVt7xlADIovi8Js7eub9qsFWgl2t43vnJ9uKYSNdkl0sW/jehgwOy
         y6Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=v5k5yiAE;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor14893466pgv.42.2019.05.28.18.22.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 18:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=v5k5yiAE;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=7hiqTDVHP7ycUHBATDRFOTjH/h1L38jFsXVu8jDFuS0=;
        b=v5k5yiAEtdR51yLQSHl2C6JH8A1Af23+g41mDYdOwzAoVr8XvhXKy1cPAVR6T0zU9o
         LKnKBxafam9LaCEh3d+X5rKOkdouDjXgxTU6wQdOdlH4rUoGs1PTtm0H8aqJft+sNE/a
         Dw5goKxS0owGNFLVDkYUFBHumuPjbss/4pvtFMe30flVdpHTQRcqv6CtN7yfsHfQvsmY
         LZlFDrSof0jt1RVozI2kRAsyiKNrNpK7UKuZvdFmVfuwmq7CZMGeLiaJc+/zlBjvW1Oc
         x+HA1SC43P3UPEpLYGOotPb8OTta16UBQX0fl66ySL8X1HM9OFvIPgcCpoQt0Vw9J8E1
         pVMA==
X-Google-Smtp-Source: APXvYqy1irI5QOZSUt4gtC8U1zUDRgiytinvm+UkUXfHcoCwlJ2WUV+f+Jk3GqWNPCEJQLSYfQ0+Ew==
X-Received: by 2002:a63:490a:: with SMTP id w10mr32183693pga.6.1559092970775;
        Tue, 28 May 2019 18:22:50 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id a7sm15705665pgj.42.2019.05.28.18.22.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 18:22:50 -0700 (PDT)
Date: Tue, 28 May 2019 18:22:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com, 
    kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com, 
    akpm@linux-foundation.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/3] Make deferred split shrinker memcg aware
In-Reply-To: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1905281817090.86034@chino.kir.corp.google.com>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 May 2019, Yang Shi wrote:

> 
> I got some reports from our internal application team about memcg OOM.
> Even though the application has been killed by oom killer, there are
> still a lot THPs reside, page reclaim doesn't reclaim them at all.
> 
> Some investigation shows they are on deferred split queue, memcg direct
> reclaim can't shrink them since THP deferred split shrinker is not memcg
> aware, this may cause premature OOM in memcg.  The issue can be
> reproduced easily by the below test:
> 

Right, we've also encountered this.  I talked to Kirill about it a week or 
so ago where the suggestion was to split all compound pages on the 
deferred split queues under the presence of even memory pressure.

That breaks cgroup isolation and perhaps unfairly penalizes workloads that 
are running attached to other memcg hierarchies that are not under 
pressure because their compound pages are now split as a side effect.  
There is a benefit to keeping these compound pages around while not under 
memory pressure if all pages are subsequently mapped again.

> $ cgcreate -g memory:thp
> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
> $ cgexec -g memory:thp ./transhuge-stress 4000
> 
> transhuge-stress comes from kernel selftest.
> 
> It is easy to hit OOM, but there are still a lot THP on the deferred split
> queue, memcg direct reclaim can't touch them since the deferred split
> shrinker is not memcg aware.
> 

Yes, we have seen this on at least 4.15 as well.

> Convert deferred split shrinker memcg aware by introducing per memcg deferred
> split queue.  The THP should be on either per node or per memcg deferred
> split queue if it belongs to a memcg.  When the page is immigrated to the
> other memcg, it will be immigrated to the target memcg's deferred split queue
> too.
> 
> And, move deleting THP from deferred split queue in page free before memcg
> uncharge so that the page's memcg information is available.
> 
> Reuse the second tail page's deferred_list for per memcg list since the same
> THP can't be on multiple deferred split queues at the same time.
> 
> Remove THP specific destructor since it is not used anymore with memcg aware
> THP shrinker (Please see the commit log of patch 2/3 for the details).
> 
> Make deferred split shrinker not depend on memcg kmem since it is not slab.
> It doesn't make sense to not shrink THP even though memcg kmem is disabled.
> 
> With the above change the test demonstrated above doesn't trigger OOM anymore
> even though with cgroup.memory=nokmem.
> 

I'm curious if your internal applications team is also asking for 
statistics on how much memory can be freed if the deferred split queues 
can be shrunk?  We have applications that monitor their own memory usage 
through memcg stats or usage and proactively try to reduce that usage when 
it is growing too large.  The deferred split queues have significantly 
increased both memcg usage and rss when they've upgraded kernels.

How are your applications monitoring how much memory from deferred split 
queues can be freed on memory pressure?  Any thoughts on providing it as a 
memcg stat?

Thanks!

