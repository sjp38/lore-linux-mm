Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDDE6B025F
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:24:06 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id e198so353612oig.23
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 21:24:06 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id s130si3404255ois.263.2018.01.18.21.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 21:24:05 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] HMM status upstream user what's next, mmu_notifier
References: <20180116213008.GC8801@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e26eb2f7-588c-0b6b-2326-f13b8e566da8@nvidia.com>
Date: Thu, 18 Jan 2018 21:24:03 -0800
MIME-Version: 1.0
In-Reply-To: <20180116213008.GC8801@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On 01/16/2018 01:30 PM, Jerome Glisse wrote:
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
> 

Hi Jerome,

Thanks again for including me here. I am very interesting in discussing this,
seeing as how we're busy adding HMM support to our driver(s).

The teardown cases still concern us, as you know (today's HMM lacks
a callback for when the struct mm disappears, for example), but that's really
just a subset of the mmu_notifier discussion that you list above.

Hope to see you there.

thanks,
-- 
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
