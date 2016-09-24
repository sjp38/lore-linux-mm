Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C168128025E
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 19:35:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 21so305430019pfy.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 16:35:29 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id g21si16043685pfj.59.2016.09.24.16.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 16:35:28 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id q2so53174892pfj.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 16:35:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com> <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Sun, 25 Sep 2016 01:35:27 +0200
Message-ID: <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On 22 September 2016 at 20:53, Matthew Wilcox
<mawilcox@linuxonhyperv.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> When compiling the radix tree with -O2, GCC thinks it can optimise:
>
>         void *entry = parent->slots[offset];
>         int siboff = entry - parent->slots;

If entry is a pointer to void, how can you do pointer arithmetic with it?
Also, if you use pointer distances, the use of int is not valid, it
should then be ptrdiff_t siboff.

lint(1) would bite your arse off in both cases.
Sadly only UNIX (Solaris, AIX, ...) use lint(1) as mandatory part of
the build process and make warnings and errors of lint(1) fatal...

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
