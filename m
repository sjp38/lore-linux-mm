Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C59AC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F339420675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F339420675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B34B6B0006; Tue,  7 May 2019 14:38:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2623B6B0007; Tue,  7 May 2019 14:38:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 104196B0008; Tue,  7 May 2019 14:38:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6FE16B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l4so18988184qke.22
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Cxyym6/ggE/hQ7zrp4iVssYioPIKhL4MxH4d7gsM4pY=;
        b=PTZdzsVppKSMR1gHTVichrq1VILuoQZh9RD/md4EkjmlNUgalZurYCniYuiar1ACSH
         DPgoMMt6BBYqwuYkaiY7yEaTs41aj5OdxSq3woVqzG1TAPQzLs4j+rtFU6aXAJn51fNN
         /3wMEUAT4RIMzXVDAmx8DIk5E5riQlVYB2vvstZbodIB57Umy8+BwR/1nMk6atiVrDEk
         SE72biT1AGWFlcDjiEQ7ozI5Ufx1uBmCqeSCE1+TZrrsCxYVxWX2dfV2Wy8xwS2qzo8C
         kF5ntkbKgAUFdiIiZzNiJhrz5WejXYTS66yQl1Amu2+wvxtkOc9uEOaemvxbkdvUdcdP
         1AvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVZxW5FKRo52VJEKGYPeP69USmxMkWffMo0Qz+wYU1rAqiUSutI
	U2rRmEWu3pF9KGH5ZdmT5z+zKkuyk56mqQaJCg333U3xWlCnyLGAjWc/PARFdy/39UnhXVqgFgR
	HW4mRc1/yvdvwGqp5ph+BXcwk1opOVz7owBqQ8Z5E3r5JerwM75f3yLO3SxCGTGJ7lQ==
X-Received: by 2002:ae9:edc3:: with SMTP id c186mr11743423qkg.156.1557254305718;
        Tue, 07 May 2019 11:38:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp9FHllv08gPrIf56rqXyo9cuUP/DC3akK3XcoUI0V0SmMvt1qs8j7SgsASQ6a3gUWsWui
X-Received: by 2002:ae9:edc3:: with SMTP id c186mr11743254qkg.156.1557254302711;
        Tue, 07 May 2019 11:38:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254302; cv=none;
        d=google.com; s=arc-20160816;
        b=bBj21eFZCLwgi+3VctMC/62u5aMUQ1d7HsliRGIwm1hDggc2drS0wrBVuWO5NDD4Ji
         9Uq9JFipwARYjx+zgIOgDg9B2TRpWhq5z5IES3eWHL0cLdvCBJQaYz9YJ9T7y1kYa3K+
         A3CYOf+zOZy4LIYZgg+szZGbPsYleW+4CnLCx/bNCiyfxHCRecijX0oirDosVa7rHLP0
         axdzGOOtLvaXWS0neprmHobj5mXQLk33gFs5yI6KT1hOb/S6XSzmJVgyCPh99a9Uglmk
         4dvwEBcDkFK3tC4T6hgpfAdUyaBIyIMiza/Nk6cosJnDmNKgRexmgSWA2N+kFEh88K+b
         RI/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Cxyym6/ggE/hQ7zrp4iVssYioPIKhL4MxH4d7gsM4pY=;
        b=asfNxYgq8jT/HYHqwajO8FEIkbqWWaBTvKaT2iknhs/ERzHznjMkB5YiykR4CY+/wf
         JXoKvdcIYgfj20kTGPuNm5y44Z3G24wXjBEF8HuHYOq2+J09XbAPndbE2UHb7YeN32KY
         xYgUaWW8A+Yz3zIVbeeeDt81jd8b/SZiLRjrMBzWrKTkeynkYkUNpyqdaYpZ4oZIvxnV
         bKw4AS3hg44/jWiJGTZ86BGC/VtQPKwURxSEux8q0uX4roqK8gbTeUJytBOhMuLVLvL/
         ymBBLkq2egRQd450DlMi0p9KrcsFiesCOykueD5/1QGKGODQ+hWS5ONvCrk62MI0Jfxy
         YvIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s10si9671127qte.221.2019.05.07.11.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 074D0308FBA0;
	Tue,  7 May 2019 18:38:20 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC0CA3DA5;
	Tue,  7 May 2019 18:38:05 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andy Lutomirski <luto@kernel.org>,
	Arun KS <arunks@codeaurora.org>,
	Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Brown <broonie@kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mathieu Malaterre <malat@debian.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH v2 0/8] mm/memory_hotplug: Factor out memory block device handling
Date: Tue,  7 May 2019 20:37:56 +0200
Message-Id: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 07 May 2019 18:38:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We only want memory block devices for memory to be onlined/offlined
(add/remove from the buddy). This is required so user space can
online/offline memory and kdump gets notified about newly onlined memory.

Only such memory has the requirement of having to span whole memory blocks.
Let's factor out creation/removal of memory block devices. This helps
to further cleanup arch_add_memory/arch_remove_memory() and to make
implementation of new features easier. E.g. supplying a driver for
memory block devices becomes way easier (so user space is able to
distinguish different types of added memory to properly online it).

Patch 1 makes sure the memory block size granularity is always respected.
Patch 2 implements arch_remove_memory() on s390x. Patch 3 prepares
arch_remove_memory() to be also called without CONFIG_MEMORY_HOTREMOVE.
Patch 4,5 and 6 factor out creation/removal of memory block devices.
Patch 7 gets rid of some unlikely errors that could have happened, not
removing links between memory block devices and nodes, previously brought
up by Oscar.

Did a quick sanity test with DIMM plug/unplug, making sure all devices
and sysfs links properly get added/removed. Compile tested on s390x and
x86-64.

Based on git://git.cmpxchg.org/linux-mmots.git

Next refactoring on my list will be making sure that remove_memory()
will never deal with zones / access "struct pages". Any kind of zone
handling will have to be done when offlining system memory / before
removing device memory. I am thinking about remove_pfn_range_from_zone()",
du undo everything "move_pfn_range_to_zone()" did.

v1 -> v2:
- s390x/mm: Implement arch_remove_memory()
-- remove mapping after "__remove_pages"


David Hildenbrand (8):
  mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
  s390x/mm: Implement arch_remove_memory()
  mm/memory_hotplug: arch_remove_memory() and __remove_pages() with
    CONFIG_MEMORY_HOTPLUG
  mm/memory_hotplug: Create memory block devices after arch_add_memory()
  mm/memory_hotplug: Drop MHP_MEMBLOCK_API
  mm/memory_hotplug: Remove memory block devices before
    arch_remove_memory()
  mm/memory_hotplug: Make unregister_memory_block_under_nodes() never
    fail
  mm/memory_hotplug: Remove "zone" parameter from
    sparse_remove_one_section

 arch/ia64/mm/init.c            |   2 -
 arch/powerpc/mm/mem.c          |   2 -
 arch/s390/mm/init.c            |  15 +++--
 arch/sh/mm/init.c              |   2 -
 arch/x86/mm/init_32.c          |   2 -
 arch/x86/mm/init_64.c          |   2 -
 drivers/base/memory.c          | 109 +++++++++++++++++++--------------
 drivers/base/node.c            |  27 +++-----
 include/linux/memory.h         |   6 +-
 include/linux/memory_hotplug.h |  12 +---
 include/linux/node.h           |   7 +--
 mm/memory_hotplug.c            |  44 ++++++-------
 mm/sparse.c                    |  10 +--
 13 files changed, 104 insertions(+), 136 deletions(-)

-- 
2.20.1

