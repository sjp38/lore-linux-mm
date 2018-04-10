Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018DC6B0008
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 22:09:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so8300767plh.7
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 19:09:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d81si1231198pfd.210.2018.04.09.19.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 19:09:03 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v32 3/4] mm/page_poison: expose page_poisoning_enabled to kernel modules
Date: Tue, 10 Apr 2018 09:50:08 +0800
Message-Id: <1523325009-29763-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1523325009-29763-1-git-send-email-wei.w.wang@intel.com>
References: <1523325009-29763-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

In some usages, e.g. virtio-balloon, a kernel module needs to know if
page poisoning is in use. This patch exposes the page_poisoning_enabled
function to kernel modules.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_poison.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_poison.c b/mm/page_poison.c
index e83fd44..762b472 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -17,6 +17,11 @@ static int early_page_poison_param(char *buf)
 }
 early_param("page_poison", early_page_poison_param);
 
+/**
+ * page_poisoning_enabled - check if page poisoning is enabled
+ *
+ * Return true if page poisoning is enabled, or false if not.
+ */
 bool page_poisoning_enabled(void)
 {
 	/*
@@ -29,6 +34,7 @@ bool page_poisoning_enabled(void)
 		(!IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC) &&
 		debug_pagealloc_enabled()));
 }
+EXPORT_SYMBOL_GPL(page_poisoning_enabled);
 
 static void poison_page(struct page *page)
 {
-- 
2.7.4
