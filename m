Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A04656B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:10:42 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so12554800wiv.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:10:42 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id g9si4520096wix.74.2015.01.28.07.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 07:10:41 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] eventfs: avoid unused variable warning
Date: Wed, 28 Jan 2015 16:10:28 +0100
Message-ID: <88925492.FKoyo2trpD@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Chris Mason <clm@fb.com>, Davide Libenzi <davidel@xmailserver.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

An optimization patch from Chris Mason causes build warnings about
an unused variable.

The patch that broke this is currently in the akpm-current series,
so this fixup can be folded into the original patch. I was expecting
multiple people to send a patch for this, so I waited a bit at first.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 567162b87a5c5f  ("eventfd: don't take the spinlock in eventfd_poll")

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 439e6f0177f3..303ddc43dbee 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -118,7 +118,6 @@ static unsigned int eventfd_poll(struct file *file, poll_table *wait)
 {
 	struct eventfd_ctx *ctx = file->private_data;
 	unsigned int events = 0;
-	unsigned long flags;
 	unsigned int count;
 
 	poll_wait(file, &ctx->wqh, wait);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
