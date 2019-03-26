Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93ACBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B481205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B481205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEAA76B0003; Tue, 26 Mar 2019 12:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9A6C6B0006; Tue, 26 Mar 2019 12:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C89086B000D; Tue, 26 Mar 2019 12:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FBC66B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:03 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id i3so14110782qtc.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=LiR7M+gjL1jwp4S7wm8Je1S/i9RmM3FIjpOd06XnOUo=;
        b=D9c42xKX+QVduWtsHbv3CluKvYkpqt2VZUubTuQeelF6Kqr2gsOSMFTPpEya6eMpxu
         ca11VakishxDxbnDVqY404qqLt/bhDez6grLaVjPbsaTvW6i2b2ZEgNLtofvtaMHvICI
         wRQx/oNnMkGSwUdFY1k9CGttwHUNIePUd2YKPcKMVuPEKBGQF58LXksR7iF/VyPl0BHv
         blPnF8l11RRLCd7sn1ZlVFFnkPKIubqm8WaPrqPXzo74nasRRyUIMAeR5YxaAqHIEzMr
         MJbaZQNvAKraBw0s2ABjHHy0P5+z8KdAx0Aa93vbm6oCbX5+cTleISE0sE4Y8bgHvMfY
         sqhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXtgmx3p6Wrdi+lEsZb1Xymiz1tiEQKH8YL/L8IytC7jzSFP0ym
	U8oTK6WtWBT6yyxpKOMbUETlmmvbPZS9NeITLwa5EQc/gYtV+/EgzCppkl8z8lOakU6OeNJRoWT
	r0DlqGwly5oP2tTOjVyC1DUv/zqIJOSncVXCNGfzIaZpRabDmWajFQd+R5QbOsusPZQ==
X-Received: by 2002:a37:b345:: with SMTP id c66mr5615907qkf.219.1553618883368;
        Tue, 26 Mar 2019 09:48:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykre79woPyY7eEzWzZxpczlWE+BRIWuMeentNQ8xED9pb9u0xM5tEu8UZV2z00ZgLQyYuB
X-Received: by 2002:a37:b345:: with SMTP id c66mr5615833qkf.219.1553618882318;
        Tue, 26 Mar 2019 09:48:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618882; cv=none;
        d=google.com; s=arc-20160816;
        b=L7xz5ikwN8GBBdVDftJ2PRMLK5Z0OjPuT2NdpsXVg2tinbwqSfdNXlr9CLM76kjEcD
         fdGGZxmf88zJU05fhuEGzE5HusfUziyB6EuIZYo2mZRr66ax9+1Yp2nYMmZ0FOsQOxup
         iwJmk8a0bjdONY23D9ZJNxxuQplQySvjM5Lnfw2dGxKrJnFuFxfE+QtmmzAi4k0jKnzG
         bZfcC2zNaU9zJvI5lhgRzxmF1of4Bvw5lctumjk3hbvY0JUp05tiDaCdpSvCxE5ARV5D
         UN+anAL0k1H/xNUVZvA6CmK3wYzL3qMkzCWgD6VEqO3Sf7dGGrdpIIJNluAh+kkPL6cA
         4tug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=LiR7M+gjL1jwp4S7wm8Je1S/i9RmM3FIjpOd06XnOUo=;
        b=b2i+AYiXCsXMQPTS746VyZHan4WqV3Bllii5s6MXx8tjx2E/j+Bc8Go2L2Sds8aEsw
         w90ueI+QGaUI0o2GNcs/XQ5nJpy68NO6JOulLK5EoZ0SsjFjFG+pzoq6O1QeqRq+tFnW
         xF+qEQzY2xkQgaaSnImFkGVeK1oZHA4cVOpMdKKW9tFbEVpvfueX53mPizThOAJPocqz
         knlf4Crk/1k3PlRnhYt2vjKRCuYDeqGBhDaaH9OLI2zDpmFrQE+9/5FWgOmKecI7FTTM
         P59iGhZgSMO7CZV1/GZeQEuT7MGVxI1He+QTR46fW/w7cL9dYZ+mHK2YTQVFqOsywcgS
         dN4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p186si3793041qkd.108.2019.03.26.09.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 47087461D1;
	Tue, 26 Mar 2019 16:48:01 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6C2B88429D;
	Tue, 26 Mar 2019 16:47:55 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
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
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v6 0/8] mmu notifier provide context informations
Date: Tue, 26 Mar 2019 12:47:39 -0400
Message-Id: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 26 Mar 2019 16:48:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

(Andrew this apply on top of my HMM patchset as otherwise you will have
 conflict with changes to mm/hmm.c)

Changes since v5:
    - drop KVM bits waiting for KVM people to express interest if they
      do not then i will post patchset to remove change_pte_notify as
      without the changes in v5 change_pte_notify is just useless (it
      it is useless today upstream it is just wasting cpu cycles)
    - rebase on top of lastest Linus tree

Previous cover letter with minor update:


Here i am not posting users of this, they already have been posted to
appropriate mailing list [6] and will be merge through the appropriate
tree once this patchset is upstream.

Note that this serie does not change any behavior for any existing
code. It just pass down more information to mmu notifier listener.

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
page table update [6].

More over this can also be use to optimize out some page table updates
like for KVM where we can update the secondary MMU directly from the
callback instead of clearing it.

ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
ACKS RDMA https://lkml.org/lkml/2018/12/6/1473

Cheers,
Jérôme

[1] v1 https://lkml.org/lkml/2018/3/23/1049
[2] v2 https://lkml.org/lkml/2018/12/5/10
[3] v3 https://lkml.org/lkml/2018/12/13/620
[4] v4 https://lkml.org/lkml/2019/1/23/838
[5] v5 https://lkml.org/lkml/2019/2/19/752
[6] patches to use this:
    https://lkml.org/lkml/2019/1/23/833
    https://lkml.org/lkml/2019/1/23/834
    https://lkml.org/lkml/2019/1/23/832
    https://lkml.org/lkml/2019/1/23/831

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>

Jérôme Glisse (8):
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

 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  8 ++--
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/gpu/drm/radeon/radeon_mn.c      |  4 +-
 drivers/infiniband/core/umem_odp.c      |  5 +-
 drivers/xen/gntdev.c                    |  6 +--
 fs/proc/task_mmu.c                      |  3 +-
 include/linux/mmu_notifier.h            | 63 +++++++++++++++++++++++--
 kernel/events/uprobes.c                 |  3 +-
 mm/hmm.c                                |  6 +--
 mm/huge_memory.c                        | 14 +++---
 mm/hugetlb.c                            | 12 +++--
 mm/khugepaged.c                         |  3 +-
 mm/ksm.c                                |  6 ++-
 mm/madvise.c                            |  3 +-
 mm/memory.c                             | 25 ++++++----
 mm/migrate.c                            |  5 +-
 mm/mmu_notifier.c                       | 12 ++++-
 mm/mprotect.c                           |  4 +-
 mm/mremap.c                             |  3 +-
 mm/oom_kill.c                           |  3 +-
 mm/rmap.c                               |  6 ++-
 virt/kvm/kvm_main.c                     |  3 +-
 22 files changed, 147 insertions(+), 52 deletions(-)

-- 
2.20.1

