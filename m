Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 657BB6B0006
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 16:20:29 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i64-v6so788701qkh.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:20:29 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id o31-v6si545789qva.266.2018.06.19.13.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 13:20:28 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 52c98023
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 20:14:33 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 5af4c768 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 20:14:33 +0000 (UTC)
Received: by mail-oi0-f47.google.com with SMTP id t22-v6so935368oih.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:20:27 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9q7aKGNiYauCjyy6Fu+bryPphEoLEMbAObTJgTrTfS2uw@mail.gmail.com>
 <20180619192139.31781-1-shakeelb@google.com>
In-Reply-To: <20180619192139.31781-1-shakeelb@google.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 22:20:15 +0200
Message-ID: <CAHmME9ppVOWn7Fo4DzaKN9M+-EZpDpA3Rp_4JoQVoSu8SEX=uw@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Shakeel,

On Tue, Jun 19, 2018 at 9:21 PM Shakeel Butt <shakeelb@google.com> wrote:
> Jason, can you try the following patch?

Your patch also fixed the problem, which was also fixed by enabling
CONFIG_SLUB_DEBUG, per the other email. I haven't checked to see if
your patch is simply a subset of what SLUB_DEBUG is doing or what. But
hopefully this points in the right direction now.

Jason
