Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8F46B0003
	for <linux-mm@kvack.org>; Sun, 27 May 2018 10:41:37 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id u23-v6so6956005ual.4
        for <linux-mm@kvack.org>; Sun, 27 May 2018 07:41:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g62-v6sor1992800vkc.155.2018.05.27.07.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 May 2018 07:41:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx6DBp+d33_fytOGPWw11xg_L0MdGp1M2e5Obc0N9kMRQ@mail.gmail.com>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
 <CAGXu5j+PHzDwnJxJwMJ=WuhacDn_vJWe9xZx+Kbsh28vxOGRiA@mail.gmail.com> <CA+55aFx6DBp+d33_fytOGPWw11xg_L0MdGp1M2e5Obc0N9kMRQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 27 May 2018 07:41:34 -0700
Message-ID: <CAGXu5jK_YfFLKt4vde__bzmhH9SCEz01ET9wyycYkhSSQj5+RA@mail.gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Salvatore Mesoraca <s.mesoraca16@gmail.com>, Jann Horn <jannh@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, LSM List <linux-security-module@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>

On Sat, May 26, 2018 at 6:33 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Thus commit f511c0b17b08 "Yes, people use FOLL_FORCE ;)"
>
> Side note, that very sam ecommit f511c0b17b08 is also the explanation for
> why the patch under discussion now seems broken.
>
> People really do use "write to /proc/self/mem" as a way to keep the
> mappings read-only, but have a way to change them when required.

Ah! Yes, that is the commit I was trying to find. Thanks!

-Kees

-- 
Kees Cook
Pixel Security
