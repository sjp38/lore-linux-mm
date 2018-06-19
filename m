Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA526B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:18:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n10-v6so38627qtp.11
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:18:56 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id m41-v6si5279965qvc.214.2018.06.19.08.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 08:18:55 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id c11a0fd9
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 15:12:57 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id e8d87ce1 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 15:12:56 +0000 (UTC)
Received: by mail-ot0-f173.google.com with SMTP id d19-v6so58477oti.8
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:18:49 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
 <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
 <CACT4Y+YLySJMfG4kCJ2FiPpPtN6sgU6k2FoZUYMFrJGLj+vDjw@mail.gmail.com>
 <CAHmME9oeoSbRZyf6qJTg+q-zZanYGu4q=YOZNqCCbRAFu15R9w@mail.gmail.com> <CALvZod7MfTTwbfG3zC1kGrZB1Cf0UAnbvdbqhC5Dm=uy6=DtOg@mail.gmail.com>
In-Reply-To: <CALvZod7MfTTwbfG3zC1kGrZB1Cf0UAnbvdbqhC5Dm=uy6=DtOg@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 17:18:36 +0200
Message-ID: <CAHmME9q7aKGNiYauCjyy6Fu+bryPphEoLEMbAObTJgTrTfS2uw@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 5:08 PM Shakeel Butt <shakeelb@google.com> wrote:
> > > Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
> > > SLAB, and I suspect Shakeel may also be using SLAB. So if you are
> > > using SLUB, there is significant chance that it's a bug in the SLUB
> > > part of the change.
> >
> > Nice intuition; I am indeed using SLUB rather than SLAB...
> >
>
> Can you try once with SLAB? Just to make sure that it is SLUB specific.

Sorry, I meant to mention that earlier. I tried with SLAB; the crash
does not occur. This appears to be SLUB-specific.
