Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 343D36B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 12:11:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w21-v6so7915922wmc.4
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 09:11:28 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id n1-v6si19568804wrr.373.2018.07.14.09.11.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jul 2018 09:11:26 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/hmm.c: remove redundant variables align_start and align_end
Date: Sat, 14 Jul 2018 17:11:24 +0100
Message-Id: <20180714161124.3923-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variables align_start and align_end are being assigned but are
never used hence they are redundant and can be removed.

Cleans up clang warnings:
warning: variable 'align_start' set but not used [-Wunused-but-set-variable]
warning: variable 'align_size' set but not used [-Wunused-but-set-variable]

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/hmm.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index caf9df27599e..76e7a058b32f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -973,10 +973,7 @@ static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
 
 static void hmm_devmem_radix_release(struct resource *resource)
 {
-	resource_size_t key, align_start, align_size;
-
-	align_start = resource->start & ~(PA_SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(resource), PA_SECTION_SIZE);
+	resource_size_t key;
 
 	mutex_lock(&hmm_devmem_lock);
 	for (key = resource->start;
-- 
2.17.1
