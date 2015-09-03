Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 007086B0268
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:48:20 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so10957970wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:20 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id hs8si11317807wib.89.2015.09.03.07.48.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:48:12 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so1568903wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:11 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 7/7] kasan: update reference to kasan prototype repo
Date: Thu,  3 Sep 2015 16:47:42 +0200
Message-Id: <d16559f97472cb31a4ebc8ff7cb222a71e736bf0.1441290220.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Update the reference to the kasan prototype repository on github,
since it was renamed.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/kasan.c  | 2 +-
 mm/kasan/report.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 61c9620..48fe48b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -4,7 +4,7 @@
  * Copyright (c) 2014 Samsung Electronics Co., Ltd.
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
  *
- * Some of code borrowed from https://github.com/xairy/linux by
+ * Some code borrowed from https://github.com/xairy/kasan-prototype by
  *        Andrey Konovalov <adech.fo@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 31b91b9..b423526 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -4,7 +4,7 @@
  * Copyright (c) 2014 Samsung Electronics Co., Ltd.
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
  *
- * Some of code borrowed from https://github.com/xairy/linux by
+ * Some code borrowed from https://github.com/xairy/kasan-prototype by
  *        Andrey Konovalov <adech.fo@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
-- 
2.5.0.457.gab17608

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
