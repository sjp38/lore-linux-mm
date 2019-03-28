Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B972C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 08:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E40AA2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 08:21:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="x2JnfuyN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E40AA2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 616276B0003; Thu, 28 Mar 2019 04:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5A16B0006; Thu, 28 Mar 2019 04:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC2A6B0007; Thu, 28 Mar 2019 04:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8B86B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 04:21:17 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h5so8042297oih.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 01:21:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=77jRvNRDYvOYIIwmPFjd/sDUifx+fyO+d5UR0CetH+8=;
        b=iko3rPU1noqhPgxjrIuNrgzIvBwqeitT9C93KxZdd0sHVZgVE50UIkYIfLZoX/pWRw
         z0Vy4bwLeS8aWl059ZuX7u8Z6/pzg2IubZOsIBxNN0FNaImsOjrr/a/PbgfWEOl7K9ft
         NrpM8tM/Nyh4JlBHWeX8hbwP/mEnZLLf2v6T3mwswtnwv5MqNCUXr2dcMeS3RLYnTWmu
         Bl5kDwEfFbFSxBgLsTvR01gqtAW/uSdPIxS+V8/DXSyzkPr5dBRhBxEgXDa1PLVTmG5r
         NAS2s2AcDe6NnWqKesQgqu6k+NBqgnEM7131CymGDtfmdJ5P6cj5s/KwgjzaOgFuiVgP
         My3A==
X-Gm-Message-State: APjAAAWpWIXIsuYHpRZSLVTp+ma+LIieLhQ6ed4Z4mdhJgxPl4/tMUfG
	nAtZvTFlIb+9u2mUGK1Iloq5/OqFE080NYCCvBiRVMPrFMfBZRJ/MRMvqeh1l80/V2AVM3FR+hj
	eiXR/yK58YBse6jFZdPYaF4TpfpYbWLSXSS14yGvrlM03MBFj+1Xbb49U2+wD2yeQ5A==
X-Received: by 2002:a9d:694e:: with SMTP id p14mr4068687oto.193.1553761276735;
        Thu, 28 Mar 2019 01:21:16 -0700 (PDT)
X-Received: by 2002:a9d:694e:: with SMTP id p14mr4068638oto.193.1553761275706;
        Thu, 28 Mar 2019 01:21:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553761275; cv=none;
        d=google.com; s=arc-20160816;
        b=kV8xPfa2FcO7PV4Pg1rNpvWy0IWi8DNquzitxUeio21FkJZWBMmLYCQViye9HOg3X5
         MFiWSAawri5hkVkYOqqAhAHXGTn63NNRPsYbR0aH4SzUV6GqQvLkh21P2PRo3B4aMrb8
         30k0D9hLbT1mfOz/1kDN2tBZ/umcIZZeLr7sGSsfoCzPbxdms2dVZs4Qh3so522y5Aam
         R4oby0yaY6C1f5uigHYYhebW3FH7kN57xY4ioVGXtZnPATV90a6zHrcyZFpu5soXJdry
         7orp2f4dScuuQIH5+LOR+f2de7QD0mZTP72v+I7yA+dZi9zBGP/HUVksKed36PjEUz6m
         v07w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=77jRvNRDYvOYIIwmPFjd/sDUifx+fyO+d5UR0CetH+8=;
        b=FUtwDBuDMBBKNAmKDPSwlflGlfxcrwPX/0HGiOPL+ESaTkxOxCKrYDvUUAok1E3yGY
         hMtPV6TYcSHVAqLdoRpYmYae8Ywo+mJwIrs14wTphdNAe6m6Trj96ELG+KtjSPd36VvU
         H+9XlRI+9VtAdubt8xN9GxQ0RZLnipPuiJzbpdIEpfyVASEZxpgR2S2xMLh5mP60zTXI
         zb1Erk5g0uVFEMGcJSwVS1IPHiV+UmGKuHj/MlCoEYOK9jFt4D6iDwjGtProkbUFufWR
         jwev8RqIRlbV4eit054T4/WbEkgecjWBpwJwrQAhZK8IMHxeoTYsdwaWkTVIKwmPmc4l
         mTZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=x2JnfuyN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u190sor14329082oif.156.2019.03.28.01.21.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 01:21:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=x2JnfuyN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=77jRvNRDYvOYIIwmPFjd/sDUifx+fyO+d5UR0CetH+8=;
        b=x2JnfuyNdHPAlLNql7+Hd+SIRPDYgD49+I3PBuwvdsWB3cuDoDV8QGLwo0NpqvN9/X
         KrPk/6cdaxf6pXJdbxK2KC8FbkBvLIUjydhssTiKJxkHkM6k2uxmA21cWqC3biP6ZjVB
         up/F6AENtCBV2rJmLVrvG9kSe64MIpMzf9J4WSvVOsJMWSAe567u30iM4Zb9aK7MaWoX
         5K/9ejxMvEgEfPG+EMO353pkAwP9A0CFKoQHspa6bo6Q+bJXLBXGOnH9iQZrHJinQzGg
         uobwkWeh8RhT7FoycdocpKohPG1l3ax2SjteWTsxWClXHOjmg2MJNzLvTMoI9xF9fo5C
         n/GA==
