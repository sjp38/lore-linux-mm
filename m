Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C322C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5462F20823
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:58:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5462F20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E14576B0007; Tue, 26 Mar 2019 09:58:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC39F6B0008; Tue, 26 Mar 2019 09:58:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB4316B000A; Tue, 26 Mar 2019 09:58:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 781476B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:58:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so3980721edq.0
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jOU6xt3JX5VunDgNyH+hQn9oq6Ym3Db0TOcBzrXZYUU=;
        b=AOQhStceLook1aiuwmX8FVOaSBLABBDU0EKVJkly4/soN/1wHBIffQYOjdDLX9aJcr
         6mzB8FjrNrzzmxtC1VDQBdVyRrejjj4GIDqBKZZb56NxsYDjYjpdPSKBp7qpVmXgRRj5
         12NnW0eS/T/+2ELXFY7QLuRGkGMiYt6cXcsE43+r0PqLDoQWPF0fsrbFYCE4/jM2lkBO
         4g/+1emqO90ljqOlcitvE+7hsanKCYvDoJtQVvWVGj5FGUE++KC/1IWekN3bSAZoEkIt
         ghKtlgFMxyaZC0JVwAAllz7qfGXOJqdceJeJf4r4Tt//22/Cj3ezKDThBRpsmfrazEhs
         lIuQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWk42/woFvC3qflY8B/0+DAqBtQLzHsI7mrva0WQ0gQHOlDEnBv
	8Twmw25IfIkmTsc58l/L4LDM9PWRoBNLhuedFq3x8K66c1UYd1TjTBC3iQOscDDQGxn1besv4sJ
	wB0h+PfjMHMeK8FITwdjLtjoNUUJfAF6QHdq+TC/PDDgILP02LdoJMow/1T0Rz28=
X-Received: by 2002:a50:8854:: with SMTP id c20mr20140294edc.167.1553608723016;
        Tue, 26 Mar 2019 06:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhr6DgfBi3QzDw4OO+Vg0dTAFE7xYg6wzsn44Zh/NfXf6HnXqWhcP8jjCQe4r9gbi2ZBys
X-Received: by 2002:a50:8854:: with SMTP id c20mr20140254edc.167.1553608722093;
        Tue, 26 Mar 2019 06:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553608722; cv=none;
        d=google.com; s=arc-20160816;
        b=dowpTFLFB3tWgnW7PZuoQY9TYmSCHGa127QL3MGexx/HKTTHWbLnYPjw+7gMgMwHH+
         uL1flqGAuzH6TidWTIAulx53sArsEptzDKnPq+JdEqDGY7vrzQszynhXsIJBz6Q9bvEp
         6a+urkzptACBYqaURnIo57XUTk2/mzy1jGZ4PKgLPqn3g55Nfg2JTlR/25jNtwRuhCNj
         psFXQlJEyxpagZVvNkZ41VhGJa0sEc0O61WwM5VArwkN8/O9ROcnGAoIovgwrJ6wanMi
         //vI3xsUEn13GKhe2n1MZVcd8FMywcbhAAyMYPeNxrKcmqHd6vd+TkxRmV3ZdKBo8Q/D
         6Sjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jOU6xt3JX5VunDgNyH+hQn9oq6Ym3Db0TOcBzrXZYUU=;
        b=Af+pNuSbL+ykTopcnOJPykqNMMmlvSgBvGYWIZ1VIb3UZmfekWFhkD6P1xHzNt/B9T
         IYtopPtaPX7OuBJWHehDZ+XCLE5tcBDAnjsKo4lEyYGIyeZyWrN83o6fgrlNRS4196Bn
         ZjVlyrEzSd2aaM1tUo2mEQcdyneF9z/0Yw/QfrZCbFWpO50gRXFaVOowA50/HKxu0ro7
         vdvzJRlAWHzsa7tPFRtldsK6GhnOCqIXIjG0KXVOEXqn3zkf4AmzuK4+/JByAZjtH22U
         tsL4QsS0FS/flndbT/mWBO8MHIj5y8/Oi8pcQFsr7zq43AFkQUyfZrs53CFYcbfg/gje
         bT1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si522597ejr.240.2019.03.26.06.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:58:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1C7FFAC8E;
	Tue, 26 Mar 2019 13:58:40 +0000 (UTC)
Date: Tue, 26 Mar 2019 14:58:37 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190326135837.GP28406@dhcp22.suse.cz>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 23-03-19 12:44:25, Yang Shi wrote:
> 
> With Dave Hansen's patches merged into Linus's tree
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
> 
> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
> effectively and efficiently is still a question. 
> 
> There have been a couple of proposals posted on the mailing list [1] [2].
> 
> The patchset is aimed to try a different approach from this proposal [1]
> to use PMEM as NUMA nodes.
> 
> The approach is designed to follow the below principles:
> 
> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
> 
> 2. DRAM first/by default. No surprise to existing applications and default
> running. PMEM will not be allocated unless its node is specified explicitly
> by NUMA policy. Some applications may be not very sensitive to memory latency,
> so they could be placed on PMEM nodes then have hot pages promote to DRAM
> gradually.

Why are you pushing yourself into the corner right at the beginning? If
the PMEM is exported as a regular NUMA node then the only difference
should be performance characteristics (module durability which shouldn't
play any role in this particular case, right?). Applications which are
already sensitive to memory access should better use proper binding already.
Some NUMA topologies might have quite a large interconnect penalties
already. So this doesn't sound like an argument to me, TBH.

> 5. Control memory allocation and hot/cold pages promotion/demotion on per VMA
> basis.

What does that mean? Anon vs. file backed memory?

[...]

> 2. Introduce a new mempolicy, called MPOL_HYBRID to keep other mempolicy
> semantics intact. We would like to have memory placement control on per process
> or even per VMA granularity. So, mempolicy sounds more reasonable than madvise.
> The new mempolicy is mainly used for launching processes on PMEM nodes then
> migrate hot pages to DRAM nodes via NUMA balancing. MPOL_BIND could bind to
> PMEM nodes too, but migrating to DRAM nodes would just break the semantic of
> it. MPOL_PREFERRED can't constraint the allocation to PMEM nodes. So, it sounds
> a new mempolicy is needed to fulfill the usecase.

The above restriction pushes you to invent an API which is not really
trivial to get right and it seems quite artificial to me already.

> 3. The new mempolicy would promote pages to DRAM via NUMA balancing. IMHO, I
> don't think kernel is a good place to implement sophisticated hot/cold page
> distinguish algorithm due to the complexity and overhead. But, kernel should
> have such capability. NUMA balancing sounds like a good start point.

This is what the kernel does all the time. We call it memory reclaim.

> 4. Promote twice faulted page. Use PG_promote to track if a page is faulted
> twice. This is an optimization to NUMA balancing to reduce the migration
> thrashing and overhead for migrating from PMEM.

I am sorry, but page flags are an extremely scarce resource and a new
flag is extremely hard to get. On the other hand we already do have
use-twice detection for mapped page cache (see page_check_references). I
believe we can generalize that to anon pages as well.

> 5. When DRAM has memory pressure, demote page to PMEM via page reclaim path.
> This is quite similar to other proposals. Then NUMA balancing will promote
> page to DRAM as long as the page is referenced again. But, the
> promotion/demotion still assumes two tier main memory. And, the demotion may
> break mempolicy.

Yes, this sounds like a good idea to me ;)

> 6. Anonymous page only for the time being since NUMA balancing can't promote
> unmapped page cache.

As long as the nvdimm access is faster than the regular storage then
using any node (including pmem one) should be OK.
-- 
Michal Hocko
SUSE Labs

