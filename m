Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F283C6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 14:38:37 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f3so5930588oia.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 11:38:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b41si4483759oth.412.2017.10.02.11.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 11:38:37 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] mm/hmm: constify hmm_devmem_page_get_drvdata() parameter
Date: Mon,  2 Oct 2017 15:32:54 -0400
Message-Id: <1506972774-10191-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

From: Ralph Campbell <rcampbell@nvidia.com>

Constify pointer parameter to avoid issue when use from code that
only has const struct page pointer to use in the first place.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 96e6997..325017a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -471,9 +471,9 @@ static inline void hmm_devmem_page_set_drvdata(struct page *page,
  * @page: pointer to struct page
  * Return: driver data value
  */
-static inline unsigned long hmm_devmem_page_get_drvdata(struct page *page)
+static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
 {
-	unsigned long *drvdata = (unsigned long *)&page->pgmap;
+	const unsigned long *drvdata = (const unsigned long *)&page->pgmap;
 
 	return drvdata[1];
 }
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
