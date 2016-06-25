Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6FC6B025E
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 13:41:46 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so258806729pat.3
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 10:41:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b6si1873972pay.102.2016.06.25.10.41.45
        for <linux-mm@kvack.org>;
        Sat, 25 Jun 2016 10:41:45 -0700 (PDT)
Subject: [PATCH 1/2] mm: CONFIG_ZONE_DEVICE stop depending on CONFIG_EXPERT
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 25 Jun 2016 10:41:02 -0700
Message-ID: <146687646274.39261.14267596518720371009.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <146687645727.39261.14620086569655191314.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <146687645727.39261.14620086569655191314.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Eric Sandeen <sandeen@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

When it was first introduced CONFIG_ZONE_DEVICE depended on disabling
CONFIG_ZONE_DMA, a configuration choice reserved for "experts".
However, now that the ZONE_DMA conflict has been eliminated it no longer
makes sense to require CONFIG_EXPERT.

Reported-by: Eric Sandeen <sandeen@redhat.com>
Reported-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 3e2daef3c946..d109a7a0c1c4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -673,7 +673,7 @@ config IDLE_PAGE_TRACKING
 	  See Documentation/vm/idle_page_tracking.txt for more details.
 
 config ZONE_DEVICE
-	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
+	bool "Device memory (pmem, etc...) hotplug support"
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
