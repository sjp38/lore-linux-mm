Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 787FB6B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:51:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g7-v6so13098250wrb.19
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:51:19 -0700 (PDT)
Received: from david.siemens.de (david.siemens.de. [192.35.17.14])
        by mx.google.com with ESMTPS id f12si5208212wmi.101.2018.04.24.08.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 08:51:18 -0700 (PDT)
From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH] kmemleak: Report if we need to tune KMEMLEAK_EARLY_LOG_SIZE
Message-ID: <288b0afc-bcc3-a2aa-2791-707e625d1da7@siemens.com>
Date: Tue, 24 Apr 2018 17:51:15 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

...rather than just mysteriously disabling it.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 mm/kmemleak.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9a085d525bbc..156c0c69cc5c 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -863,6 +863,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
 
 	if (crt_early_log >= ARRAY_SIZE(early_log)) {
 		crt_early_log++;
+		pr_warn("Too many early logs\n");
 		kmemleak_disable();
 		return;
 	}
-- 
2.13.6
