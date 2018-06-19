Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE3D6B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:08:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v13-v6so349822wmc.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:08:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d5-v6sor9021399wri.16.2018.06.19.08.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 08:08:40 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
 <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
 <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com> <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com>
In-Reply-To: <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Jun 2018 08:08:27 -0700
Message-ID: <CALvZod7MfTTwbfG3zC1kGrZB1Cf0UAnbvdbqhC5Dm=uy6=DtOg@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason@zx2c4.com
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 6:05 AM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> HI Dimitry,
>
> On Tue, Jun 19, 2018 at 6:55 AM Dmitry Vyukov <dvyukov@google.com> wrote:
> > Your code frees all entries before freeing the cache, right? If you
> > add total_entries check before freeing the cache, it does not fire,
> > right?
>
> Yes, certainly.
>
> > Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
> > SLAB, and I suspect Shakeel may also be using SLAB. So if you are
> > using SLUB, there is significant chance that it's a bug in the SLUB
> > part of the change.
>
> Nice intuition; I am indeed using SLUB rather than SLAB...
>

Can you try once with SLAB? Just to make sure that it is SLUB specific.
