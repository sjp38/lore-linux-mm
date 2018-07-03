Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE7486B000D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:44:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c12-v6so1606524wrd.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:44:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h74-v6si1627550wme.116.2018.07.03.14.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 14:44:31 -0700 (PDT)
Date: Tue, 3 Jul 2018 23:44:29 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re:
Message-ID: <20180703214429.tntoxzb66zikhukc@linutronix.de>
References: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
 <20180703145235.28050-1-bigeasy@linutronix.de>
 <20180703141429.c752e3342426b9f8d48ef255@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180703141429.c752e3342426b9f8d48ef255@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, tglx@linutronix.de, Kirill Tkhai <ktkhai@virtuozzo.com>

On 2018-07-03 14:14:29 [-0700], Andrew Morton wrote:
> 
> > Reply-To: "[PATCH 0/4] mm/list_lru": add.list_lru_shrink_walk_irq@mail.linuxfoundation.org.and.use.it ()
> 
> Well that's messed up.

indeed it is. This should get into Subject:

> On Tue,  3 Jul 2018 16:52:31 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:
> 
> > My intepretation of situtation is that Vladimir Davydon is fine patch #1
> > and #2 of the series [0] but dislikes the irq argument and struct
> > member. It has been suggested to use list_lru_shrink_walk_irq() instead
> > the approach I went on in "mm: list_lru: Add lock_irq member to
> > __list_lru_init()".
> > 
> > This series is based on the former two patches and introduces
> > list_lru_shrink_walk_irq() (and makes the third patch of series
> > obsolete).
> > In patch 1-3 I tried a tiny cleanup so the different locking
> > (spin_lock() vs spin_lock_irq()) is simply lifted to the caller of the
> > function.
> > 
> > [0] The patch
> >       mm: workingset: remove local_irq_disable() from count_shadow_nodes() 
> >    and
> >       mm: workingset: make shadow_lru_isolate() use locking suffix
> > 
> 
> This isn't a very informative [0/n] changelog.  Some overall summary of
> the patchset's objective, behaviour, use cases, testing results, etc.

The patches should be threaded as a reply to 3/3 of the series so I
assumed it was enough. And while Vladimir complained about 2/3 and 3/3
the discussion went on in 2/3 where he suggested to go on with the _irq
function. And testing, well with and without RT the function was invoked
as part of swapping (allocating memory until OOM) without complains.

> I'm seeing significant conflicts with Kirill's "Improve shrink_slab()
> scalability (old complexity was O(n^2), new is O(n))" series, which I
> merged eight milliseconds ago.  Kirill's patchset is large but fairly
> straightforward so I expect it's good for 4.18.  So I suggest we leave
> things a week or more then please take a look at redoing this patchset
> on top of that work?  

If Vladimir is okay with to redo and nobody else complains then I could
rebase these four patches on top of your tree next week.

Sebastian
