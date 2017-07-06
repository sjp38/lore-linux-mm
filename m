Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5616B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 18:01:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so15022548pfe.11
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 15:01:37 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id 12si997537plb.93.2017.07.06.15.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 15:01:35 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id k14so7253821pgr.0
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 15:01:35 -0700 (PDT)
From: Greg Hackmann <ghackmann@google.com>
Subject: [PATCH 0/4] kasan: add clang support
Date: Thu,  6 Jul 2017 15:01:10 -0700
Message-Id: <20170706220114.142438-1-ghackmann@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

This patch series adds support for building KASAN-enabled kernels with clang.
This mostly involves adding callbacks for a couple of new features in LLVM's
AddressSanitizer implementation.  We also need to probe for the (slightly
different) CFLAGS used to configure ASAN with clang.

*** BLURB HERE ***

Alexander Potapenko (1):
  kasan: added functions for unpoisoning stack variables

Greg Hackmann (3):
  kasan: support alloca() poisoning
  kasan: support LLVM-style asan parameters
  kasan: add compiler support for clang

 include/linux/compiler-clang.h | 10 ++++++++++
 lib/test_kasan.c               | 22 ++++++++++++++++++++++
 mm/kasan/kasan.c               | 41 +++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h               |  8 ++++++++
 mm/kasan/report.c              |  3 +++
 scripts/Makefile.kasan         | 10 +++++++++-
 6 files changed, 93 insertions(+), 1 deletion(-)

-- 
2.13.2.725.g09c95d1e9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
