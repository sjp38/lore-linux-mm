Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854316B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p1so2524734pfp.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:16 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 01/10] idr: add #include <linux/bug.h>
Date: Wed, 29 Nov 2017 21:55:17 +0800
Message-Id: <1511963726-34070-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

The <linux/bug.h> was removed from radix-tree.h by the following commit:
f5bba9d11a256ad2a1c2f8e7fc6aabe6416b7890.

Since that commit, tools/testing/radix-tree/ couldn't pass compilation
due to: tools/testing/radix-tree/idr.c:17: undefined reference to
WARN_ON_ONCE. This patch adds the bug.h header to idr.h to solve the
issue.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Eric Biggers <ebiggers@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
---
 include/linux/idr.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 7c3a365..fa14f83 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -15,6 +15,7 @@
 #include <linux/radix-tree.h>
 #include <linux/gfp.h>
 #include <linux/percpu.h>
+#include <linux/bug.h>
 
 struct idr {
 	struct radix_tree_root	idr_rt;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
