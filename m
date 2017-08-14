Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1FD6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:36:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so13493897wrc.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:36:04 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id 93si5296564wra.429.2017.08.14.02.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 02:36:03 -0700 (PDT)
Subject: [PATCH 2/2] kmemleak: Use seq_puts() in print_unreferenced()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <301bc8c9-d9f6-87be-ce1d-dc614e82b45b@users.sourceforge.net>
Message-ID: <b764965b-1d80-83c6-72f0-7b64d1036168@users.sourceforge.net>
Date: Mon, 14 Aug 2017 11:36:01 +0200
MIME-Version: 1.0
In-Reply-To: <301bc8c9-d9f6-87be-ce1d-dc614e82b45b@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Aug 2017 11:23:11 +0200

The script "checkpatch.pl" pointed information out like the following.

WARNING: Prefer seq_puts to seq_printf

Thus fix the affected source code place.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c6c798d90b2e..cfac550d4d00 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -373,7 +373,7 @@ static void print_unreferenced(struct seq_file *seq,
 		   object->comm, object->pid, object->jiffies,
 		   msecs_age / 1000, msecs_age % 1000);
 	hex_dump_object(seq, object);
-	seq_printf(seq, "  backtrace:\n");
+	seq_puts(seq, "  backtrace:\n");
 
 	for (i = 0; i < object->trace_len; i++) {
 		void *ptr = (void *)object->trace[i];
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
