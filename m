Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D6246B009B
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:26 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAPte014086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 19 of 25] ensure mapcount is taken on head pages
Message-Id: <8f6ae889d6edf096b76f.1258220317@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:37 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Unlike the page count, the page mapcount cannot be taken on PageTail compound
pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -73,6 +73,7 @@ void page_remove_rmap(struct page *);
 
 static inline void page_dup_rmap(struct page *page)
 {
+	VM_BUG_ON(PageTail(page));
 	atomic_inc(&page->_mapcount);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
