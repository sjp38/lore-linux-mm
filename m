Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id D7D67828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:20:40 -0400 (EDT)
Received: by mail-lf0-f45.google.com with SMTP id g184so59046495lfb.3
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:20:40 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id jm4si2872079lbc.134.2016.04.13.01.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 01:20:39 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id g184so59045912lfb.3
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:20:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <192b213b1a3518e98ed7e458aae19283b415ce3d.1460394567.git.glider@google.com>
References: <192b213b1a3518e98ed7e458aae19283b415ce3d.1460394567.git.glider@google.com>
Date: Wed, 13 Apr 2016 11:20:39 +0300
Message-ID: <CAPAsAGyWX78DfNCtC7K73nMd8D+-5Tx_UE3LtvjyTK6Xfn_V+Q@mail.gmail.com>
Subject: Re: [PATCH v1] mm, kasan: don't call kasan_krealloc() from ksize().
 Add a ksize() test.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-04-11 20:10 GMT+03:00 Alexander Potapenko <glider@google.com>:
> Instead of calling kasan_krealloc(), which replaces the memory allocation
> stack ID (if stack depot is used), just unpoison the whole memory chunk.
> Add a test that makes sure ksize() unpoisons the whole chunk.
>

Split in two please.

> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
