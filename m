Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFE7C6B0009
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n5so13576316qtl.13
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u189si883346qkd.79.2018.04.04.12.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:02 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 07/79] mm/page: add helpers to find mapping give a page and buffer head
Date: Wed,  4 Apr 2018 15:17:54 -0400
Message-Id: <20180404191831.5378-5-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For now this simply use exist page_mapping() inline. Latter it will
use buffer head pointer as a key to lookup mapping for write protected
page.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm-page.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mm-page.h b/include/linux/mm-page.h
index 2981db45eeef..647a8a8cf9ba 100644
--- a/include/linux/mm-page.h
+++ b/include/linux/mm-page.h
@@ -132,5 +132,17 @@ static inline unsigned long _page_file_offset(struct page *page,
 	return page->index << PAGE_SHIFT;
 }
 
+/*
+ * fs_page_mapping_get_with_bh() - page mapping knowing buffer_head
+ * @page: page struct pointer for which we want the mapping
+ * @bh: buffer_head associated with the page for the mapping
+ * Returns: page mapping for the given buffer head
+ */
+static inline struct address_space *fs_page_mapping_get_with_bh(
+		struct page *page, struct buffer_head *bh)
+{
+	return page_mapping(page);
+}
+
 #endif /* MM_PAGE_H */
 #endif /* DOT_NOT_INCLUDE___INSIDE_MM */
-- 
2.14.3
