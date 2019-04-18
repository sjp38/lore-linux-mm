Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E98AFC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 08:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B4B3214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 08:15:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WMYdzWgQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B4B3214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 491846B0005; Thu, 18 Apr 2019 04:15:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4416E6B0006; Thu, 18 Apr 2019 04:15:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A0C6B0007; Thu, 18 Apr 2019 04:15:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C46EC6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:15:42 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m85so264333lje.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:15:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=N323ote5HssxsLbgpRKGomemLtnlwkK3ixDMsYVRR2E=;
        b=nYNesF8PlpqOiMTnb2lCpeOdGqzEfNC/E+vIjI29mqS1E1cCWQSNv24p9Y/7WNqjsF
         8PPs/YYUEUazCeWiG+/qNV6q9aIAklKCavQD+WbvacA9DhC40BGBGkN+yQWQGORRjpBZ
         ie6tF5SnopLKQag4062cAnIXgsgI4HqHQL1j1va8vlfT0+PM7x5/g9IgsFPqkBVPk04e
         LSleaSmuOArY11Z8KjVuqSOV2tt0gcwfacDViKdOkhKjMEx6OM8ZgOKbM00jxTtI8XsQ
         c0pSaJdKUCA085Yxgu9kUyDJ4u2Zlw4NwTmE9qXd/mXbcICo+WNZ1n6AhDxvJbf9PSa+
         N0FA==
X-Gm-Message-State: APjAAAXTpRbA0UOVY8SXAKNyA6e+wr+kPdNOxUAQQMxGxVMMScQU64EB
	cMV1wJYtrXjXbC5KNxOEJuxf2eMAFmii14E13/qO4GDxDR6ca7iOE+BzTikUy2ZkpaVLh8HjM6u
	rAsz3rt+T4sqe6EiW/sY850TmLbWPlJ0+c15pV7uz4rVBHijKAk41H0PixqCMp2/rHQ==
X-Received: by 2002:a2e:3803:: with SMTP id f3mr52658322lja.165.1555575341910;
        Thu, 18 Apr 2019 01:15:41 -0700 (PDT)
X-Received: by 2002:a2e:3803:: with SMTP id f3mr52658279lja.165.1555575340744;
        Thu, 18 Apr 2019 01:15:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555575340; cv=none;
        d=google.com; s=arc-20160816;
        b=g+lmPE+k/GyWtk0iWFcvkrOCdxarP9D5qpvdt5ngEMAK9fus7qMVd/I/ql/GBx0xyB
         sfCN0maykeua6za8M6XCa9JGj/Vai4GGvM12h9hCFnReaU7iUIpyslFQ2uz61DgVyS9o
         QazY5IcOWIzKJejzQAO/SnFLTSfafAMTEYxMh2sOx6ge4XKEw5TNtVYLg/DllKQtvwbJ
         sV0Nl3OpvFT+7nka0OK3xtaymfM5cD3vH5X9/aA+uHcM8tmqrvoJ8BQP9UADUA/YZtd8
         MzywGlf71o1tNm89vTAk5Arng1PaJYxz0EZoibb4o6VDkZue4eg+VNt6zWvSU5jSo/zL
         Ay5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=N323ote5HssxsLbgpRKGomemLtnlwkK3ixDMsYVRR2E=;
        b=OZM9Tb1mPrEhwYS/dgtW6aZCufRxOkBZbsigyuNIMpjKqUvpxzGT3nXEiTL9xDorIo
         tBH5XUBRZ2VcR2wlnyo5W2NsL2KtnXK5SYWfXFycTvC4+f2Nz/o3Cu1k0Va9ibuSfCNd
         V9e6gIvsUNp2ykUSBVHNgIYYzvnpLd8ewZpv5WC43uU7UOdv4jwoaFEmbkHIqZRiNDE3
         hykBoN4sfwLEDZXnuhkQ+Dxn9yDrIJ0QlDmQd9+TnRE/SBZI/qpNeW0bzn2RSwx0oV5d
         a54enQDNhpywsBoK65KANa6A+nW1clsHETgOENKxZ9u0GxnqvfIeAdGMIHpK94dtZ9e9
         j0VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WMYdzWgQ;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l19sor631258lji.9.2019.04.18.01.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 01:15:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WMYdzWgQ;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=N323ote5HssxsLbgpRKGomemLtnlwkK3ixDMsYVRR2E=;
        b=WMYdzWgQaP+pXUvSIR0Au7VkGGsnRl6OCThTg4EgOhwD8wOevcHwx+wJU11rkan+k9
         mCfqu5ph/kf5FsMAwMRbizVoepAdM6+vYV8m+xe3GqrGQZLrsB5esZVa91DzWZxaG6Ps
         CQI0D1agoPwX01DUSe5CHaLm8J7aoOzub6m+L+4eXpRxTVNMFl63TopOk4asM/HDoQlS
         SIgpzsz5OVI5ASSTTtdc2vJHlGZOiKZr3LDH9KGpW+udXkX4/irjjCCJYf3woOXsCdc+
         bYiVHodrDUaDggrr7a987OZYleMblygMql7e4P6dBn4GyZqk4Q+uLeM0JfRQKuTgb1Yr
         1exA==
