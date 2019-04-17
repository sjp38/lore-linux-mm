Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB767C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:52:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 442742173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:52:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 442742173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D2816B0005; Wed, 17 Apr 2019 14:52:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 986DE6B0006; Wed, 17 Apr 2019 14:52:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8758D6B0007; Wed, 17 Apr 2019 14:52:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0666B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:52:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 33so15146633pgv.17
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:52:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=LMoYYohTDCsg4RTF0qKmHG620NIXuEopdfdugBPNwsA=;
        b=py6w41cD4q04PzUZqBivxcTsTNC1SbLPhXtBAm30annaDA6eYg+W9X+mxIUeaBd69r
         G9quCV+QqAZgCVcxXKbHBuCHYFsyUSrex/4rg+JxPyzL85Ivy/blSHEnj4ITcBnZKaJA
         Fgo8sjQ015+4D6AZYHZT4pUrSUklKyLueLRIzSsIIlaeaz0L+86/y0dGKgEYZZj6YLJ1
         O4dUGWlkrNKOVjIYZWHCgt2utJJYpeecUiNHjVSA9fZ9yL8NwOoSKcpE4e99VklrFFpq
         xzx+GAaN02SmMMgK8vbihBQMRQEiotLDwgd3cVUiGYFTFwfvY1nI+emcKcKnWU0tvtN5
         5Dlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUj8mkTxeodtb7xTX1q+Dt/e0lo+0IZTBWHRgYv9ZrflvF+ezqf
	PnQNyZA3eMdoLT+IjkiHiyL6xiz4rt+PVFgibR+0rBZUMQ0V4QRo4opB9D9Qd2/hDGqTuNqaL7g
	3iOKuAgtGXdk3SNWH7VdDbWKJFUZ0UOBVbb8hcuRQA9rvaLVQMaCIi3MBjAs4qwymqg==
X-Received: by 2002:a63:e850:: with SMTP id a16mr80583734pgk.195.1555527163531;
        Wed, 17 Apr 2019 11:52:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOGP2i6w2wgldDuDAXk7fNlZ7bZOkx7Dj4udzPZmkY2JZHEQPSg0TYNHvN+LfL0xN7VCt9
X-Received: by 2002:a63:e850:: with SMTP id a16mr80583672pgk.195.1555527162473;
        Wed, 17 Apr 2019 11:52:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527162; cv=none;
        d=google.com; s=arc-20160816;
        b=vwIq7MeYl/rduhxJEAsojeRS4t/mRBHjt/FCv5Dcw4rUlXlGf6SvVqxJC8zOPe3D4E
         gDC9fCSu1E8SVBD2b1PPnLDbQwmZUD/A0LaMl2B26BaD79w7qNVaQ7DGv7yeDvQ4MnR1
         nvpG5naa0utO2FOB0DYGLsbjEWx++eyYQBUIEIqVhiwFHLY4w9upn1xEM9PA7DT/OZUl
         jahOl9WW2g3Bom6xtr4KdW1RVE5U2AEoA00hpPJ2XotFla+QqrYfq9N5zBUtPza48rQP
         xEU8NMo+xW4enPyjfQiI3eRx6dUu3ytxzlMVhDhAnPUaIOMarhSSNHqgVE0Rsoq4HJU8
         i2LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=LMoYYohTDCsg4RTF0qKmHG620NIXuEopdfdugBPNwsA=;
        b=GIcR2zFKpv2kKq20ei3Hh0EXcXTFAwPTYczinSX00lJDzidtjOSXuice4JtI6vqSYe
         UkBYRF+VMejBCTZ/QyVQCAGcWhk/TY1V072PsIC5Jsor6hTs9bXhKEJLjyx+6FGrYEWi
         7KP/p4O6EVwEZ+xAWteY3vTlQoxG4rfaMjPWkb2GSvKmCrzQknoFjs7Vea0dTCFXgGyW
         Uf7k4Ic5+g3FKZa4A9Lv1AgFY8JFDfMvw99gzl8pAp5QSmDMQV+wgKGNdbzR+IqLLjX2
         n2hoSTEtXW7EZ36NOFgmeD6jIpQvUToRi9DzT8rvSVcICf0/OUFjXdUn+hVjVlLYlnoY
         2xVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g123si51531334pfc.58.2019.04.17.11.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:52:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:52:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="136653982"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga006.jf.intel.com with ESMTP; 17 Apr 2019 11:52:41 -0700
Subject: [PATCH v6 00/12] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:38:55 -0700
Message-ID: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v5 [1]:

- Rebase on next-20190416 and the new 'struct mhp_restrictions'
  infrastructure.

- Extend mhp_restrictions to the 'remove' case so the sub-section policy
  can be clarified with respect to the memblock-api in a symmetric
  manner with the 'add' case.

- Kill is_dev_zone() since cleanups have now made it moot

[1]: https://lwn.net/Articles/783808/

---

