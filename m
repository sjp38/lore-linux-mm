Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF4246B0595
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 18:58:29 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p3so98705114qtg.4
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 15:58:29 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id s14si6289326qke.263.2017.07.29.15.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 15:58:29 -0700 (PDT)
Received: by mail-qk0-x229.google.com with SMTP id d145so127616998qkc.2
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 15:58:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170729140901.5887-1-bsingharora@gmail.com>
References: <20170729140901.5887-1-bsingharora@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sun, 30 Jul 2017 08:58:28 +1000
Message-ID: <CAKTCnznL9fxBq_xwm-z4yg_7muNKFJso26GMbEJCbSzN38N+fg@mail.gmail.com>
Subject: Re: [RFC PATCH v1] powerpc/radix/kasan: KASAN support for Radix
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michael Ellerman <mpe@ellerman.id.au>
Cc: kasan-dev@googlegroups.com, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Balbir Singh <bsingharora@gmail.com>

> +
> +extern struct static_key_false powerpc_kasan_enabled_key;
> +#define check_return_arch_not_ready() \
> +       do {                                                            \
> +               if (!static_branch_likely(&powerpc_kasan_enabled_key))  \
> +                       return;                                         \
> +       } while (0)

This is supposed to call __mem*() before returning, I'll do a new RFC,
I must have missed it in my rebasing somewhere

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
