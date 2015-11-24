Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFAD6B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:38:32 -0500 (EST)
Received: by oiww189 with SMTP id w189so18260473oiw.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:38:31 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id zf5si13357984obb.63.2015.11.24.13.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:38:31 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 0/3] Allow EINJ to inject memory error to NVDIMM
Date: Tue, 24 Nov 2015 15:33:35 -0700
Message-Id: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@rjwysocki.net, dan.j.williams@intel.com
Cc: tony.luck@intel.com, bp@alien8.de, vishal.l.verma@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

This patch-set extends the EINJ driver to allow injecting a memory
error to NVDIMM.  It first extends iomem resource interface to support
checking a NVDIMM region.

Patch 1/3 changes region_intersects() to accept non-RAM regions, and
adds region_intersects_ram().

Patch 2/3 adds region_intersects_pmem() to check a NVDIMM region.

Patch 3/3 changes the EINJ driver to allow injecting a memory error
to NVDIMM.

---
v3:
 - Check the param2 value before target memory type. (Tony Luck)
 - Add a blank line before if-statement. Remove an unnecessary brakets.
   (Borislav Petkov)

v2:
 - Change the EINJ driver to call region_intersects_ram() for checking
   RAM with a specified size. (Dan Williams)
 - Add export to region_intersects_ram().

---
Toshi Kani (3):
 1/3 resource: Add @flags to region_intersects()
 2/3 resource: Add region_intersects_pmem()
 3/3 ACPI/APEI/EINJ: Allow memory error injection to NVDIMM

---
 drivers/acpi/apei/einj.c | 12 ++++++++----
 include/linux/mm.h       |  5 ++++-
 kernel/memremap.c        |  5 ++---
 kernel/resource.c        | 35 ++++++++++++++++++++++++++++-------
 4 files changed, 42 insertions(+), 15 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
