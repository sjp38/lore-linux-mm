Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA8FF6B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 10:38:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v127so987738wma.3
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:38:39 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 63si7816915wrb.8.2017.10.17.07.38.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 07:38:38 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/hmm: remove redundant variable align_end
Date: Tue, 17 Oct 2017 15:38:37 +0100
Message-Id: <20171017143837.23207-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable align_end is assigned a value but it is never read, so
the variable is redundant and can be removed. Cleans up the clang
warning: Value stored to 'align_end' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/hmm.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index a88a847bccba..ea19742a5d60 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -803,11 +803,10 @@ static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
 
 static void hmm_devmem_radix_release(struct resource *resource)
 {
-	resource_size_t key, align_start, align_size, align_end;
+	resource_size_t key, align_start, align_size;
 
 	align_start = resource->start & ~(PA_SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(resource), PA_SECTION_SIZE);
-	align_end = align_start + align_size - 1;
 
 	mutex_lock(&hmm_devmem_lock);
 	for (key = resource->start;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
