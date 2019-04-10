Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C0F4C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 21:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D92982082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 21:38:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="IuGLqpYW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D92982082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 240996B0007; Wed, 10 Apr 2019 17:38:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F4066B0008; Wed, 10 Apr 2019 17:38:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 108646B000A; Wed, 10 Apr 2019 17:38:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B43926B0007
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 17:38:28 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id f67so2365874wme.3
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:38:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LOxvXqKFPj3MVMl61HzHsAJfIq2rKeT4Ruwa8q/szlk=;
        b=q7cfa4aSjv2t5e4kdLo4PKtwAOss1WkszlFYP3KvV7cadZkG9OcInCDqLa2/BwO1yq
         WlCMjMqBj/+cCy809EraqhkGrFMv25JFGLNjjODTzCSX4baqLLIeCfjp3EzYBcuH0K6j
         6XaXBq6lv6B/8IN7zMDrvzQF1uSSbuaVWITqvSHdvz6Qf/dU3YDmAgGYyYcxVaYDoOKc
         nnOBLg8db8qfNSsB/1Pjq2M0b+6HTRE3fa4WYRCB/44j+VtdDtImclk8sBUJ9EqQSWFG
         Se3YS5Cq8B+YUnj6LavTUreCMMcFGz+IV9IimYsY8yVRClNoHO6pdJIwekf7EOyt+84L
         ktKg==
X-Gm-Message-State: APjAAAXxU+dvKPSqMQ70WJIJuyB/1WWb0JQ2j3bcEtvEMj/Esehn9Fdp
	Wsl1lOmFzUwmuY5hfYGvC6PqqO7ckBRvMgq6wTpaYQvCoOCbE0TtsiImmeqKxzgyLjWeHNqhPTs
	pNT8bfQAyK0H3JUxS6eLoXpsycYt/amdQrhRmfqSkIT/EkZUUJzydys/AVDBwlglL+w==
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr4280280wme.91.1554932308097;
        Wed, 10 Apr 2019 14:38:28 -0700 (PDT)
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr4280245wme.91.1554932307233;
        Wed, 10 Apr 2019 14:38:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554932307; cv=none;
        d=google.com; s=arc-20160816;
        b=gDcMvUPE4XBxlWO8eKISnaVQ9+19jqyMlLF22sbGxZhn0E4rBbGDVLL5PM8n91Nj5J
         XoGK6KzxZhcFfL13iRbHqEGaBbfIgbrDy6R/F5K+QIM7Il/LKIQQc3pSFdzTGGTgpUpw
         X/EJg17VPjXKjoqgaTLNpujw3hvsSm8JljOqJbUXPn+KRj0/sdxVig2diDX/oETBH+gC
         t51WNsh0WsjQQzexQP182ahTw+FYk8SHoKvr7K3c/iLvu++BdF5973ippVqUKsiwerfF
         Z3wNY8pUZu0yKvTiQS5uQ/816ClVqZdiT4BPkWQsN1nVQxGg4U+3E0f4hsPvYqrYGbbk
         6Akg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LOxvXqKFPj3MVMl61HzHsAJfIq2rKeT4Ruwa8q/szlk=;
        b=LI3qyv6SCUCpI5VWMpqwwa7JpDOnXXkxLQF3ThkfWHzj3R9za9LSv9993Y4mZpTOWt
         PX0TANBK0yj0aSXH5NmGNewXEj8ls2h6lVmHS+dQsvf03ByCw7sL7npEa+96LlyJ5Dff
         ZX9twOp+gTDInD4JlSson4H+j3QZB6WxgsSaJMYtTJJ90uMfTMt69qFRKrngvcx6fmWR
         xYlgYdxwt/QLmXTiZ6J9DGVnL1QpWcQkMD+KyXXcLZRqOWz8OvyT8iJQz47kGXIdCl5p
         Nlc+ycFUBSxH0tVo/pXPO2+fZeqXQamL2eUxXRckIX2MP5kD0l1tcYa/bCB6Tzx/11+V
         JbwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=IuGLqpYW;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor24403819wrc.29.2019.04.10.14.38.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 14:38:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=IuGLqpYW;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LOxvXqKFPj3MVMl61HzHsAJfIq2rKeT4Ruwa8q/szlk=;
        b=IuGLqpYW78+nQWkej9wKStxCq8RIIrHjSMDS6OyqdFFNNxekxJhF89osk20TuKhrEO
         MElGo2FWORrNdRRerXLqjoT6MJkaWwt2JRoVTuFYipzOQEPGknG5meN37wEVLWBVLpAF
         x5IlPyQE3C1AOSQ8B1VRa/tpNetbiGbUNZFEI=
X-Google-Smtp-Source: APXvYqzYK41wa+yBABjfRn4lLJk4EEpjyQYNII3AdqhtAf0gjYSQko7bu1DksvIQIi7STAbWZb8KZw==
X-Received: by 2002:adf:ea81:: with SMTP id s1mr7852347wrm.277.1554932306536;
        Wed, 10 Apr 2019 14:38:26 -0700 (PDT)
Received: from localhost ([2a01:4b00:8432:8a00:56e1:adff:fe3f:49ed])
        by smtp.gmail.com with ESMTPSA id j11sm49008948wrw.85.2019.04.10.14.38.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Apr 2019 14:38:25 -0700 (PDT)
Date: Wed, 10 Apr 2019 22:38:24 +0100
From: Chris Down <chris@chrisdown.name>
To: Waiman Long <longman@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Message-ID: <20190410213824.GA13638@chrisdown.name>
References: <20190410191321.9527-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190410191321.9527-1-longman@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Waiman,

Waiman Long writes:
>The current control mechanism for memory cgroup v2 lumps all the memory
>together irrespective of the type of memory objects. However, there
>are cases where users may have more concern about one type of memory
>usage than the others.

I have concerns about this implementation, and the overall idea in general. We 
had per-class memory limiting in the cgroup v1 API, and it ended up really 
poorly, and resulted in a situation where it's really hard to compose a usable 
system out of it any more.

A major part of the restructure in cgroup v2 has been to simplify things so 
that it's more easy to understand for service owners and sysadmins. This was 
intentional, because otherwise the system overall is hard to make into 
something that does what users *really* want, and users end up with a lot of 
confusion, misconfiguration, and generally an inability to produce a coherent 
system, because we've made things too hard to piece together.

In general, for purposes of resource control, I'm not convinced that it makes 
sense to limit only one kind of memory based on prior experience with v1. Can 
you give a production use case where this would be a clear benefit, traded off 
against the increase in complexity to the API?

>For simplicity, the limit is not hierarchical and applies to only tasks
>in the local memory cgroup.

We've made an explicit effort to make all things hierarchical -- this confuses 
things further. Even if we did have something like this, it would have to 
respect the hierarchy, we really don't want to return to the use_hierarchy 
days where users, sysadmins, and even ourselves are confused by the resource 
control semantics that are supposed to be achieved.

>We have customer request to limit memory consumption on anonymous memory
>only as they said the feature was available in other OSes like Solaris.

What's the production use case where this is demonstrably providing clear 
benefits in terms of resource control? How can it compose as part of an easy to 
understand, resource controlling system? I'd like to see a lot more information 
on why this is needed, and the usability and technical tradeoffs considered.

Thanks,

Chris

