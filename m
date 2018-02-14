Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 192F46B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:15:35 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id n186so12983428vkc.3
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 01:15:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x2sor1535342vka.13.2018.02.14.01.15.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 01:15:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180125153755.GU28465@dhcp22.suse.cz>
References: <20180116213008.GC8801@redhat.com> <20180125153755.GU28465@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 14 Feb 2018 20:15:32 +1100
Message-ID: <CAKTCnzkiKpdGFPXqwVutpd=JVbvf8WMNEK1LG1tjM0ftvmR+rQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Jerome Glisse <jglisse@redhat.com>, lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Jan 26, 2018 at 2:37 AM, Michal Hocko <mhocko@suse.com> wrote:
> On Tue 16-01-18 16:30:08, Jerome Glisse wrote:
>> I want to talk about status of HMM and respective upstream user for
>> it and also talk about what's next in term of features/improvement
>> plan (generic page write protection, mmu_notifier, ...). Most likely
>> short 15-30minutes if mmu_notifier is split into its own topic.
>>
>> I want to talk about mmu_notifier, specificaly adding more context
>> information to mmu_notifier callback (why a notification is happening
>> reclaim, munmap, migrate, ...). Maybe we can grow this into its own
>> topic and talk about mmu_notifier and issue with it like OOM or being
>> able to sleep/take lock ... and improving mitigation.
>>
>> People (mmu_notifier probably interest a larger set):
>>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>>     "Balbir Singh" <bsingharora@gmail.com>
>>     "David Rientjes" <rientjes@google.com>
>>     "John Hubbard" <jhubbard@nvidia.com>
>>     "Michal Hocko" <mhocko@suse.com>
>
> I am definitely interested.

me too and as I said in the previous email, we may have other examples
of coherent memory like openCAPI and lots of experience with both NUMA
and HMM/HMM-CDM. I'd like to share them and discuss the path forward

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
