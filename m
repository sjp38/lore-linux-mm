Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11D806B02F3
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 17:14:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p45so69991079qtg.11
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 14:14:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si15389281qtb.351.2017.07.03.14.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 14:14:25 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 1/5] mm/persistent-memory: match IORES_DESC name and enum memory_type one
Date: Mon,  3 Jul 2017 17:14:11 -0400
Message-Id: <20170703211415.11283-2-jglisse@redhat.com>
In-Reply-To: <20170703211415.11283-1-jglisse@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Use consistent name between IORES_DESC and enum memory_type, rename
MEMORY_DEVICE_PUBLIC to MEMORY_DEVICE_PERSISTENT. This is to free up
the public name for CDM (cache coherent device memory) for which the
term public is a better match.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h | 4 ++--
 kernel/memremap.c        | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 57546a07a558..2299cc2d387d 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * Specialize ZONE_DEVICE memory into multiple types each having differents
  * usage.
  *
- * MEMORY_DEVICE_PUBLIC:
+ * MEMORY_DEVICE_PERSISTENT:
  * Persistent device memory (pmem): struct page might be allocated in different
  * memory and architecture might want to perform special actions. It is similar
  * to regular memory, in that the CPU can access it transparently. However,
@@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * include/linux/hmm.h and Documentation/vm/hmm.txt.
  */
 enum memory_type {
-	MEMORY_DEVICE_PUBLIC = 0,
+	MEMORY_DEVICE_PERSISTENT = 0,
 	MEMORY_DEVICE_PRIVATE,
 };
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b9baa6c07918..e82456c39a6a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
-	pgmap->type = MEMORY_DEVICE_PUBLIC;
+	pgmap->type = MEMORY_DEVICE_PERSISTENT;
 	pgmap->page_fault = NULL;
 	pgmap->page_free = NULL;
 	pgmap->data = NULL;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
