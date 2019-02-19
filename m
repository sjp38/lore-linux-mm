Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3891DC10F02
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2B502183E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2B502183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B7808E0003; Tue, 19 Feb 2019 15:04:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667268E0002; Tue, 19 Feb 2019 15:04:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57C348E0003; Tue, 19 Feb 2019 15:04:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE308E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:04:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f70so594988qke.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:04:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=pSOGhJmzvuAOiiAWJFwnrOQy7lzxVmkuYa1YKkFVB5Q=;
        b=pA5w4SJTh3AwE/dY3u0eJmlIlpy6EGgNxxSQIQSVIJAJJMueCUMehgRj9b555Imvco
         +Lm+UwhMzfWiQRAA6NyKe4iHuHXAnhkicbnjDklPdqsprB3TQLKDIUHXzb1rNDFJnmCr
         WAm23b+oamYTy0x2wDVpLP13T6zZMQBxvoyHseNVlEA65UszoH3a1Zp4db4mi4NFBwUF
         WlRZSG5MgOnKOblei0B/mJb9RfS9f+6K9pBnTXkUmru8UEuBACMDSjznFUg5/bGk7xwp
         26JnQmM6MNHJdhoWHIfAZRs10MbMiRIzD4zQ3PaH/iHZohsECQlsLfbRtcfKAVa4Lz3+
         t8HQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZaBs7o20dmxa0Rz+8wLHXLnS4+yiLM2UsOE2057BvAFhc5S+Jm
	WrQ/SvVWJ6xbZEA6XnNR1ePcqw35gw5JfwGgx7youXrutW1ZMdw6pjdNeM9f6GbkFCGSSjpeB/u
	wn0/b4fBEE2Ww1+XbTWhEdJVelPWwHpV18RCU38M/2WLPdlTNx/0pht3gQKKaD4szqg==
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr24242584qte.109.1550606691890;
        Tue, 19 Feb 2019 12:04:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYk6nGMoS6VQvX2r7wb0FKob1xaY+Gz5f5n1k7Hyk52npCjM7/dpDRYbvS2EMuqHBXyhT5q
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr24242209qte.109.1550606686423;
        Tue, 19 Feb 2019 12:04:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606686; cv=none;
        d=google.com; s=arc-20160816;
        b=FOt9i1PrRy92X5kD64o6m9jUNt1+ELau/xDh2dkA729iH/PV576wX8RXTR4NGT0zFI
         ddOeOk9J40NSvnLXLUW3XhMFGNb4emDMQFy4JDTasLVfkZVxWvyS8v85OAXacQ4oDaqC
         VkRCiwcHEHPzVOSFx0l5fuKKk9zN1P7RDEfnlwH2TVT7ouuYu8BIpez83KjOtPBBD9CR
         gPm+OzGMzn44Z2Yxfvrq9hf9AnkkUFF8UnxtwK8DZDtEJAhItL8ac7ak2cdp/Ls+WezM
         cKtILJOvCeztuAgFNP+7BzhDSQPU5V1mkHGw+6f5DWQ9LH6gUKR4bkyYc5GFl7Yjq+k2
         cikQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=pSOGhJmzvuAOiiAWJFwnrOQy7lzxVmkuYa1YKkFVB5Q=;
        b=Sz9fHDLju93DKfGPl79zyvQswF7u/ra/5ny4SE9LAhOhpKjQFz9sR+h9V7pUsZ1+rs
         fucwo6qCntrsJshqA00AyH5XkolQt6NweM5GGJTp1uKaK7lQ5Iz3hoPHaWKnqWAUPHAN
         I9bhh8DOlv5T7XK1XtNzfoSzAcFZneZzo0HcZyeQmG+phTFv5Cdi8shQy70CSpvLOFvX
         4D9SokeV+Hh59Sp8hIMWsSF3Ve3Mg1WglL0RA5tp2unepgxLn4ElQE9RuYZmZSWAkD3W
         zkQreFHx3Q2dckToTW8TChmKm9JysTP47hXtUBy5M3eBdNjwAUWK+aesMwY3YzS4644N
         w4Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e8si5657887qvh.215.2019.02.19.12.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:04:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 372A081DE0;
	Tue, 19 Feb 2019 20:04:45 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BA38B6013C;
	Tue, 19 Feb 2019 20:04:39 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v5 0/9] mmu notifier provide context informations
