Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 499526B000C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 12:15:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v64so3661799wma.4
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 09:15:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor1128279wmc.51.2018.03.01.09.15.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 09:15:48 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/2] kasan: a couple of test fixes
Date: Thu,  1 Mar 2018 18:15:41 +0100
Message-Id: <cover.1519924383.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Nick Terrell <terrelln@fb.com>, Chris Mason <clm@fb.com>, Yury Norov <ynorov@caviumnetworks.com>, Al Viro <viro@zeniv.linux.org.uk>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Jeff Layton <jlayton@redhat.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

The first one fixes the invalid-free test crashing the kernel, and the
second one fixes the memset tests working incorrectly due to compiler
optimizations.

Andrey Konovalov (2):
  kasan: fix invalid-free test crashing the kernel
  kasan: disallow compiler to optimize away memset in tests

 lib/Makefile     | 1 +
 lib/test_kasan.c | 8 ++++++++
 2 files changed, 9 insertions(+)

-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
