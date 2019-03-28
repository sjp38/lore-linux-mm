Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2637DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D683620645
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D683620645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 718CC6B0003; Thu, 28 Mar 2019 09:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C8B66B0006; Thu, 28 Mar 2019 09:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58F466B0007; Thu, 28 Mar 2019 09:44:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5406B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:44:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so8089774edd.21
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=NrH6xh1MbhRwtxPZnwY9wBd33az+JyvhHQ4ruL7W1iw=;
        b=phH2/URWuJlXVxny11VOZqMOd+a0IDLkXl4I40+SrZF2tmrUZWyJ3qChHKxc74OqYW
         VddHE2Piltzt1k7m3JEn3GSn9mPGgWmWcKlvpp3NPxii7uQdvz+tdpFAz1NOR4eEnp3U
         w6Wnx4RGObMR4iTNfUB9KZPqgg+e+UmTXeERQX1L1k67jMZwUVLzTLPBs/p/ISZfaWHE
         46+7TM1KHmbWG2nbkjgq6USCx5GV/s1F/O9yRD5mPtZhH7JNgny9ol2q5ebKLuTO641i
         SbDSczlsWyt61u3tPjRHo6+7wjSpfjc/rwwyFFn3GtRcx283kxWo4AJWbBslTWdMLJ/s
         AUBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVu50CYawU/kZlKPBaxo8bDaDsCJmeeCySOPHDV7ZxwkaE2Asr7
	sGuPPF0VVgaQezd9zdist47bzkNBQEUIfGhCRfio63uCzE1ehXGIvpDSly4aqu5ZmqVrGbQVzEh
	u6Tjg6Vdqt1pWdnfXkpxTMOnpFJZtcG37vMxICsSdC1QIRqRpJbZsuKhPhubiUCW+rw==
X-Received: by 2002:aa7:c6cf:: with SMTP id b15mr28056667eds.46.1553780642521;
        Thu, 28 Mar 2019 06:44:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZzgXTQtq14R2nytzPJHvq79yVo8UFWBIABm3n9Ps1Lu47Bv+PG6etMOz7RULn2GaTPohA
X-Received: by 2002:aa7:c6cf:: with SMTP id b15mr28056600eds.46.1553780641385;
        Thu, 28 Mar 2019 06:44:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780641; cv=none;
        d=google.com; s=arc-20160816;
        b=iTbJQVchVWYLZO8bNdK/S4oYmX80TnaKfiVtEGYPym9XlFCwFPK/clxHl3WWrEkT5m
         0R1KP5iNwaww+zUIHNfZFHQ9jsHhM8DmgWqrQN1uHidcRWPlsElRjvKCamcx2t5R6dOp
         GKbjdZQ9xvmrQSJkA82ir8HGbVzlxMF0Yl6K4b3AvvBe0xW8SD88vlH8l0Rj/wKtjcAe
         ZULasOAFiKaji3p0QgD9vFF88/Xo6d2WVrfxlhlUx6lHSrpFbZ5r5M0KbU7HojNyavnG
         JW6uBqlLFcjhoIy/ll+7nrOH5Wv4Tx6uJ4u2mqUhnYCCbcyQhmwlnzHSa+idRkq17Af+
         ioOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=NrH6xh1MbhRwtxPZnwY9wBd33az+JyvhHQ4ruL7W1iw=;
        b=Y+1cLNkF8YSIhC2AMOGGhItgAsNw+DRUx4Cf8m5Ge9L/taFgfN0rS6VeaF0Zv5Pk5+
         nmnoJvD8Rw6xuVUkIWHrDl9+MO3nlZCnoADyW+XdsQepjcRYMH9BPetPvzUDgRnE933B
         bY/481xH+gNJfPHkIQN+T5/haB8twg2c4q5CWQU9N4kYfp2eLPjcD9CvBQuqfw5oN8p1
         Ni8nEvVQLDNIC3+mp0Ri5TXJgqeoJTtDHum6WFMPCECkQm+jSHJLDY8azZmhAfAk6+ay
         5TzGUXbwY3HPlG1H7Gba39cIMdUIaAE3Z/9NzvloSfYXeJc45K8OcQMInGVPQKSrj4h+
         PuIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id t25si2040556ejr.164.2019.03.28.06.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:44:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 28 Mar 2019 14:44:00 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 28 Mar 2019 13:43:30 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded memory
Date: Thu, 28 Mar 2019 14:43:16 +0100
Message-Id: <20190328134320.13232-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

since last two RFCs were almost unnoticed (thanks David for the feedback),
I decided to re-work some parts to make it more simple and give it a more
testing, and drop the RFC, to see if it gets more attention.
I also added David's feedback, so now all users of add_memory/__add_memory/
add_memory_resource can specify whether they want to use this feature or not.
I also fixed some compilation issues when CONFIG_SPARSEMEM_VMEMMAP is not set.

[Testing]

