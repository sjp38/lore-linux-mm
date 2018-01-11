Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7CA26B0270
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 10:29:19 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 61so1673876wrg.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:29:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t14sor323391wmc.5.2018.01.11.07.29.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 07:29:18 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 1/2] kasan: fix prototype author email address
Date: Thu, 11 Jan 2018 16:29:08 +0100
Message-Id: <de3b7ffc30a55178913a7d3865216aa7accf6c40.1515684162.git.andreyknvl@google.com>
In-Reply-To: <cover.1515684162.git.andreyknvl@google.com>
References: <cover.1515684162.git.andreyknvl@google.com>
In-Reply-To: <cover.1515684162.git.andreyknvl@google.com>
References: <cover.1515684162.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

Use the new one.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/kasan.c  | 2 +-
 mm/kasan/report.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba487df5..cb4065f31f7f 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -5,7 +5,7 @@
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
  *
  * Some code borrowed from https://github.com/xairy/kasan-prototype by
- *        Andrey Konovalov <adech.fo@gmail.com>
+ *        Andrey Konovalov <andreyknvl@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 410c8235e671..eee796a005ac 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -5,7 +5,7 @@
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
  *
  * Some code borrowed from https://github.com/xairy/kasan-prototype by
- *        Andrey Konovalov <adech.fo@gmail.com>
+ *        Andrey Konovalov <andreyknvl@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