X-Google-Smtp-Source: APXvYqzjkJpTHMK9RphN01MaAEQ8Cpo3cxvjAigAn5Tcf7lTFuZs3fK5+TNTiM3+kSzXVyIh+XiNCw==
X-Received: by 2002:a2e:8316:: with SMTP id a22mr10057018ljh.171.1555575340347;
        Thu, 18 Apr 2019 01:15:40 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id v11sm296970lfb.68.2019.04.18.01.15.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 01:15:39 -0700 (PDT)
Date: Thu, 18 Apr 2019 11:15:38 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guroan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	david@fromorbit.com, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>, cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 0/5] mm: reparent slab memory on cgroup removal
Message-ID: <20190418081538.prspe27lqudvvu3u@esperanza>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Roman,

On Wed, Apr 17, 2019 at 02:54:29PM -0700, Roman Gushchin wrote:
> There is however a significant problem with reparenting of slab memory:
> there is no list of charged pages. Some of them are in shrinker lists,
> but not all. Introducing of a new list is really not an option.

True, introducing a list of charged pages would negatively affect
SL[AU]B performance since we would need to protect it with some kind
of lock.

> 
> But fortunately there is a way forward: every slab page has a stable pointer
> to the corresponding kmem_cache. So the idea is to reparent kmem_caches
> instead of slab pages.
> 
> It's actually simpler and cheaper, but requires some underlying changes:
> 1) Make kmem_caches to hold a single reference to the memory cgroup,
>    instead of a separate reference per every slab page.
> 2) Stop setting page->mem_cgroup pointer for memcg slab pages and use
>    page->kmem_cache->memcg indirection instead. It's used only on
>    slab page release, so it shouldn't be a big issue.
> 3) Introduce a refcounter for non-root slab caches. It's required to
>    be able to destroy kmem_caches when they become empty and release
>    the associated memory cgroup.

Which means an unconditional atomic inc/dec on charge/uncharge paths
AFAIU. Note, we have per cpu batching so charging a kmem page in cgroup
v2 doesn't require an atomic variable modification. I guess you could
use some sort of per cpu ref counting though.

Anyway, releasing mem_cgroup objects, but leaving kmem_cache objects
dangling looks kinda awkward to me. It would be great if we could
release both, but I assume it's hardly possible due to SL[AU]B
complexity.

What about reusing dead cgroups instead? Yeah, it would be kinda unfair,
because a fresh cgroup would get a legacy of objects left from previous
owners, but still, if we delete a cgroup, the workload must be dead and
so apart from a few long-lived objects, there should mostly be cached
objects charged to it, which should be easily released on memory
pressure. Sorry if somebody's asked this question before - I must have
missed that.

Thanks,
Vladimir

