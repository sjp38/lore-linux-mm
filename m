Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41FA06B0006
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 10:37:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id n13so4780478wra.13
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 07:37:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si3942076wrc.349.2018.01.25.07.37.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 07:37:56 -0800 (PST)
Date: Thu, 25 Jan 2018 16:37:55 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Message-ID: <20180125153755.GU28465@dhcp22.suse.cz>
References: <20180116213008.GC8801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116213008.GC8801@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>

On Tue 16-01-18 16:30:08, Jerome Glisse wrote:
> I want to talk about status of HMM and respective upstream user for
> it and also talk about what's next in term of features/improvement
> plan (generic page write protection, mmu_notifier, ...). Most likely
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

I am definitely interested.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
