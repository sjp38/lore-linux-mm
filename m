Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id BFA626B0268
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:46:37 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so141600407wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:37 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id p4si17242427wiz.80.2015.09.14.06.46.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:46:28 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so143618513wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:28 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 7/7] kasan: update reference to kasan prototype repo
Date: Mon, 14 Sep 2015 15:46:08 +0200
Message-Id: <4c8a6793de540216e5fbc4616a4556374c3348ad.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
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
index ae6bd36..f5e068a 100644
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
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
