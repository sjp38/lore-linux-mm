Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 392246B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:14:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q21-v6so1605253pff.4
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:14:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w135-v6si2045251pff.8.2018.07.03.14.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 14:14:31 -0700 (PDT)
Date: Tue, 3 Jul 2018 14:14:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re:
Message-Id: <20180703141429.c752e3342426b9f8d48ef255@linux-foundation.org>
In-Reply-To: <20180703145235.28050-1-bigeasy@linutronix.de>
References: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
	<20180703145235.28050-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, tglx@linutronix.de, Kirill Tkhai <ktkhai@virtuozzo.com>


> Reply-To: "[PATCH 0/4] mm/list_lru": add.list_lru_shrink_walk_irq@mail.linuxfoundation.org.and.use.it ()

Well that's messed up.

On Tue,  3 Jul 2018 16:52:31 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> My intepretation of situtation is that Vladimir Davydon is fine patch #1
> and #2 of the series [0] but dislikes the irq argument and struct
> member. It has been suggested to use list_lru_shrink_walk_irq() instead
> the approach I went on in "mm: list_lru: Add lock_irq member to
> __list_lru_init()".
> 
> This series is based on the former two patches and introduces
> list_lru_shrink_walk_irq() (and makes the third patch of series
> obsolete).
> In patch 1-3 I tried a tiny cleanup so the different locking
> (spin_lock() vs spin_lock_irq()) is simply lifted to the caller of the
> function.
> 
> [0] The patch
>       mm: workingset: remove local_irq_disable() from count_shadow_nodes() 
>    and
>       mm: workingset: make shadow_lru_isolate() use locking suffix
> 

This isn't a very informative [0/n] changelog.  Some overall summary of
the patchset's objective, behaviour, use cases, testing results, etc.

I'm seeing significant conflicts with Kirill's "Improve shrink_slab()
scalability (old complexity was O(n^2), new is O(n))" series, which I
merged eight milliseconds ago.  Kirill's patchset is large but fairly
straightforward so I expect it's good for 4.18.  So I suggest we leave
things a week or more then please take a look at redoing this patchset
on top of that work?  
