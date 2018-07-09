Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF9C06B02E5
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:24:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b5-v6so11891876pfi.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 07:24:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a190-v6si14307307pgc.241.2018.07.09.07.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 07:24:49 -0700 (PDT)
Date: Mon, 9 Jul 2018 07:24:45 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: BUG: corrupted list in cpu_stop_queue_work
Message-ID: <20180709142445.GC2662@bombadil.infradead.org>
References: <00000000000032412205706753b5@google.com>
 <000000000000693c7d057087caf3@google.com>
 <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
 <20180709133212.GA2662@bombadil.infradead.org>
 <8b258017-8817-8050-14a5-5e55c56bbf18@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b258017-8817-8050-14a5-5e55c56bbf18@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+d8a8e42dfba0454286ff@syzkaller.appspotmail.com>, bigeasy@linutronix.de, linux-kernel@vger.kernel.org, matt@codeblueprint.co.uk, mingo@kernel.org, peterz@infradead.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-mm <linux-mm@kvack.org>

On Mon, Jul 09, 2018 at 11:15:54PM +0900, Tetsuo Handa wrote:
> On 2018/07/09 22:32, Matthew Wilcox wrote:
> >> >From d6f24d6eecd79836502527624f8086f4e3e4c331 Mon Sep 17 00:00:00 2001
> >> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Date: Mon, 9 Jul 2018 15:58:44 +0900
> >> Subject: [PATCH] shmem: Fix crash upon xas_store() failure.
> >>
> >> syzbot is reporting list corruption [1]. This is because xas_store() from
> >> shmem_add_to_page_cache() is not handling memory allocation failure. Fix
> >> this by checking xas_error() after xas_store().
> > 
> > I have no idea why you wrote this patch on Monday when I already said
> > I knew what the problem was on Friday, fixed the problem and pushed it
> > out to my git tree on Saturday.
> > 
> 
> Because syzbot found a C reproducer on 2018/07/09 02:29 UTC, and your fix was
> not in time for a kernel version syzbot was testing, and you were not listed
> as a recipient of this bug, and I didn't know you already fixed this bug.
> 
> Anyway, linux-next-20180709 still does not have this fix.
> What is the title of your fix you pushed on Saturday?

I folded it into shmem: Convert shmem_add_to_page_cache to XArray.
I can see it's fixed in today's linux-next.  I fixed it differently
from the way you fixed it, so if you're looking for an xas_error check
after xas_store, you won't find it.