The memory hotplug section is an arbitrary / convenient unit for memory
hotplug. 'Section-size' units have bled into the user interface
('memblock' sysfs) and can not be changed without breaking existing
userspace. The section-size constraint, while mostly benign for typical
memory hotplug, has and continues to wreak havoc with 'device-memory'
use cases, persistent memory (pmem) in particular. Recall that pmem uses
devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
'struct page' memmap for pmem. However, it does not use the 'bottom
half' of memory hotplug, i.e. never marks pmem pages online and never
exposes the userspace memblock interface for pmem. This leaves an
opening to redress the section-size constraint.

To date, the libnvdimm subsystem has attempted to inject padding to
satisfy the internal constraints of arch_add_memory(). Beyond
complicating the code, leading to bugs [2], wasting memory, and limiting
configuration flexibility, the padding hack is broken when the platform
changes this physical memory alignment of pmem from one boot to the
next. Device failure (intermittent or permanent) and physical
reconfiguration are events that can cause the platform firmware to
change the physical placement of pmem on a subsequent boot, and device
failure is an everyday event in a data-center.

It turns out that sections are only a hard requirement of the
user-facing interface for memory hotplug and with a bit more
infrastructure sub-section arch_add_memory() support can be added for
kernel internal usages like devm_memremap_pages(). Here is an analysis
of the current design assumptions in the current code and how they are
addressed in the new implementation:

Current design assumptions:

- Sections that describe boot memory (early sections) are never
  unplugged / removed.

- pfn_valid(), in the CONFIG_SPARSEMEM_VMEMMAP=y, case devolves to a
  valid_section() check

- __add_pages() and helper routines assume all operations occur in
  PAGES_PER_SECTION units.

- The memblock sysfs interface only comprehends full sections

New design assumptions:

- Sections are instrumented with a sub-section bitmask to track (on x86)
  individual 2MB sub-divisions of a 128MB section.

- Partially populated early sections can be extended with additional
  sub-sections, and those sub-sections can be removed with
  arch_remove_memory(). With this in place we no longer lose usable memory
  capacity to padding.

- pfn_valid() is updated to look deeper than valid_section() to also check the
  active-sub-section mask. This indication is in the same cacheline as
  the valid_section() so the performance impact is expected to be
  negligible. So far the lkp robot has not reported any regressions.

- Outside of the core vmemmap population routines which are replaced,
  other helper routines like shrink_{zone,pgdat}_span() are updated to
  handle the smaller granularity. Core memory hotplug routines that deal
  with online memory are not touched.

- The existing memblock sysfs user api guarantees / assumptions are
  not touched since this capability is limited to !online
  !memblock-sysfs-accessible sections.

Meanwhile the issue reports continue to roll in from users that do not
understand when and how the 128MB constraint will bite them. The current
implementation relied on being able to support at least one misaligned
namespace, but that immediately falls over on any moderately complex
namespace creation attempt. Beyond the initial problem of 'System RAM'
colliding with pmem, and the unsolvable problem of physical alignment
changes, Linux is now being exposed to platforms that collide pmem
ranges with other pmem ranges by default [3]. In short,
devm_memremap_pages() has pushed the venerable section-size constraint
past the breaking point, and the simplicity of section-aligned
arch_add_memory() is no longer tenable.

These patches are exposed to the kbuild robot on my libnvdimm-pending
branch [4], and a preview of the unit test for this functionality is
available on the 'subsection-pending' branch of ndctl [5].

[2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
[3]: https://github.com/pmem/ndctl/issues/76
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=libnvdimm-pending
[5]: https://github.com/pmem/ndctl/commit/7c59b4867e1c

---

Dan Williams (12):
      mm/sparsemem: Introduce struct mem_section_usage
      mm/sparsemem: Introduce common definitions for the size and mask of a section
      mm/sparsemem: Add helpers track active portions of a section at boot
      mm/hotplug: Prepare shrink_{zone,pgdat}_span for sub-section removal
      mm/sparsemem: Convert kmalloc_section_memmap() to populate_section_memmap()
      mm/hotplug: Add mem-hotplug restrictions for remove_memory()
      mm: Kill is_dev_zone() helper
      mm/sparsemem: Prepare for sub-section ranges
      mm/sparsemem: Support sub-section hotplug
      mm/devm_memremap_pages: Enable sub-section remap
      libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
      libnvdimm/pfn: Stop padding pmem namespaces to section alignment


 arch/ia64/mm/init.c            |    4 
 arch/powerpc/mm/mem.c          |    5 -
 arch/s390/mm/init.c            |    2 
 arch/sh/mm/init.c              |    4 
 arch/x86/mm/init_32.c          |    4 
 arch/x86/mm/init_64.c          |    9 +
 drivers/nvdimm/dax_devs.c      |    2 
 drivers/nvdimm/pfn.h           |   12 -
 drivers/nvdimm/pfn_devs.c      |   93 +++-------
 include/linux/memory_hotplug.h |   12 +
 include/linux/mm.h             |    4 
 include/linux/mmzone.h         |   72 ++++++--
 kernel/memremap.c              |   70 +++-----
 mm/hmm.c                       |    2 
 mm/memory_hotplug.c            |  148 +++++++++-------
 mm/page_alloc.c                |    8 +
 mm/sparse-vmemmap.c            |   21 ++
 mm/sparse.c                    |  371 +++++++++++++++++++++++++++-------------
 18 files changed, 503 insertions(+), 340 deletions(-)

