Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDDD6B4938
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:55:57 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e17so18224235wrw.13
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:55:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t141sor3446528wme.23.2018.11.27.08.55.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:55:55 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 04/25] kasan: rename source files to reflect the new naming scheme
Date: Tue, 27 Nov 2018 17:55:22 +0100
Message-Id: <a6cd5acdc334d532754279a7d2d770e2be96419d.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

We now have two KASAN modes: generic KASAN and tag-based KASAN. Rename
kasan.c to generic.c to reflect that. Also rename kasan_init.c to init.c
as it contains initialization code for both KASAN modes.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/Makefile                 | 8 ++++----
 mm/kasan/{kasan.c => generic.c}   | 0
 mm/kasan/{kasan_init.c => init.c} | 0
 3 files changed, 4 insertions(+), 4 deletions(-)
 rename mm/kasan/{kasan.c => generic.c} (100%)
 rename mm/kasan/{kasan_init.c => init.c} (100%)

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index a6df14bffb6b..d643530b24aa 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -1,14 +1,14 @@
 # SPDX-License-Identifier: GPL-2.0
 KASAN_SANITIZE := n
 UBSAN_SANITIZE_common.o := n
-UBSAN_SANITIZE_kasan.o := n
+UBSAN_SANITIZE_generic.o := n
 KCOV_INSTRUMENT := n
 
-CFLAGS_REMOVE_kasan.o = -pg
+CFLAGS_REMOVE_generic.o = -pg
 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 
 CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
-CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
+CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := common.o kasan.o report.o kasan_init.o quarantine.o
+obj-y := common.o generic.o report.o init.o quarantine.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/generic.c
similarity index 100%
rename from mm/kasan/kasan.c
rename to mm/kasan/generic.c
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/init.c
similarity index 100%
rename from mm/kasan/kasan_init.c
rename to mm/kasan/init.c
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
