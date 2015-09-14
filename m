Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id B738C6B0258
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:46:21 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so143614012wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:21 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bt11si18680657wjb.210.2015.09.14.06.46.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:46:20 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so133845184wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:20 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/7] kasan: various fixes
Date: Mon, 14 Sep 2015 15:46:01 +0200
Message-Id: <cover.1442238094.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

This patchset contains various fixes for KASAN. That includes:

1. Improving reported bug types.

Making KASAN distinguish and report the following types of bugs:
slab-out-of-bounds, stack-out-of-bounds, global-out-of-bounds
use-after-free, null-ptr-deref, user-memory-access, wild-memory-access.

2. Making references to the tool name consistent.

We decided to use KASAN as the short name of the tool since a lot of
people already use it, and KernelAddressSanitizer as the full name
to be consistent with the userspace AddressSantizer.

Changes since v1:
- rebased on top of the latest -mm

Andrey Konovalov (7):
  kasan: update reported bug types for not user nor kernel memory
    accesses
  kasan: update reported bug types for kernel memory accesses
  kasan: accurately determine the type of the bad access
  kasan: update log messages
  kasan: various fixes in documentation
  kasan: move KASAN_SANITIZE in arch/x86/boot/Makefile
  kasan: update reference to kasan prototype repo

 Documentation/kasan.txt     | 43 +++++++++++-----------
 arch/x86/boot/Makefile      |  4 +-
 arch/x86/mm/kasan_init_64.c |  2 +-
 mm/kasan/kasan.c            | 12 ++----
 mm/kasan/kasan.h            |  3 --
 mm/kasan/report.c           | 89 +++++++++++++++++++++++++--------------------
 6 files changed, 78 insertions(+), 75 deletions(-)

-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
