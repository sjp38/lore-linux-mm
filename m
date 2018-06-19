Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0826B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:05:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d7-v6so16555279qth.21
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:05:13 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id t64-v6si1251243qki.335.2018.06.19.06.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 06:05:10 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 9e41df9e
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 12:59:17 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 6e66547a (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 12:59:17 +0000 (UTC)
Received: by mail-oi0-f44.google.com with SMTP id d5-v6so18051796oib.5
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:05:08 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
 <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com> <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com>
In-Reply-To: <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 15:04:56 +0200
Message-ID: <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

HI Dimitry,

On Tue, Jun 19, 2018 at 6:55 AM Dmitry Vyukov <dvyukov@google.com> wrote:
> Your code frees all entries before freeing the cache, right? If you
> add total_entries check before freeing the cache, it does not fire,
> right?

Yes, certainly.

> Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
> SLAB, and I suspect Shakeel may also be using SLAB. So if you are
> using SLUB, there is significant chance that it's a bug in the SLUB
> part of the change.

Nice intuition; I am indeed using SLUB rather than SLAB...

Jason
