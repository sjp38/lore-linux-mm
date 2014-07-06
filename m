Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 373DD6B0036
	for <linux-mm@kvack.org>; Sun,  6 Jul 2014 15:30:50 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so4146843pdi.23
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 12:30:49 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id hp4si39533868pac.0.2014.07.06.12.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 06 Jul 2014 12:30:48 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3BEBE3EE0AE
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:30:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 4EBD2AC0519
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:30:46 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0206F1DB8038
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:30:46 +0900 (JST)
Message-ID: <53B9A38F.9000609@jp.fujitsu.com>
Date: Mon, 7 Jul 2014 04:29:19 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] firmware/memmap: pass the correct argument to firmware_map_find_entry_bootmem()
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, santosh.shilimkar@ti.com, toshi.kani@hp.com

firmware_map_add_hotplug() calls firmware_map_find_entry_bootmem() to get
free firmware_map_entry. But end arguments is not correct. So
firmware_map_find_entry_bootmem() cannot not find firmware_map_entry.

The patch passes the correct end argument to firmware_map_find_entry_bootmem().

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/firmware/memmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 17cf96c..1815849 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -286,7 +286,7 @@ int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;

-	entry = firmware_map_find_entry_bootmem(start, end, type);
+	entry = firmware_map_find_entry_bootmem(start, end - 1, type);
 	if (!entry) {
 		entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
 		if (!entry)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