Date: Tue, 19 Feb 2019 15:04:21 -0500
Message-Id: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 19 Feb 2019 20:04:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Since last version [4] i added the extra bits needed for the change_pte
optimization (which is a KSM thing). Here i am not posting users of
this, they will be posted to the appropriate sub-systems (KVM, GPU,
RDMA, ...) once this serie get upstream. If you want to look at users
of this see [5] [6]. If this gets in 5.1 then i will be submitting
those users for 5.2 (including KVM if KVM folks feel comfortable with
it).

Note that this serie does not change any behavior for any existing
code. It just pass down more informations to mmu notifier listener.

The rational for this patchset:


CPU page table update can happens for many reasons, not only as a
result of a syscall (munmap(), mprotect(), mremap(), madvise(), ...)
but also as a result of kernel activities (memory compression, reclaim,
migration, ...).

This patch introduce a set of enums that can be associated with each
of the events triggering a mmu notifier:

    - UNMAP: munmap() or mremap()
    - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
    - PROTECTION_VMA: change in access protections for the range
    - PROTECTION_PAGE: change in access protections for page in the range
    - SOFT_DIRTY: soft dirtyness tracking

Being able to identify munmap() and mremap() from other reasons why the
page table is cleared is important to allow user of mmu notifier to
update their own internal tracking structure accordingly (on munmap or
mremap it is not longer needed to track range of virtual address as it
becomes invalid). Without this serie, driver are force to assume that
every notification is an munmap which triggers useless trashing within
drivers that associate structure with range of virtual address. Each
driver is force to free up its tracking structure and then restore it
on next device page fault. With this serie we can also optimize device
page table update [5].

More over this can also be use to optimize out some page table updates
like for KVM where we can update the secondary MMU directly from the
callback instead of clearing it.

Patches to leverage this serie will be posted separately to each sub-
system.

Cheers,
Jérôme

[1] v1 https://lkml.org/lkml/2018/3/23/1049
[2] v2 https://lkml.org/lkml/2018/12/5/10
[3] v3 https://lkml.org/lkml/2018/12/13/620
[4] v4 https://lkml.org/lkml/2019/1/23/838
[5] patches to use this:
    https://lkml.org/lkml/2019/1/23/833
    https://lkml.org/lkml/2019/1/23/834
    https://lkml.org/lkml/2019/1/23/832
    https://lkml.org/lkml/2019/1/23/831
[6] KVM restore change pte optimization
    https://patchwork.kernel.org/cover/10791179/

Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>

Jérôme Glisse (9):
  mm/mmu_notifier: helper to test if a range invalidation is blockable
  mm/mmu_notifier: convert user range->blockable to helper function
  mm/mmu_notifier: convert mmu_notifier_range->blockable to a flags
  mm/mmu_notifier: contextual information for event enums
  mm/mmu_notifier: contextual information for event triggering
    invalidation v2
  mm/mmu_notifier: use correct mmu_notifier events for each invalidation
  mm/mmu_notifier: pass down vma and reasons why mmu notifier is
    happening v2
  mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
  mm/mmu_notifier: set MMU_NOTIFIER_USE_CHANGE_PTE flag where
    appropriate v2

 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  8 +--
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/gpu/drm/radeon/radeon_mn.c      |  4 +-
 drivers/infiniband/core/umem_odp.c      |  5 +-
 drivers/xen/gntdev.c                    |  6 +-
 fs/proc/task_mmu.c                      |  3 +-
 include/linux/mmu_notifier.h            | 93 +++++++++++++++++++++++--
 kernel/events/uprobes.c                 |  3 +-
 mm/hmm.c                                |  6 +-
 mm/huge_memory.c                        | 14 ++--
 mm/hugetlb.c                            | 12 ++--
 mm/khugepaged.c                         |  3 +-
 mm/ksm.c                                |  9 ++-
 mm/madvise.c                            |  3 +-
 mm/memory.c                             | 26 ++++---
 mm/migrate.c                            |  5 +-
 mm/mmu_notifier.c                       | 12 +++-
 mm/mprotect.c                           |  4 +-
 mm/mremap.c                             |  3 +-
 mm/oom_kill.c                           |  3 +-
 mm/rmap.c                               |  6 +-
 virt/kvm/kvm_main.c                     |  3 +-
 22 files changed, 180 insertions(+), 53 deletions(-)

-- 
2.17.2

