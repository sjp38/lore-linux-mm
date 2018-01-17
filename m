Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5CD280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 20:22:49 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so7143459pln.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:22:49 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id d187si2754876pgc.133.2018.01.16.17.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 17:22:48 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
References: <20180116213008.GC8801@redhat.com>
From: "Liubo(OS Lab)" <liubo95@huawei.com>
Message-ID: <97e9fc59-0fc9-2c53-2713-6195f0375afe@huawei.com>
Date: Wed, 17 Jan 2018 09:19:56 +0800
MIME-Version: 1.0
In-Reply-To: <20180116213008.GC8801@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

On 2018/1/17 5:30, Jerome Glisse wrote:
> I want to talk about status of HMM and respective upstream user for
> it and also talk about what's next in term of features/improvement
> plan (generic page write protection, mmu_notifier, ...). Most likely

I don't think we should consider to push more code to upstream for a nobody-use feature.

AFAIR, Michal also mentioned that HMM need a real user/driver before upstream.
But I haven't seen a workable user/driver version.

Looks like HMM is a custom framework for Nvidia, and Nvidia would not like to open source its driver.
Even if nvidia really use HMM and open sourced its driver, it's probably the only user.
But the HMM framework touched too much core mm code.

Cheers,
Liubo

> short 15-30minutes if mmu_notifier is split into its own topic.
> 
> I want to talk about mmu_notifier, specificaly adding more context
> information to mmu_notifier callback (why a notification is happening
> reclaim, munmap, migrate, ...). Maybe we can grow this into its own
> topic and talk about mmu_notifier and issue with it like OOM or being
> able to sleep/take lock ... and improving mitigation.
> 
> People (mmu_notifier probably interest a larger set):
>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>     "Balbir Singh" <bsingharora@gmail.com>
>     "David Rientjes" <rientjes@google.com>
>     "John Hubbard" <jhubbard@nvidia.com>
>     "Michal Hocko" <mhocko@suse.com>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
