Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 817E4828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:51:49 -0400 (EDT)
Received: by mail-lf0-f52.google.com with SMTP id j11so59964773lfb.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:51:49 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id ps4si12154533lbb.43.2016.04.13.01.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 01:51:47 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id c126so60086426lfb.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:51:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e8d064377178b0a64f2e44c92c3c531a276ff4d5.1460457476.git.glider@google.com>
References: <e8d064377178b0a64f2e44c92c3c531a276ff4d5.1460457476.git.glider@google.com>
Date: Wed, 13 Apr 2016 11:51:47 +0300
Message-ID: <CAPAsAGxvAC+6MFjTL3wr0b3mxFj+0PMaR=DyaM1K7gzLC+7_bg@mail.gmail.com>
Subject: Re: [PATCH v1] lib/stackdepot.c: allow the stack trace hash to be zero
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-04-12 13:46 GMT+03:00 Alexander Potapenko <glider@google.com>:
> There's actually no point in reserving the zero hash value.
>
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---

No sign-off, poor changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
