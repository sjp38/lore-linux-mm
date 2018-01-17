Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD08C280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:05:07 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id d25so11479662otc.1
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:05:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19si1319589oii.311.2018.01.16.18.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 18:05:06 -0800 (PST)
Date: Tue, 16 Jan 2018 21:05:02 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Message-ID: <20180117020502.GA3492@redhat.com>
References: <20180116213008.GC8801@redhat.com>
 <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liubo(OS Lab)" <liubo95@huawei.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

On Wed, Jan 17, 2018 at 09:19:56AM +0800, Liubo(OS Lab) wrote:
> On 2018/1/17 5:30, Jerome Glisse wrote:
> > I want to talk about status of HMM and respective upstream user for
> > it and also talk about what's next in term of features/improvement
> > plan (generic page write protection, mmu_notifier, ...). Most likely
> 
> I don't think we should consider to push more code to upstream for a nobody-use feature.
> 
> AFAIR, Michal also mentioned that HMM need a real user/driver before upstream.
> But I haven't seen a workable user/driver version.
> 
> Looks like HMM is a custom framework for Nvidia, and Nvidia would not like to open source its driver.
> Even if nvidia really use HMM and open sourced its driver, it's probably the only user.
> But the HMM framework touched too much core mm code.

So it is not NVidia only, they are other GPU from different company that
intend to use HMM, i can't comment any further on timeline.

Regarding NVidia hardware i intend to have the patchset to use HMM inside
nouveau ready before summit and post as RFC. Per drm sub-system guideline
we can not upstream it until we also have a functional userspace stack and
we are also working on that.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
