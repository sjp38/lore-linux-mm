Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 245466B4B93
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:35:59 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z17-v6so3253972wrr.16
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 04:35:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4-v6sor393144wmg.11.2018.08.29.04.35.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 04:35:57 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v6 18/18] kasan: add SPDX-License-Identifier mark to source files
Date: Wed, 29 Aug 2018 13:35:22 +0200
Message-Id: <878e719ff82dd0e43d9ede66856f2f76d072c417.1535462971.git.andreyknvl@google.com>
In-Reply-To: <cover.1535462971.git.andreyknvl@google.com>
References: <cover.1535462971.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patch adds a "SPDX-License-Identifier: GPL-2.0" mark to all source
files under mm/kasan.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/common.c         | 1 +
 mm/kasan/kasan.c          | 1 +
 mm/kasan/kasan_init.c     | 1 +
 mm/kasan/kasan_report.c   | 1 +
 mm/kasan/khwasan.c        | 1 +
 mm/kasan/khwasan_report.c | 1 +
 mm/kasan/quarantine.c     | 1 +
 mm/kasan/report.c         | 1 +
 8 files changed, 8 insertions(+)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index e5648f4218eb..f2576d93e74c 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains common KASAN and KHWASAN code.
  *
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 44ec228de0a2..128a865c9e05 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains core KASAN code.
  *
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 7a2a2f13f86f..b3c068ab2a85 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains some kasan initialization code.
  *
diff --git a/mm/kasan/kasan_report.c b/mm/kasan/kasan_report.c
index fdf2d77e3125..48da73f4ef7c 100644
--- a/mm/kasan/kasan_report.c
+++ b/mm/kasan/kasan_report.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains KASAN specific error reporting code.
  *
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
index 6b1309278e39..934f80b2d22e 100644
--- a/mm/kasan/khwasan.c
+++ b/mm/kasan/khwasan.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains core KHWASAN code.
  *
diff --git a/mm/kasan/khwasan_report.c b/mm/kasan/khwasan_report.c
index 51238b404b08..4e193546d94e 100644
--- a/mm/kasan/khwasan_report.c
+++ b/mm/kasan/khwasan_report.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains KHWASAN specific error reporting code.
  *
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 3a8ddf8baf7d..0e4dc1a22615 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * KASAN quarantine.
  *
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index e031c78f2e52..633b4b245798 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * This file contains common KASAN and KHWASAN error reporting code.
  *
-- 
2.19.0.rc0.228.g281dcd1b4d0-goog
