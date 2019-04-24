Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E98F9C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A46F4218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A46F4218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BE526B000A; Wed, 24 Apr 2019 06:25:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A12A6B0008; Wed, 24 Apr 2019 06:25:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25D696B000A; Wed, 24 Apr 2019 06:25:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02BF26B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:25:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k6so15567191qkf.13
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:25:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ovxRdLHLpo/ZGFIFnwb1QGvap7Uwfci/2N8Hcrm8h7c=;
        b=mTLlv3/agFDaDLZIcKYX5jYO5soCXeeW3hZiejx9a5qzG5umd5pou0sgD5eHPVbIWX
         gY/yTcUZJn/1Wm2hR92sSsFMbgsjgS5MzrNu6K+MRnQDQlfBOYYbUQ8vnIDbil4UMERS
         MSdqddTh/up3Wn/T1ojwbYoBUIaiOuR54vuxrGbm1/ksRfONiCpxkXXEj3EkOTuo/xlE
         FSsgT9ld5IKbpUYI68v5NthmB9LIbDOTwoosf81NB7ap1FVz2tC6FWuaEUAiV8pVCCFB
         HqJ8d48eNqkndLIqzrK5pK7rRil7mDu5lxJtMmu6qyOgHjeKTGniSlOAKbzSgrMSIe1f
         rDzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/cE+fsM7pagRBBa03/ns0lGIbK1HCQYuF16FgabMsXed39bs9
	kMrxi5ARlJVzFO3zhj54ngPZPhWF8dpKHxBQ4C6DDVXvEjIX3UeMn96QrfTEByaTAxnREHJyg9I
	eXTC6IUAudCTJKU6BEizlEc6nB9MGdLW7xW3o2FJRAtSfX50PtkPh3IfJ+75R4MaNkg==
X-Received: by 2002:a0c:bf50:: with SMTP id b16mr11551622qvj.110.1556101540721;
        Wed, 24 Apr 2019 03:25:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydLNwMOHuCIw4IMTudyPOxIwpraHDRoUH+ihyVpMxwE21+lB95qDw4ZbxwIsvtLg29Orol
X-Received: by 2002:a0c:bf50:: with SMTP id b16mr11551568qvj.110.1556101539951;
        Wed, 24 Apr 2019 03:25:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101539; cv=none;
        d=google.com; s=arc-20160816;
        b=Lgw4eXjAS9+mhuBS1O8oG55+QbMqYnrmrh4ZDZneWGjjVrYtFt845+GJMGAB2TN1yB
         KaRkyOWSKeCtHlHXMzkBrVkEBUEQAKb1L5ITxqCKkL3/S1+hZJipo3QG6epkTtveTqnW
         dDJtDcfdnKhcGUza/pgIfM2nCJ+9LxZmQ3CyXP5xaphaJTjo7umRmwaCcVyGFl0FrR/S
         ZlkaufJSuHz3awgO1zWSj07EcEHVcH7e+TWGiR21O/bRT9kZEoyNMN02O6ejterML1Vp
         +ZmNTMxD0Edowcc0z+rYWZ/KocR0+snpLSOgQ/3caV+pcUhnHlPRzndRmlgKi478/XDi
         k4UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ovxRdLHLpo/ZGFIFnwb1QGvap7Uwfci/2N8Hcrm8h7c=;
        b=FQAj5vZjLs8MWgTgBazSQ4AXalB7VOsCVj2xCbtleI51vnotl8FlJNQFRqicjqbMc1
         r95fEzfwf/0NXH6lzkFDdhfmII/dVQV8BhhG4PkAqWIrLMk9V587tJWp3HXw1+Phyg2M
         inTujtBho6+YtGRyAJDX6/zsCblclLGTQkm7XTmQ+DqhV/N8McVWLYvIGwnNU9JyMbUx
         k+jqZpdYAj+Y1kf2GGe+76RxB3SWHOXo8vDXmjaeW/McH4zAU/DO2lIlN8PNWdMyNsgZ
         OfNnS3TxZK4W0/Kb3KZ+vzbqlWe0C6H7ORGs5nE1HvcUagrZa6FTiwK3d5DATZvuBQ8s
         0lpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i37si2280171qti.228.2019.04.24.03.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:25:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E2923199364;
	Wed, 24 Apr 2019 10:25:33 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2CDA8600C4;
	Wed, 24 Apr 2019 10:25:12 +0000 (UTC)
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
Subject: [PATCH v1 0/7] mm/memory_hotplug: Factor out memory block device handling
Date: Wed, 24 Apr 2019 12:25:04 +0200
Message-Id: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 24 Apr 2019 10:25:38 +0000 (UTC)
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
implementation of new features (e.g. sub-section hot-add) easier.

Patch 1 makes sure the memory block size granularity is always respected.
Patch 2 implements arch_remove_memory() on s390x. Patch 3 prepares
arch_remove_memory() to be also called without CONFIG_MEMORY_HOTREMOVE.
Patch 4,5 and 6 factor out creation/removal of memory block devices.
Patch 7 gets rid of some unlikely errors that could have happened, not
removinf links between memory block devices and nodes, previously brought
up by Oscar.

Did a quick sanity test with DIMM plug/unplug, making sure all devices
and sysfs links properly get added/removed. Compile tested on s390x and
x86-64.

Based on git://git.cmpxchg.org/linux-mmots.git

David Hildenbrand (7):
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

 arch/ia64/mm/init.c            |   2 -
 arch/powerpc/mm/mem.c          |   2 -
 arch/s390/mm/init.c            |  15 +++--
 arch/sh/mm/init.c              |   2 -
 arch/x86/mm/init_32.c          |   2 -
 arch/x86/mm/init_64.c          |   2 -
 drivers/base/memory.c          | 109 +++++++++++++++++++--------------
 drivers/base/node.c            |  27 +++-----
 include/linux/memory.h         |   6 +-
 include/linux/memory_hotplug.h |  10 ---
 include/linux/node.h           |   7 +--
 mm/memory_hotplug.c            |  42 +++++--------
 mm/sparse.c                    |   6 --
 13 files changed, 100 insertions(+), 132 deletions(-)

-- 
2.20.1

