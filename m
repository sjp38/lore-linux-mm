Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B305A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 10:37:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v10so4679736wrv.22
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 07:37:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i64si1003648wmh.151.2018.01.25.07.37.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 07:37:19 -0800 (PST)
Date: Thu, 25 Jan 2018 16:37:16 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Message-ID: <20180125153716.GT28465@dhcp22.suse.cz>
References: <20180116213008.GC8801@redhat.com>
 <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
 <20180117020502.GA3492@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117020502.GA3492@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Liubo(OS Lab)" <liubo95@huawei.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>

On Tue 16-01-18 21:05:02, Jerome Glisse wrote:
> On Wed, Jan 17, 2018 at 09:19:56AM +0800, Liubo(OS Lab) wrote:
> > On 2018/1/17 5:30, Jerome Glisse wrote:
> > > I want to talk about status of HMM and respective upstream user for
> > > it and also talk about what's next in term of features/improvement
> > > plan (generic page write protection, mmu_notifier, ...). Most likely
> > 
> > I don't think we should consider to push more code to upstream for a nobody-use feature.
> > 
> > AFAIR, Michal also mentioned that HMM need a real user/driver before upstream.
> > But I haven't seen a workable user/driver version.
> > 
> > Looks like HMM is a custom framework for Nvidia, and Nvidia would not like to open source its driver.
> > Even if nvidia really use HMM and open sourced its driver, it's probably the only user.
> > But the HMM framework touched too much core mm code.
> 
> So it is not NVidia only, they are other GPU from different company that
> intend to use HMM, i can't comment any further on timeline.
> 
> Regarding NVidia hardware i intend to have the patchset to use HMM inside
> nouveau ready before summit and post as RFC. Per drm sub-system guideline
> we can not upstream it until we also have a functional userspace stack and
> we are also working on that.

I would really appreciate to at least see some form of RFC work. It
would be a pity to have a HMM discussion anniversary without an actual
user in sight.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
