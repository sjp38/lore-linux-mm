Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5FB6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 15:37:07 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id w20so38590302qtb.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 12:37:07 -0800 (PST)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id p1si20002359qtb.210.2017.02.03.12.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 12:37:06 -0800 (PST)
Received: by mail-qt0-x244.google.com with SMTP id s58so6776183qtc.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 12:37:06 -0800 (PST)
Subject: Re: [Resend PATCH 2/2] mm/memory_hotplug: set magic number to
 page->freelsit instead of page->lru.next
References: <b7ae8d10-da58-45cb-f088-f8adff299911@gmail.com>
 <1d34eaa5-a506-8b7a-6471-490c345deef8@gmail.com>
 <2c29bd9f-5b67-02d0-18a3-8828e78bbb6f@gmail.com>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <722b1cc4-93ac-dd8b-2be2-7a7e313b3b0b@gmail.com>
Date: Fri, 3 Feb 2017 15:37:23 -0500
MIME-Version: 1.0
In-Reply-To: <2c29bd9f-5b67-02d0-18a3-8828e78bbb6f@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, dave.hansen@linux.intel.com, vbabka@suse.cz, mgorman@techsingularity.net, qiuxishi@huawei.com

Hi Andrew,

Please apply the following patch into your tree because patch
("mm/memory_hotplug: set magic number to page->freelsit instead of page->lru.next")
is not applied correctly.

---
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Fri, 3 Feb 2017 15:18:03 -0500
Subject: [PATCH] Remove unnecessary code from get_page_bootmem()

The following patch is not applied correctly.
http://lkml.kernel.org/r/2c29bd9f-5b67-02d0-18a3-8828e78bbb6f@gmail.com

So the following unnecessary code still remains.

get_page_bootmem()
{
...
        page->lru.next = (struct list_head *)type;
...

The patch removei 1/2 ? this code from get_page_bootmem()

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
  mm/memory_hotplug.c | 1 -
  1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 19b460a..50b586c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -179,7 +179,6 @@ static void release_memory_resource(struct resource *res)
  void get_page_bootmem(unsigned long info,  struct page *page,
  		      unsigned long type)
  {
-	page->lru.next = (struct list_head *)type;
  	page->freelist = (void *)type;
  	SetPagePrivate(page);
  	set_page_private(page, info);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
