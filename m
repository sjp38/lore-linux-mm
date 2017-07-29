Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5364E6B054C
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:06:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u11so65215684qtu.10
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 16:06:12 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id s13si20618109qks.161.2017.07.29.16.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 16:06:11 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id d136so23954553qkg.3
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 16:06:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKTCnznL9fxBq_xwm-z4yg_7muNKFJso26GMbEJCbSzN38N+fg@mail.gmail.com>
References: <20170729140901.5887-1-bsingharora@gmail.com> <CAKTCnznL9fxBq_xwm-z4yg_7muNKFJso26GMbEJCbSzN38N+fg@mail.gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sun, 30 Jul 2017 09:06:10 +1000
Message-ID: <CAKTCnzneP4Hn6Ko69TBPv4scaQYMQoNdg8eQ5dRx4TWS6a=o=Q@mail.gmail.com>
Subject: Re: [RFC PATCH v1] powerpc/radix/kasan: KASAN support for Radix
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michael Ellerman <mpe@ellerman.id.au>
Cc: kasan-dev@googlegroups.com, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Balbir Singh <bsingharora@gmail.com>

On Sun, Jul 30, 2017 at 8:58 AM, Balbir Singh <bsingharora@gmail.com> wrote:
>> +
>> +extern struct static_key_false powerpc_kasan_enabled_key;
>> +#define check_return_arch_not_ready() \
>> +       do {                                                            \
>> +               if (!static_branch_likely(&powerpc_kasan_enabled_key))  \
>> +                       return;                                         \
>> +       } while (0)
>
> This is supposed to call __mem*() before returning, I'll do a new RFC,
> I must have missed it in my rebasing somewhere

Sorry for the noise, I am sleep deprived, I was trying to state that this
does not work for hash (with disable_radix on the command-line)

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
