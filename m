Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A76D6C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50E0A21872
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:24:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M4RnDbpk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50E0A21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44E68E0002; Fri,  1 Feb 2019 07:24:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E01268E0001; Fri,  1 Feb 2019 07:24:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBBCD8E0002; Fri,  1 Feb 2019 07:24:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECD08E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 07:24:57 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y7so2152796wrr.12
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 04:24:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:reply-to:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=WXxNonisvEEGsJcrJ12yHRZbUb6lt7CD6ZwqgsaLB7g=;
        b=CCXnsOvRBTycATxNxFVnMO3d6Nr7Rsc8kkn8lUGKpVAMsRGDpUkKUW894vJ/TyyY2K
         UtHj82V4ZNXjRuHdaXSxEVuEJZvETIQs8G6lUafIQFe3wwQH6HRafa1gpbXbZWYgY3Tb
         /DkZafVESmMsGAtTE0RYlO0JY2a9S+b3uNK+cGNTRa+DG5ZyBZ6FOpQKXbjS20OUmOmt
         5JLh/KFsIwxuW270FKRkt0E7EPqpxCzVYgKhpPT/3tOu5X945NelwG8pPQ0p0KULhfcC
         iYO3+iUkTzUnsKAx85uDwV55BpZ7fzJxCIhsWfjoYX4yQoEnhTcJ7M9d7zSmYUUXU9M8
         0oow==
X-Gm-Message-State: AJcUukeJxi0kPsWsZ9XhP+wpAIViAP0m6UO/KEwUI4XU4Cv75YG7b8d3
	z5WXih2Rx9QGGq9eXo7lItxS97r9f/E/m0VNhqc+4VwTSEfDjOR5k5KhozHNC/SkqapyOmTqJOF
	laYQS74nuLH8gz9IF1FBLLHpmKURkP8lFfEn8IyucZL+TX4LInNjKGC3cIcn15h7oACxuC6/5YT
	Sm1/hlZdNLhLUYWsN+ZIi7UVfzxp3TlDhsGSOAQoEsNey1CEUfSPK8XNA5j7n8JLkq9H8lkXNln
	9XWyd+PnJJfYASf07SRX6igs3TGVUvJy0aQpLYFhQU/rl2JgntTrtp6q5RY6vnNrkD0zzh/TaRd
	9L++GUGkqDbnfP0UgEJgL90Lq5q2PtKwNFSeU/TgZSEjEQFEEV65IongguXDNCRqrcSJHdS0mdH
	f
X-Received: by 2002:adf:9422:: with SMTP id 31mr40642510wrq.106.1549023896864;
        Fri, 01 Feb 2019 04:24:56 -0800 (PST)
X-Received: by 2002:adf:9422:: with SMTP id 31mr40642457wrq.106.1549023895855;
        Fri, 01 Feb 2019 04:24:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549023895; cv=none;
        d=google.com; s=arc-20160816;
        b=B5sGVHa8EJROZ+IEhjiSKEM52wuXQYORPmSjLjlL7htgaL7+hR6qpg/EK4UAewP/gu
         wr/ewdYHxnG4prRHWg0b0a3yjff9CEnFWrrPhgyQa767Rk5aHm9T/pltiIw8gW/9lXNY
         hHiHlXNY8Z1U+YfhNxCoVgeTxB9W9V2+Gas+ZUPEDZ+//P7EM/LuNKbyL83wWjfzP0zK
         bds5/u2yA7HKrDYEtu1ch/DOvBraMee5R90iFhzcQ5hKdwIlKJG6ssMVLleiyX75wyRz
         1LewXeb5hGRbnCcfSUIkDTA37ToFDm61ZFofaK42H3mvlrxGLqe3Q6vTJsx4AR/joP7V
         doCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:reply-to
         :dkim-signature;
        bh=WXxNonisvEEGsJcrJ12yHRZbUb6lt7CD6ZwqgsaLB7g=;
        b=ViXWcntZcABdec6i2VSwdSmW32KyotMPTaQkOuMwI2PRfGhKHnv7NX7d5oO+58JFZ3
         MY8saxck5z2CslMJJgGWwGQbg+Z+eFUAdzHZcFzrrxnl+0abTHTkf0USqYOsqjrXtqbM
         YeuKLnIKtVPoigvspP+vVcOAydg4GpiatbCL6HhJThgo4n8NWwEZ3zXL0mxdJWEoyrYS
         DxKw4A6qd66v64tdWSIjcJOO+6n8IQGFK8FmquIb9nJ1N4JdCJB1oB8vZdpldtEl61b2
         Dz3BPXvCqrxEbMAxnnfB11uVcs1ZhWfy1J++E4946SltPn4k/TibyPp9EblAkEhGc1cX
         V4cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M4RnDbpk;
       spf=pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ckoenig.leichtzumerken@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q186sor1601717wme.15.2019.02.01.04.24.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 04:24:55 -0800 (PST)
