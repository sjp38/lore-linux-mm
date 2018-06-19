Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31C896B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:59:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f65-v6so6620438wmd.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 20:59:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v17-v6sor2921079wmh.68.2018.06.18.20.59.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 20:59:18 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
In-Reply-To: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 18 Jun 2018 20:59:01 -0700
Message-ID: <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason@zx2c4.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 18, 2018 at 7:51 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> Hello Shakeel,
>
> It may be the case that f9e13c0a5a33d1eaec374d6d4dab53a4f72756a0 has
> introduced a regression. I've bisected a failing test to this commit,
> and after staring at the my code for a long time, I'm unable to find a
> bug that this commit might have unearthed. Rather, it looks like this
> commit introduces a performance optimization, rather than a
> correctness fix, so it seems that whatever test case is failing is
> likely an incorrect failure. Does that seem like an accurate
> possibility to you?
>
> Below is a stack trace when things go south. Let me know if you'd like
> to run my test suite, and I can send additional information.
>
> Regards,
> Jason
>

Hi Jason, yes please do send me the test suite with the kernel config.

Shakeel
