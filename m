Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB016B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:18:07 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id r129so95637216wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:18:07 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id vx5si549828wjc.219.2016.01.26.01.18.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 01:18:05 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 26 Jan 2016 09:18:05 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id EDD201B0807C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:08 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0Q9I1gE6291918
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0Q9I0hn027050
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 02:18:01 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH/RFC 1/3] mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
Date: Tue, 26 Jan 2016 10:18:23 +0100
Message-Id: <1453799905-10941-2-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>

We can provide debug_pagealloc_enabled() also if CONFIG_DEBUG_PAGEALLOC
is not set. It will return false in that case.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7783073..fbc5354 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2148,6 +2148,10 @@ kernel_map_pages(struct page *page, int numpages, int enable)
 extern bool kernel_page_present(struct page *page);
 #endif /* CONFIG_HIBERNATION */
 #else
+static inline bool debug_pagealloc_enabled(void)
+{
+	return false;
+}
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
 #ifdef CONFIG_HIBERNATION
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
