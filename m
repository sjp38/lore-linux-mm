Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42C54C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0904B2082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0904B2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DA106B0003; Thu, 20 Jun 2019 06:35:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 789C58E0002; Thu, 20 Jun 2019 06:35:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650508E0001; Thu, 20 Jun 2019 06:35:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 411EC6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:35:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r40so3063717qtk.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:35:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=6eourjUrY5W8L+9v6dreqWQZxYmO/clrAxJ3gl9QD00=;
        b=UDBS1m8IEqduQAbc5/qlxpUCKIW8q53BogMqQKjA6J23736o+PwMDO+3GNJw6es5c/
         eV3JDXJXU/jgjfLZp56KtZiOIYzFcSpcKvo3nOQExsVgfyevarVU5epknkolUE6My9kF
         HNrqO+coZoXoihr492nPHHS8H+z0eLW2wZVUx8Ye7F7qNYk+ckh/ZC+hkTTOqqHhh1Xo
         QH8qsjMQ2v5kGKHJvv9Q3Mj/JzG6KuRRtBMtmtZ/dYWv4t4tXKkutMDaJpmGvtbfDi4T
         lYRtxnQQ8FzS1Ts4uLk5bQFmO+DQuCpGGgeBDDQXg8s3fpL7QyOSRg35WtG74Mmu/4Zc
         NG0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWqXOUY0cZjB0AmXTKDsv5NQzjV4iXOm2xuCp6TC/dKaVY7Cc7j
	EA1aUXjBwnZXIK2w/Li9dlMDagx6vXmIH08u1cEOrl0IT8JAtgjopOg1A9tumWyO5xnYWSegLjB
	dpKAouPtW4s3bnqFel9hS4Cy3HQEViiFh+7lkHZpJu+PdXQdGcZfZfWQSIVlcdnEyGA==
X-Received: by 2002:ac8:66d8:: with SMTP id m24mr10459804qtp.355.1561026945004;
        Thu, 20 Jun 2019 03:35:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx//MLmmku2cHsdduW8mFJfwqkr87O+3YotPjitFIEkhZIphFYv83A8KhoLJmYtxkpYLE5a
X-Received: by 2002:ac8:66d8:: with SMTP id m24mr10459760qtp.355.1561026944193;
        Thu, 20 Jun 2019 03:35:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026944; cv=none;
        d=google.com; s=arc-20160816;
        b=PrjGDrV3xZFNmRCCcObeVG1apucQJ7yV5fI0oo5O6LGHf/AqUTpQPUTGa9PNaB+tfS
         zG5tomKaE3bUq7GVq0OQ+1tm14Piih4ya1rFxZmPSMyMTu+FAQuEnUOly4TWt3mzp/w9
         J/K5ep6P36V2d/kHZiLsm+ZiwO6qJfUGYAWJhzVUbNX1DMWghJmk4laCCWsOcshRU3PF
         zci779WFw1eKX8v7ylg8iUrMHQ7f6XwqiIQ6JBeINXofD/mrl+vboLN+KKNEQ7nhO2zK
         n0cmgup3EF0mX0AH4K3Q+sEml+ntQm1mFG3srBX8Y2YR/LI/MI7huV/CwqbfD/YKIrPP
         I4bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=6eourjUrY5W8L+9v6dreqWQZxYmO/clrAxJ3gl9QD00=;
        b=o4hgWUDOdIx7YmVaDd1Fpg24BinS//DkooLUTztZ1WDhrDJrwfjzTDHtCTfeCEsJ7c
         6Fo2Xz5qzbV+ugJet16xM4pSXTgVMSuPXfFp2eNXq3rJCqgQt9MeVZLZhnEtjQMZcz5d
         yStntWTLC+L8K3Y2xzUOlXmnWVJ7qRS4L5rAhTwP96MitCfA8l4HthCC7quzDXl86S8u
         sujBYPkCGcbM2QT0Z82lC5xN7vhXlkrLJqyOYAakUYEvlqUG+QbP+bliJvkev09HBQ3r
         /KxoJPjIERReNrdhgHv1+Q2f2UItKfd/qvsL/rio+hjq4qtdY8rDC63nVOPqB1EUpQxm
         Wo4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s52si4416367qts.399.2019.06.20.03.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:35:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E1A41C1EB202;
	Thu, 20 Jun 2019 10:35:34 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6A49D608A7;
	Thu, 20 Jun 2019 10:35:21 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Juergen Gross <jgross@suse.com>,
	Keith Busch <keith.busch@intel.com>,
	Len Brown <lenb@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michael Neuling <mikey@neuling.org>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Rashmica Gupta <rashmica.g@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2 0/6] mm: Further memory block device cleanups
Date: Thu, 20 Jun 2019 12:35:14 +0200
Message-Id: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 20 Jun 2019 10:35:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

@Andrew: Only patch 1 and 6 changed. The patches are based on the
same state as the previous patches (replace the old ones if possible).

Some further cleanups around memory block devices. Especially, clean up
and simplify walk_memory_range(). Including some other minor cleanups.

Compiled + tested on x86 with DIMMs under QEMU.

v1 -> v2:
- "mm: Section numbers use the type "unsigned long""
-- "unsigned long i" -> "unsigned long nr", in one case -> "int i"
- "drivers/base/memory.c: Get rid of find_memory_block_hinted("
-- Fix compilation error
-- Get rid of the "hint" parameter completely

David Hildenbrand (6):
  mm: Section numbers use the type "unsigned long"
  drivers/base/memory: Use "unsigned long" for block ids
  mm: Make register_mem_sect_under_node() static
  mm/memory_hotplug: Rename walk_memory_range() and pass start+size
    instead of pfns
  mm/memory_hotplug: Move and simplify walk_memory_blocks()
  drivers/base/memory.c: Get rid of find_memory_block_hinted()

 arch/powerpc/platforms/powernv/memtrace.c |  22 ++---
 drivers/acpi/acpi_memhotplug.c            |  19 +---
 drivers/base/memory.c                     | 115 ++++++++++++++--------
 drivers/base/node.c                       |   8 +-
 include/linux/memory.h                    |   5 +-
 include/linux/memory_hotplug.h            |   2 -
 include/linux/mmzone.h                    |   4 +-
 include/linux/node.h                      |   7 --
 mm/memory_hotplug.c                       |  57 +----------
 mm/sparse.c                               |  12 +--
 10 files changed, 105 insertions(+), 146 deletions(-)

-- 
2.21.0

