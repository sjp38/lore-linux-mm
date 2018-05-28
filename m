Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D335F6B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 05:32:34 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h62-v6so5549931vke.1
        for <linux-mm@kvack.org>; Mon, 28 May 2018 02:32:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o132-v6sor3322151vko.269.2018.05.28.02.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 May 2018 02:32:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx6DBp+d33_fytOGPWw11xg_L0MdGp1M2e5Obc0N9kMRQ@mail.gmail.com>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
 <CAGXu5j+PHzDwnJxJwMJ=WuhacDn_vJWe9xZx+Kbsh28vxOGRiA@mail.gmail.com> <CA+55aFx6DBp+d33_fytOGPWw11xg_L0MdGp1M2e5Obc0N9kMRQ@mail.gmail.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Mon, 28 May 2018 11:32:13 +0200
Message-ID: <CAJHCu1Ky09DWskcD4nVW5u1C5faWMv1A4kcxWzdiap7+G1SPkg@mail.gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, LSM List <linux-security-module@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>

2018-05-27 3:33 GMT+02:00 Linus Torvalds <torvalds@linux-foundation.org>:
> On Sat, May 26, 2018 at 5:32 PM Kees Cook <keescook@chromium.org> wrote:
>
>> I went through some old threads from 2012 when e268337dfe26 was
>> introduced, and later when things got looked at during DirtyCOW. There
>> was discussion about removing FOLL_FORCE (in order to block writes on
>> a read-only memory region).
>
> Side note, we did that for /dev/mem, and things broke.
>
> Thus commit f511c0b17b08 "Yes, people use FOLL_FORCE ;)"
>
> Side note, that very sam ecommit f511c0b17b08 is also the explanation for
> why the patch under discussion now seems broken.
>
> People really do use "write to /proc/self/mem" as a way to keep the
> mappings read-only, but have a way to change them when required.

Oh, I didn't expect this, interesting...
A configurable LSM is probably the right way to do this.

Thank you for your time,

Salvatore
