Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8DFE6B03B7
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:49:13 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y1so1853760qkd.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:49:13 -0800 (PST)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id m62si5764856qkb.14.2016.12.21.07.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 07:49:13 -0800 (PST)
Received: by mail-qk0-x243.google.com with SMTP id t184so9354712qkd.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:49:13 -0800 (PST)
Subject: [Resend PATCH 1/2] mm/sparse: use page_private() to get page->private
 value
References: <b7ae8d10-da58-45cb-f088-f8adff299911@gmail.com>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <1d34eaa5-a506-8b7a-6471-490c345deef8@gmail.com>
Date: Wed, 21 Dec 2016 10:49:08 -0500
MIME-Version: 1.0
In-Reply-To: <b7ae8d10-da58-45cb-f088-f8adff299911@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, dave.hansen@linux.intel.com, vbabka@suse.cz, mgorman@techsingularity.net, qiuxishi@huawei.com

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
index 1e168bf..dc30a70 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -667,7 +667,7 @@ static void free_map_bootmem(struct page *memmap)
  		BUG_ON(magic == NODE_INFO);

  		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
-		removing_section_nr = page->private;
+		removing_section_nr = page_private(page);

  		/*
  		 * When this function is called, the removing section is
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
