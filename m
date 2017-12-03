Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30EE06B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 07:24:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so10551412pfh.7
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 04:24:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor3898971plb.135.2017.12.03.04.24.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Dec 2017 04:24:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171201213643.2506-1-paullawrence@google.com>
References: <20171201213643.2506-1-paullawrence@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 3 Dec 2017 13:24:25 +0100
Message-ID: <CACT4Y+bVp=x7kZXa86TEEidPB5sJyHG4j0gFffYkXsmMCKe57w@mail.gmail.com>
Subject: Re: [PATCH v3 0/5] kasan: support alloca, LLVM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On Fri, Dec 1, 2017 at 10:36 PM, Paul Lawrence <paullawrence@google.com> wrote:
> [PATCH v3 1/5] kasan: add compiler support for clang
>   Moved to start of patchset
>
> [PATCH v3 2/5] kasan/Makefile: Support LLVM style asan parameters.
>   Using Andrey's version.
>   Fixed up bug with testing CFLAGS_KASAN_SHADOW
>   Modifed to not output gcc style options on llvm
>
> [PATCH v3 3/5] kasan: support alloca() poisoning
>   Added alloca makefile option here
>   Modified to only unpoison the last block
>
> [PATCH v3 4/5] kasan: Add tests for alloca poisoning
>   No change
>
> [PATCH v3 5/5] kasan: added functions for unpoisoning stack variables
>   No change
>
> Paul Lawrence (5):
>   kasan: add compiler support for clang
>   kasan/Makefile: Support LLVM style asan parameters.
>   kasan: support alloca() poisoning
>   kasan: Add tests for alloca poisonong
>   kasan: added functions for unpoisoning stack variables
>
>  include/linux/compiler-clang.h |  8 +++++++
>  lib/test_kasan.c               | 22 +++++++++++++++++++
>  mm/kasan/kasan.c               | 49 ++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/kasan.h               |  8 +++++++
>  mm/kasan/report.c              |  4 ++++
>  scripts/Makefile.kasan         | 30 ++++++++++++++++----------
>  6 files changed, 110 insertions(+), 11 deletions(-)


The series looks good to me. Thanks for working on this, we need clang.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