Testing has been carried out on the following platforms:

 - x86_64 (small and big memblocks)
 - powerpc
 - arm64 (Huawei's fellows)

I plan to test it on Xen and Hyper-V, but for now those two will not be
using this feature, and neither DAX/pmem.

Of course, if this does not find any strong objection, my next step is to
work on enabling this on Xen/Hyper-V.

[Coverletter]

This is another step to make the memory hotplug more usable. The primary
goal of this patchset is to reduce memory overhead of the hot added
memory (at least for SPARSE_VMEMMAP memory model). The current way we use
to populate memmap (struct page array) has two main drawbacks:

a) it consumes an additional memory until the hotadded memory itself is
   onlined and
b) memmap might end up on a different numa node which is especially true
   for movable_node configuration.

a) is problem especially for memory hotplug based memory "ballooning"
   solutions when the delay between physical memory hotplug and the
   onlining can lead to OOM and that led to introduction of hacks like auto
   onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
   policy for the newly added memory")).

b) can have performance drawbacks.

I have also seen hot-add operations failing on archs because they
were running out of order-x pages.
E.g On powerpc, in certain configurations, we use order-8 pages,
and given 64KB base pagesize, that is 16MB.
If we run out of those, we just fail the operation and we cannot add
more memory.
We could fallback to base pages as x86_64 does, but we can do better.

One way to mitigate all these issues is to simply allocate memmap array
(which is the largest memory footprint of the physical memory hotplug)
from the hotadded memory itself. VMEMMAP memory model allows us to map
any pfn range so the memory doesn't need to be online to be usable
for the array. See patch 3 for more details. In short I am reusing an
existing vmem_altmap which wants to achieve the same thing for nvdim
device memory.

There is also one potential drawback, though. If somebody uses memory
hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
for them obviously because each memory block will contain reserved
area. Large x86 machines will use 2G memblocks so at least one 1G page
will be available but this is still not 2G...

If that is a problem, we can always configure a fallback strategy to
use the current scheme.

Since this only works when CONFIG_VMEMMAP_ENABLED is set,
we do check for it before setting the flag that allows use
to use the feature, no matter if the user wanted it.

[Overall design]:

Let us say we hot-add 2GB of memory on a x86_64 (memblock size = 128M).
That is:

 - 16 sections
 - 524288 pages
 - 8192 vmemmap pages (out of those 524288. We spend 512 pages for each section)

 The range of pages is: 0xffffea0004000000 - 0xffffea0006000000
 The vmemmap range is:  0xffffea0004000000 - 0xffffea0004080000

 0xffffea0004000000 is the head vmemmap page (first page), while all the others
 are "tails".

 We keep the following information in it:

 - Head page:
   - head->_refcount: number of sections
   - head->private :  number of vmemmap pages
 - Tail page:
   - tail->freelist : pointer to the head

This is done because it eases the work in cases where we have to compute the
number of vmemmap pages to know how much do we have to skip etc, and to keep
the right accounting to present_pages.

When we want to hot-remove the range, we need to be careful because the first
pages of that range, are used for the memmap maping, so if we remove those
first, we would blow up while accessing the others later on.
For that reason we keep the number of sections in head->_refcount, to know how
much do we have to defer the free up.

Since in a hot-remove operation, sections are being removed sequentially, the
approach taken here is that every time we hit free_section_memmap(), we decrease
the refcount of the head.
When it reaches 0, we know that we hit the last section, so we call
vmemmap_free() for the whole memory-range in backwards, so we make sure that
the pages used for the mapping will be latest to be freed up.

Vmemmap pages are charged to spanned/present_paged, but not to manages_pages.

Michal Hocko (3):
  mm, memory_hotplug: cleanup memory offline path
  mm, memory_hotplug: provide a more generic restrictions for memory
    hotplug
  mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap

Oscar Salvador (1):
  mm, memory_hotplug: allocate memmap from the added memory range for
    sparse-vmemmap

 arch/arm64/mm/mmu.c                             |  10 +-
 arch/ia64/mm/init.c                             |   5 +-
 arch/powerpc/mm/init_64.c                       |   7 +
 arch/powerpc/mm/mem.c                           |   6 +-
 arch/powerpc/platforms/powernv/memtrace.c       |   2 +-
 arch/powerpc/platforms/pseries/hotplug-memory.c |   2 +-
 arch/s390/mm/init.c                             |  12 +-
 arch/sh/mm/init.c                               |   6 +-
 arch/x86/mm/init_32.c                           |   6 +-
 arch/x86/mm/init_64.c                           |  20 ++-
 drivers/acpi/acpi_memhotplug.c                  |   2 +-
 drivers/base/memory.c                           |   2 +-
 drivers/dax/kmem.c                              |   2 +-
 drivers/hv/hv_balloon.c                         |   2 +-
 drivers/s390/char/sclp_cmd.c                    |   2 +-
 drivers/xen/balloon.c                           |   2 +-
 include/linux/memory_hotplug.h                  |  53 ++++++--
 include/linux/memremap.h                        |   2 +-
 include/linux/page-flags.h                      |  34 +++++
 kernel/memremap.c                               |   9 +-
 mm/compaction.c                                 |   6 +
 mm/memory_hotplug.c                             | 168 ++++++++++++++++--------
 mm/page_alloc.c                                 |  30 ++++-
 mm/page_isolation.c                             |  11 ++
 mm/sparse.c                                     | 104 +++++++++++++--
 mm/util.c                                       |   2 +
 26 files changed, 393 insertions(+), 114 deletions(-)

-- 
2.13.7

