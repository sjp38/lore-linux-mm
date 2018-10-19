Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 977E06B0007
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 06:58:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f5-v6so25098459plf.11
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 03:58:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c89-v6si25066189pfe.60.2018.10.19.03.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Oct 2018 03:58:56 -0700 (PDT)
Date: Fri, 19 Oct 2018 12:58:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm/kasan: make quarantine_lock a raw_spinlock_t
Message-ID: <20181019105851.GG3121@hirez.programming.kicks-ass.net>
References: <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
 <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
 <20181010092929.a5gd3fkkw6swco4c@linutronix.de>
 <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
 <20181010095343.6qxved3owi6yokoa@linutronix.de>
 <CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
 <20181010214945.5owshc3mlrh74z4b@linutronix.de>
 <20181012165655.f067886428a394dc7fbae7af@linux-foundation.org>
 <20181013135058.GC4931@worktop.programming.kicks-ass.net>
 <20181015163529.30ed9b0ac18e20dd975f4253@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015163529.30ed9b0ac18e20dd975f4253@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Mon, Oct 15, 2018 at 04:35:29PM -0700, Andrew Morton wrote:
> On Sat, 13 Oct 2018 15:50:58 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > The whole raw_spinlock_t is for RT, no other reason.
> 
> Oh.  I never realised that.
> 
> Is this documented anywhere?  Do there exist guidelines which tell
> non-rt developers and reviewers when it should be used?

I'm afraid not; I'll put it on the todo list ... I've also been working
on some lockdep validation for the lock order stuff.