X-Google-Smtp-Source: APXvYqwUDaQSZRlXkxLdn8Ktoc7WDC+3ppHol9nwM1pxOZhHFWsQT1TKlLs73I8ZPb5FRaOOtzcq5GgbEYyMY53kW3g=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr19187454oih.105.1553761275036;
 Thu, 28 Mar 2019 01:21:15 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz> <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz> <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz> <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com> <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
In-Reply-To: <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Mar 2019 01:21:03 -0700
Message-ID: <CAPcyv4g2FuormkwNNWy7kU4JF6_-sX3WnSVS7YggMJMMOCehMQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 7:09 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
> On 3/27/19 1:09 PM, Michal Hocko wrote:
> > On Wed 27-03-19 11:59:28, Yang Shi wrote:
> >>
> >> On 3/27/19 10:34 AM, Dan Williams wrote:
> >>> On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> >>>> On Tue 26-03-19 19:58:56, Yang Shi wrote:
> > [...]
> >>>>> It is still NUMA, users still can see all the NUMA nodes.
> >>>> No, Linux NUMA implementation makes all numa nodes available by default
> >>>> and provides an API to opt-in for more fine tuning. What you are
> >>>> suggesting goes against that semantic and I am asking why. How is pmem
> >>>> NUMA node any different from any any other distant node in principle?
> >>> Agree. It's just another NUMA node and shouldn't be special cased.
> >>> Userspace policy can choose to avoid it, but typical node distance
> >>> preference should otherwise let the kernel fall back to it as
> >>> additional memory pressure relief for "near" memory.
> >> In ideal case, yes, I agree. However, in real life world the performance is
> >> a concern. It is well-known that PMEM (not considering NVDIMM-F or HBM) has
> >> higher latency and lower bandwidth. We observed much higher latency on PMEM
> >> than DRAM with multi threads.
> > One rule of thumb is: Do not design user visible interfaces based on the
> > contemporary technology and its up/down sides. This will almost always
> > fire back.
>
> Thanks. It does make sense to me.
>
> >
> > Btw. if you keep arguing about performance without any numbers. Can you
> > present something specific?
>
> Yes, I did have some numbers. We did simple memory sequential rw latency
> test with a designed-in-house test program on PMEM (bind to PMEM) and
> DRAM (bind to DRAM). When running with 20 threads the result is as below:
>
>               Threads          w/lat            r/lat
> PMEM      20                537.15         68.06
> DRAM      20                14.19           6.47
>
> And, sysbench test with command: sysbench --time=600 memory
> --memory-block-size=8G --memory-total-size=1024T --memory-scope=global
> --memory-oper=read --memory-access-mode=rnd --rand-type=gaussian
> --rand-pareto-h=0.1 --threads=1 run
>
> The result is:
>                     lat/ms
> PMEM      103766.09
> DRAM      31946.30
>
> >
> >> In real production environment we don't know what kind of applications would
> >> end up on PMEM (DRAM may be full, allocation fall back to PMEM) then have
> >> unexpected performance degradation. I understand to have mempolicy to choose
> >> to avoid it. But, there might be hundreds or thousands of applications
> >> running on the machine, it sounds not that feasible to me to have each
> >> single application set mempolicy to avoid it.
> > we have cpuset cgroup controller to help here.
> >
> >> So, I think we still need a default allocation node mask. The default value
> >> may include all nodes or just DRAM nodes. But, they should be able to be
> >> override by user globally, not only per process basis.
> >>
> >> Due to the performance disparity, currently our usecases treat PMEM as
> >> second tier memory for demoting cold page or binding to not memory access
> >> sensitive applications (this is the reason for inventing a new mempolicy)
> >> although it is a NUMA node.
> > If the performance sucks that badly then do not use the pmem as NUMA,
> > really. There are certainly other ways to export the pmem storage. Use
> > it as a fast swap storage. Or try to work on a swap caching mechanism
> > that still allows much faster access than a slow swap storage. But do
> > not try to pretend to abuse the NUMA interface while you are breaking
> > some of its long term established semantics.
>
> Yes, we are looking into using it as a fast swap storage too and perhaps
> other usecases.
>
> Anyway, though nobody thought it makes sense to restrict default
> allocation nodes, it sounds over-engineered. I'm going to drop it.
>
> One question, when doing demote and promote we need define a path, for
> example, DRAM <-> PMEM (assume two tier memory). When determining what
> nodes are "DRAM" nodes, does it make sense to assume the nodes with both
> cpu and memory are DRAM nodes since PMEM nodes are typically cpuless nodes?

For ACPI platforms the HMAT is effectively going to enforce "cpu-less"
nodes for any memory range that has differentiated performance from
the conventional memory pool, or differentiated performance for a
specific initiator. So "memory-less == PMEM" is not a robust
assumption.

The plan is to use the HMAT to populate the default fallback order,
but allow for an override if the HMAT information is missing or
incorrect.

