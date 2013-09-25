Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 14CC36B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 21:04:06 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so5374356pdj.1
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 18:04:05 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 25 Sep 2013 11:04:01 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 897672BB0053
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:03:59 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8P13mPk62521474
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:03:48 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8P13w9G005181
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:03:58 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v7 4/4] revert mm/vmalloc.c: emit the failure message before return
Date: Wed, 25 Sep 2013 09:02:44 +0800
Message-Id: <1380070964-12975-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1380070964-12975-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1380070964-12975-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 *v2 -> v3: revert commit 46c001a2 directly

Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
__vmalloc_area_node allocation failure. This patch revert commit 46c001a2
(mm/vmalloc.c: emit the failure message before return).

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e523a14..fa4eee8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node);
 	if (!addr)
-		goto fail;
+		return NULL;
 
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
