Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 910E86B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:17:20 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q19-v6so12023435plr.22
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:17:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1-v6sor5560166plt.102.2018.06.19.06.17.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 06:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com>
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
 <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
 <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com> <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Jun 2018 15:16:58 +0200
Message-ID: <CACT4Y+YAYwXrTkawfPWMhX5tk85f9CDfN_w+5JfykgDnOG57PQ@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 3:04 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> HI Dimitry,
>
> On Tue, Jun 19, 2018 at 6:55 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>> Your code frees all entries before freeing the cache, right? If you
>> add total_entries check before freeing the cache, it does not fire,
>> right?
>
> Yes, certainly.
>
>> Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
>> SLAB, and I suspect Shakeel may also be using SLAB. So if you are
>> using SLUB, there is significant chance that it's a bug in the SLUB
>> part of the change.
>
> Nice intuition; I am indeed using SLUB rather than SLAB...

Now the reasonable question is: does SLUB path of
f9e13c0a5a33d1eaec374d6d4dab53a4f72756a0 have a bug?
syzbot has stressed SLAB version to death, and any such issues would
pop up very loudly, but I am not sure what is the amount of testing
for SLUB.