Received-SPF: pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M4RnDbpk;
       spf=pass (google.com: domain of ckoenig.leichtzumerken@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ckoenig.leichtzumerken@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=reply-to:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=WXxNonisvEEGsJcrJ12yHRZbUb6lt7CD6ZwqgsaLB7g=;
        b=M4RnDbpkBe7khiuH/YflEZDCjdNGpPFKhoTM/Sj20K1EuyuNHLNl1iLtvRygCtjGIn
         QVoQuiSoSa7VqghdJtmY829X1iWfnGuJPx3goPFXXs3N0EOiAEqiodDwYN1LG97YmFsN
         FQw8XB2Zcs9tFXKGUGOpHG28fyM7r21ooHNcMzE13000y1Bv//O1/balf5DgflWPPVft
         pUKjo1FQAGRl10krk1LZ5gALq2ISgEkBp+19gQvt1FCmhtOrB53fS0/P7q9P7w9LcPJd
         JKa1144z6CWbMhf56ra6u8bH2kULV0CPC7ZycnHfNcrdR9Iyt0xGPJURHx/YJRZrK8XO
         wLDQ==
X-Google-Smtp-Source: AHgI3IbtRx7AmXK/MW+l9XaAIVVyP8FdWntSLEqI6CG6u1uNd47WlHhcIhsK8Jx/7XQy+203eEWIDg==
X-Received: by 2002:a1c:a755:: with SMTP id q82mr2322317wme.6.1549023895272;
        Fri, 01 Feb 2019 04:24:55 -0800 (PST)
Received: from ?IPv6:2a02:908:1252:fb60:be8a:bd56:1f94:86e7? ([2a02:908:1252:fb60:be8a:bd56:1f94:86e7])
        by smtp.gmail.com with ESMTPSA id h13sm10030054wrp.61.2019.02.01.04.24.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 04:24:54 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
To: Jerome Glisse <jglisse@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Ralph Campbell <rcampbell@nvidia.com>, Jan Kara <jack@suse.cz>,
 Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
 Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org,
 John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@mellanox.com>,
 Ross Zwisler <zwisler@kernel.org>, linux-fsdevel@vger.kernel.org,
 Paolo Bonzini <pbonzini@redhat.com>, Dan Williams
 <dan.j.williams@intel.com>, =?UTF-8?Q?Christian_K=c3=b6nig?=
 <christian.koenig@amd.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190131161006.GA16593@redhat.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <d8c0fd08-c1d9-6035-e5b6-6691874cec07@gmail.com>
Date: Fri, 1 Feb 2019 13:24:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131161006.GA16593@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 31.01.19 um 17:10 schrieb Jerome Glisse:
> Andrew what is your plan for this ? I had a discussion with Peter Xu
> and Andrea about change_pte() and kvm. Today the change_pte() kvm
> optimization is effectively disabled because of invalidate_range
> calls. With a minimal couple lines patch on top of this patchset
> we can bring back the kvm change_pte optimization and we can also
> optimize some other cases like for instance when write protecting
> after fork (but i am not sure this is something qemu does often so
> it might not help for real kvm workload).
>
> I will be posting a the extra patch as an RFC, but in the meantime
> i wanted to know what was the status for this.
>
>
> Jan, Christian does your previous ACK still holds for this ?

At least the general approach still sounds perfectly sane to me.

Regarding how to merge these patches I think we should just get the 
general infrastructure into Linus tree and when can then merge the DRM 
patches one release later when we are sure that it doesn't break anything.

Christian.

>
>
> On Wed, Jan 23, 2019 at 05:23:06PM -0500, jglisse@redhat.com wrote:
>> From: Jérôme Glisse <jglisse@redhat.com>
>>
>> Hi Andrew, i see that you still have my event patch in you queue [1].
>> This patchset replace that single patch and is broken down in further
>> step so that it is easier to review and ascertain that no mistake were
>> made during mechanical changes. Here are the step:
>>
>>      Patch 1 - add the enum values
>>      Patch 2 - coccinelle semantic patch to convert all call site of
>>                mmu_notifier_range_init to default enum value and also
>>                to passing down the vma when it is available
>>      Patch 3 - update many call site to more accurate enum values
>>      Patch 4 - add the information to the mmu_notifier_range struct
>>      Patch 5 - helper to test if a range is updated to read only
>>
>> All the remaining patches are update to various driver to demonstrate
>> how this new information get use by device driver. I build tested
>> with make all and make all minus everything that enable mmu notifier
>> ie building with MMU_NOTIFIER=no. Also tested with some radeon,amd
>> gpu and intel gpu.
>>
>> If they are no objections i believe best plan would be to merge the
>> the first 5 patches (all mm changes) through your queue for 5.1 and
>> then to delay driver update to each individual driver tree for 5.2.
>> This will allow each individual device driver maintainer time to more
>> thouroughly test this more then my own testing.
>>
>> Note that i also intend to use this feature further in nouveau and
>> HMM down the road. I also expect that other user like KVM might be
>> interested into leveraging this new information to optimize some of
>> there secondary page table invalidation.
>>
>> Here is an explaination on the rational for this patchset:
>>
>>
>> CPU page table update can happens for many reasons, not only as a result
>> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
>> as a result of kernel activities (memory compression, reclaim, migration,
>> ...).
>>
>> This patch introduce a set of enums that can be associated with each of
>> the events triggering a mmu notifier. Latter patches take advantages of
>> those enum values.
>>
>> - UNMAP: munmap() or mremap()
>> - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>> - PROTECTION_VMA: change in access protections for the range
>> - PROTECTION_PAGE: change in access protections for page in the range
>> - SOFT_DIRTY: soft dirtyness tracking
>>
>> Being able to identify munmap() and mremap() from other reasons why the
>> page table is cleared is important to allow user of mmu notifier to
>> update their own internal tracking structure accordingly (on munmap or
>> mremap it is not longer needed to track range of virtual address as it
>> becomes invalid).
>>
>> [1] https://www.ozlabs.org/~akpm/mmotm/broken-out/mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
>>
>> Cc: Christian König <christian.koenig@amd.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Ross Zwisler <zwisler@kernel.org>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Paolo Bonzini <pbonzini@redhat.com>
>> Cc: Radim Krčmář <rkrcmar@redhat.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: John Hubbard <jhubbard@nvidia.com>
>> Cc: kvm@vger.kernel.org
>> Cc: dri-devel@lists.freedesktop.org
>> Cc: linux-rdma@vger.kernel.org
>> Cc: linux-fsdevel@vger.kernel.org
>> Cc: Arnd Bergmann <arnd@arndb.de>
>>
>> Jérôme Glisse (9):
>>    mm/mmu_notifier: contextual information for event enums
>>    mm/mmu_notifier: contextual information for event triggering
>>      invalidation
>>    mm/mmu_notifier: use correct mmu_notifier events for each invalidation
>>    mm/mmu_notifier: pass down vma and reasons why mmu notifier is
>>      happening
>>    mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
>>    gpu/drm/radeon: optimize out the case when a range is updated to read
>>      only
>>    gpu/drm/amdgpu: optimize out the case when a range is updated to read
>>      only
>>    gpu/drm/i915: optimize out the case when a range is updated to read
>>      only
>>    RDMA/umem_odp: optimize out the case when a range is updated to read
>>      only
>>
>>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 13 ++++++++
>>   drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++
>>   drivers/gpu/drm/radeon/radeon_mn.c      | 13 ++++++++
>>   drivers/infiniband/core/umem_odp.c      | 22 +++++++++++--
>>   fs/proc/task_mmu.c                      |  3 +-
>>   include/linux/mmu_notifier.h            | 42 ++++++++++++++++++++++++-
>>   include/rdma/ib_umem_odp.h              |  1 +
>>   kernel/events/uprobes.c                 |  3 +-
>>   mm/huge_memory.c                        | 14 +++++----
>>   mm/hugetlb.c                            | 11 ++++---
>>   mm/khugepaged.c                         |  3 +-
>>   mm/ksm.c                                |  6 ++--
>>   mm/madvise.c                            |  3 +-
>>   mm/memory.c                             | 25 +++++++++------
>>   mm/migrate.c                            |  5 ++-
>>   mm/mmu_notifier.c                       | 10 ++++++
>>   mm/mprotect.c                           |  4 ++-
>>   mm/mremap.c                             |  3 +-
>>   mm/oom_kill.c                           |  3 +-
>>   mm/rmap.c                               |  6 ++--
>>   20 files changed, 171 insertions(+), 35 deletions(-)
>>
>> -- 
>> 2.17.2
>>
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

