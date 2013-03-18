Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 466656B0037
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:21:26 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 1/3]  mm: Export split_page()
Date: Mon, 18 Mar 2013 13:51:36 -0700
Message-Id: <1363639898-1615-1-git-send-email-kys@microsoft.com>
In-Reply-To: <1363639873-1576-1-git-send-email-kys@microsoft.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

This symbol would be used in the Hyper-V balloon driver to support 2M
allocations.

In this version of the patch, based on feedback from Michal Hocko
<mhocko@suse.cz>, I have updated the patch description.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 mm/page_alloc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cacfee..7e0ead6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1404,6 +1404,7 @@ void split_page(struct page *page, unsigned int order)
 	for (i = 1; i < (1 << order); i++)
 		set_page_refcounted(page + i);
 }
+EXPORT_SYMBOL_GPL(split_page);
 
 static int __isolate_free_page(struct page *page, unsigned int order)
 {
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
