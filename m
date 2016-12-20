Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4D06B0349
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:16:05 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d45so133426162qta.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:16:05 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id d31si3343571qkh.193.2016.12.20.11.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 11:16:04 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id n6so24113431qtd.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:16:04 -0800 (PST)
Subject: [PATCH 1/2] mm/sparse: use page_private() to get page->private value
References: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <f32225cf-be0f-9f9f-6f46-53a25029f3c4@gmail.com>
Date: Tue, 20 Dec 2016 14:16:00 -0500
MIME-Version: 1.0
In-Reply-To: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

free_map_bootmem() uses page->private directly to set
removing_section_nr argument. But to get page->private
value, page_private() has been prepared.

So free_map_bootmem() should use page_private() instead of
page->private.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
  mm/sparse.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 1e168bf..c62b366 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -667,7 +667,7 @@ static void free_map_bootmem(struct page *memmap)
  		BUG_ON(magic == NODE_INFO);

  		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
-		removing_section_nr = page->private;
+		removing_section_nr = page_private()

  		/*
  		 * When this function is called, the removing section is
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
