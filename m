Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 235986B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 19:24:35 -0400 (EDT)
Received: by oiad129 with SMTP id d129so56858668oia.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 16:24:34 -0700 (PDT)
Received: from g2t4622.austin.hp.com (g2t4622.austin.hp.com. [15.73.212.79])
        by mx.google.com with ESMTPS id dx4si10342362obb.90.2015.10.22.16.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 16:24:34 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/3] Allow EINJ to inject memory error to NVDIMM
Date: Thu, 22 Oct 2015 17:20:41 -0600
Message-Id: <1445556044-30322-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

This patch-set extends the EINJ driver to allow injecting a memory
error to NVDIMM.  It first extends iomem resource interface to support
checking a NVDIMM region.

Patch 1/3 changes region_intersects() to accept non-RAM regions, and
adds region_intersects_ram().

Patch 2/3 adds region_intersects_pmem() to check a NVDIMM region.

Patch 3/3 changes the EINJ driver to allow injecting a memory error
to NVDIMM.

---
Toshi Kani (3):
 1/3 resource: Add @flags to region_intersects()
 2/3 resource: Add region_intersects_pmem()
 3/3 ACPI/APEI/EINJ: Allow memory error injection to NVDIMM

---
 drivers/acpi/apei/einj.c | 12 ++++++++----
 include/linux/mm.h       |  5 ++++-
 kernel/memremap.c        |  5 ++---
 kernel/resource.c        | 34 +++++++++++++++++++++++++++-------
 4 files changed, 41 insertions(+), 15 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
