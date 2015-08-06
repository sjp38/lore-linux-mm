Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBF66B025B
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 13:54:57 -0400 (EDT)
Received: by qged69 with SMTP id d69so58365652qge.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 10:54:57 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id n97si6774074qkh.75.2015.08.06.10.54.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 10:54:56 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so21572657qge.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 10:54:56 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zswap: comment clarifying maxlen
Date: Thu,  6 Aug 2015 13:54:49 -0400
Message-Id: <1438883689-7868-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <CALZtONCquXbE-dHWQUfKL_OSO7Bk5HN+t2EZduoD11vcaiJxmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

Add a comment clarifying the variable-size array created on the stack will
always be either CRYPTO_MAX_ALG_NAME (64) or 32 bytes long.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index 7bbecd9..b198081 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -691,6 +691,11 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	char str[kp->str->maxlen], *s;
 	int ret;
 
+	/*
+	 * kp is either zswap_zpool_kparam or zswap_compressor_kparam, defined
+	 * at the top of this file, so maxlen is CRYPTO_MAX_ALG_NAME (64) or
+	 * 32 (arbitrary).
+	 */
 	strlcpy(str, val, kp->str->maxlen);
 	s = strim(str);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
