Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2A86B597D
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:00:41 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y83so6001294qka.7
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 10:00:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si1067894qvp.175.2018.11.30.10.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 10:00:39 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 4/4] mm/memory_hotplug: Drop MEMORY_TYPE_UNSPECIFIED
Date: Fri, 30 Nov 2018 18:59:22 +0100
Message-Id: <20181130175922.10425-5-david@redhat.com>
In-Reply-To: <20181130175922.10425-1-david@redhat.com>
References: <20181130175922.10425-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Banman <andrew.banman@hpe.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Michal=20Such=C3=A1nek?= <msuchanek@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>

We now have proper types for all users, we can drop this one.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michal Suchánek <msuchanek@suse.de>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 3 ---
 include/linux/memory.h | 5 -----
 2 files changed, 8 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c5fdca7a3009..a6e524f0ea38 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -388,9 +388,6 @@ static ssize_t type_show(struct device *dev, struct device_attribute *attr,
 	ssize_t len = 0;
 
 	switch (mem->type) {
-	case MEMORY_BLOCK_UNSPECIFIED:
-		len = sprintf(buf, "unspecified\n");
-		break;
 	case MEMORY_BLOCK_BOOT:
 		len = sprintf(buf, "boot\n");
 		break;
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a3a1e9764805..11679622f743 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -50,10 +50,6 @@ int set_memory_block_size_order(unsigned int order);
  *  No memory block is to be created (e.g. device memory). Not exposed to
  *  user space.
  *
- * MEMORY_BLOCK_UNSPECIFIED:
- *  The type of memory block was not further specified when adding the
- *  memory block.
- *
  * MEMORY_BLOCK_BOOT:
  *  This memory block was added during boot by the basic system. No
  *  specific device driver takes care of this memory block. This memory
@@ -103,7 +99,6 @@ int set_memory_block_size_order(unsigned int order);
  */
 enum {
 	MEMORY_BLOCK_NONE = 0,
-	MEMORY_BLOCK_UNSPECIFIED,
 	MEMORY_BLOCK_BOOT,
 	MEMORY_BLOCK_DIMM,
 	MEMORY_BLOCK_DIMM_UNREMOVABLE,
-- 
2.17.2
