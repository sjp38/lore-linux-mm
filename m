Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 931A9280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 04:40:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x184so19066801wmf.14
        for <linux-mm@kvack.org>; Sun, 21 May 2017 01:40:23 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id r4si16238957wmr.130.2017.05.21.01.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 01:40:22 -0700 (PDT)
Subject: [PATCH 3/3] zswap: Delete an error message for a failed memory
 allocation in zswap_dstmem_prepare()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Message-ID: <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
Date: Sun, 21 May 2017 10:27:30 +0200
MIME-Version: 1.0
In-Reply-To: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 09:29:25 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zswap.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 3f0a9a1daef4..ed7312291df9 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -374,7 +374,6 @@ static int zswap_dstmem_prepare(unsigned int cpu)
-	if (!dst) {
-		pr_err("can't allocate compressor buffer\n");
+	if (!dst)
 		return -ENOMEM;
-	}
+
 	per_cpu(zswap_dstmem, cpu) = dst;
 	return 0;
 }
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
